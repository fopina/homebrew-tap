const { createHash } = require('node:crypto');
const { appendFileSync } = require('node:fs');
const { Octokit } = require('@octokit/rest');

const API_VERSION = '2022-11-28';
const USER_AGENT = 'homebrew-tap-bump-action';

function input(name, { required = false, fallback = '' } = {}) {
  const value = process.env[`INPUT_${name.toUpperCase()}`] ?? fallback;
  if (required && !value) throw new Error(`Input '${name}' is required`);
  return value;
}

function rubyString(value) {
  return JSON.stringify(value);
}

async function github(client, method, route, parameters = {}) {
  try {
    const { data } = await client.request(`${method} ${route}`, {
      ...parameters,
      headers: { 'X-GitHub-Api-Version': API_VERSION },
    });
    return data;
  } catch (error) {
    throw new Error(`GitHub API ${method} ${route} failed (${error.status || 'network error'}): ${error.message}`);
  }
}

function validateInputs(inputs, repository) {
  if (!/^v?[0-9][0-9A-Za-z.+_-]*$/.test(inputs.version)) {
    throw new Error('version must be a release tag such as v1.2.3');
  }
  if (!/^[A-Za-z0-9._-]+$/.test(inputs.formulaFile)) {
    throw new Error('formula_file may contain only letters, numbers, dots, underscores, and hyphens');
  }
  if (!/^[A-Z][A-Za-z0-9]*$/.test(inputs.formulaClass)) {
    throw new Error('formula_class must be a Ruby class name such as MyFormula');
  }
  if (!/^[^/]+\/[^/]+$/.test(repository)) {
    throw new Error('GITHUB_REPOSITORY is missing or invalid; invoke this action from a GitHub repository');
  }
  if (!/^[^/]+\/[^/]+$/.test(inputs.tapRepo)) {
    throw new Error('tap_repo must be in org/repo format');
  }
}

function findAsset(assets, bin, platform, architecture, label) {
  const prefix = `${bin.toLowerCase()}_`;
  const matches = assets.filter(({ name }) => {
    const normalized = name.toLowerCase();
    return normalized.startsWith(prefix) && platform.test(normalized) && architecture.test(normalized) &&
      /\.(tar\.gz|tgz|zip)$/.test(normalized);
  });
  if (matches.length !== 1) {
    const candidates = matches.map(({ name }) => `  ${name}`).join('\n') || '  (none)';
    const allAssets = assets.map(({ name }) => `  ${name}`).join('\n') || '  (none)';
    throw new Error(`Expected exactly one ${label} release archive; found ${matches.length}. Matching candidates:\n${candidates}\nAll release assets:\n${allAssets}`);
  }
  return matches[0];
}

async function sha256(url) {
  const response = await fetch(url, { headers: { 'User-Agent': USER_AGENT } });
  if (!response.ok) throw new Error(`Downloading ${url} failed (${response.status})`);
  const hash = createHash('sha256');
  for await (const chunk of response.body) hash.update(chunk);
  return hash.digest('hex');
}

function formula(inputs, repository, assets) {
  const homepage = inputs.homepage || `https://github.com/${repository}`;
  const testBody = inputs.test || `assert_predicate bin/${rubyString(inputs.bin)}, :executable?`;
  const indentedTest = testBody.split(/\r?\n/).map((line) => `    ${line}`).join('\n');
  return `class ${inputs.formulaClass} < Formula
  desc ${rubyString(inputs.description)}
  homepage ${rubyString(homepage)}
  license ${rubyString(inputs.license)}

  if OS.mac? && Hardware::CPU.intel?
    url ${rubyString(assets.macos_amd64.url)}
    sha256 ${rubyString(assets.macos_amd64.sha256)}
  end

  if OS.mac? && Hardware::CPU.arm?
    url ${rubyString(assets.macos_arm64.url)}
    sha256 ${rubyString(assets.macos_arm64.sha256)}
  end

  if OS.linux? && Hardware::CPU.intel?
    url ${rubyString(assets.linux_amd64.url)}
    sha256 ${rubyString(assets.linux_amd64.sha256)}
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url ${rubyString(assets.linux_arm64.url)}
    sha256 ${rubyString(assets.linux_arm64.sha256)}
  end

  def install
    bin.install ${rubyString(inputs.bin)}
  end

  test do
${indentedTest}
  end
end
`;
}

async function updateFormula(inputs, client, formulaPath, content) {
  const [owner, repo] = inputs.tapRepo.split('/');
  const repository = { owner, repo };
  const baseRef = await github(client, 'GET', '/repos/{owner}/{repo}/git/ref/{ref}', { ...repository, ref: `heads/${inputs.tapBranch}` });
  const pullBranch = `bump-${inputs.formulaFile}-${inputs.formulaVersion}`;
  let branchSha;
  try {
    const pullRef = await github(client, 'GET', '/repos/{owner}/{repo}/git/ref/{ref}', { ...repository, ref: `heads/${pullBranch}` });
    branchSha = pullRef.object.sha;
  } catch (error) {
    if (!error.message.includes('(404)')) throw error;
  }

  let existingFile;
  if (branchSha) {
    try {
      existingFile = await github(client, 'GET', '/repos/{owner}/{repo}/contents/{path}', { ...repository, path: formulaPath, ref: pullBranch });
      const current = Buffer.from(existingFile.content.replace(/\s/g, ''), 'base64').toString('utf8');
      if (current === content) return { pullRequest: await findOrCreatePullRequest(inputs, client, owner, repo, pullBranch), status: 'already up to date' };
    } catch (error) {
      if (!error.message.includes('(404)')) throw error;
    }
  }

  if (!branchSha) {
    await github(client, 'POST', '/repos/{owner}/{repo}/git/refs', {
      ...repository, ref: `refs/heads/${pullBranch}`, sha: baseRef.object.sha,
    });
  }
  await github(client, 'PUT', '/repos/{owner}/{repo}/contents/{path}', {
    ...repository,
    path: formulaPath,
    message: `${inputs.formulaFile} ${inputs.formulaVersion}`,
    content: Buffer.from(content, 'utf8').toString('base64'),
    branch: pullBranch,
    author: { name: 'github-actions[bot]', email: '41898282+github-actions[bot]@users.noreply.github.com' },
    committer: { name: 'github-actions[bot]', email: '41898282+github-actions[bot]@users.noreply.github.com' },
    ...(existingFile?.sha ? { sha: existingFile.sha } : {}),
  });

  const pullRequest = await findOrCreatePullRequest(inputs, client, owner, repo, pullBranch);
  return { pullRequest, status: pullRequest.created ? 'created' : 'updated' };
}

async function findOrCreatePullRequest(inputs, client, owner, repo, pullBranch) {
  const existing = await github(client, 'GET', '/repos/{owner}/{repo}/pulls', {
    owner, repo, state: 'open', head: `${owner}:${pullBranch}`, base: inputs.tapBranch,
  });
  if (existing.length) return { url: existing[0].html_url, created: false };
  const created = await github(client, 'POST', '/repos/{owner}/{repo}/pulls', {
    owner, repo,
    title: `${inputs.formulaFile} ${inputs.formulaVersion}`,
    body: `Automated Homebrew formula update for ${process.env.GITHUB_REPOSITORY} release ${inputs.version}.`,
    head: pullBranch,
    base: inputs.tapBranch,
  });
  return { url: created.html_url, created: true };
}

async function run() {
  const inputs = {
    token: input('token', { required: true }),
    version: input('version', { required: true }),
    formulaClass: input('formula_class', { required: true }),
    formulaFile: input('formula_file', { required: true }),
    description: input('description', { required: true }),
    homepage: input('homepage'),
    license: input('license', { fallback: 'MIT' }),
    bin: input('bin', { required: true }),
    test: input('test'),
    tapRepo: input('tap_repo', { fallback: 'fopina/homebrew-tap' }),
    tapBranch: input('tap_branch', { fallback: 'main' }),
  };
  const repository = process.env.GITHUB_REPOSITORY || '';
  validateInputs(inputs, repository);
  inputs.formulaVersion = inputs.version.replace(/^v/, '');

  const sourceClient = new Octokit({ userAgent: USER_AGENT });
  const tapClient = new Octokit({ auth: inputs.token, userAgent: USER_AGENT });
  const [sourceOwner, sourceRepo] = repository.split('/');
  const release = await github(sourceClient, 'GET', '/repos/{owner}/{repo}/releases/tags/{tag}', {
    owner: sourceOwner, repo: sourceRepo, tag: inputs.version,
  });
  if (release.tag_name !== inputs.version) throw new Error(`GitHub release response did not match tag ${inputs.version}`);

  const definitions = {
    macos_amd64: [/([_-])(darwin|macos|mac|osx)([_-]|$)/, /([_-])(amd64|x86_64)([_.-]|$)/, 'macOS Intel'],
    macos_arm64: [/([_-])(darwin|macos|mac|osx)([_-]|$)/, /([_-])(arm64|aarch64)([_.-]|$)/, 'macOS Apple Silicon'],
    linux_amd64: [/([_-])linux([_-]|$)/, /([_-])(amd64|x86_64)([_.-]|$)/, 'Linux Intel'],
    linux_arm64: [/([_-])linux([_-]|$)/, /([_-])(arm64|aarch64)([_.-]|$)/, 'Linux ARM64'],
  };
  const assets = {};
  for (const [key, [platform, architecture, label]] of Object.entries(definitions)) {
    const asset = findAsset(release.assets || [], inputs.bin, platform, architecture, label);
    assets[key] = { name: asset.name, url: asset.browser_download_url, sha256: await sha256(asset.browser_download_url) };
  }
  console.log(`Matched release assets for ${repository}@${inputs.version}:`);
  for (const asset of Object.values(assets)) console.log(`  ${asset.name} -> ${asset.url}`);

  const path = `Formula/${inputs.formulaFile}.rb`;
  const content = formula(inputs, repository, assets);
  const result = await updateFormula(inputs, tapClient, path, content);

  if (process.env.GITHUB_STEP_SUMMARY) {
    const line = result.status === 'already up to date'
      ? `Formula \`${inputs.formulaFile}\` is already up to date for \`${inputs.formulaVersion}\`.`
      : `${result.status[0].toUpperCase()}${result.status.slice(1)} pull request: [${inputs.tapRepo}](${result.pullRequest.url})`;
    appendFileSync(process.env.GITHUB_STEP_SUMMARY, `## Homebrew tap update\n\n${line}\n`);
  }
  if (process.env.GITHUB_OUTPUT) {
    appendFileSync(process.env.GITHUB_OUTPUT,
      `assets=${JSON.stringify(Object.fromEntries(Object.entries(assets).map(([key, asset]) => [key, asset.name])))}\n` +
      `pull_request=${result.pullRequest.url || ''}\n`);
  }
  console.log(result.pullRequest.url ? `${result.status} pull request: ${result.pullRequest.url}` : 'Formula is already up to date.');
}

run().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
