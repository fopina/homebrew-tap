#!/bin/bash -l

set -euo pipefail

if [[ ! "${INPUT_VERSION}" =~ ^v?[0-9][0-9A-Za-z.+_-]*$ ]]; then
  echo "version must be a release tag such as v1.2.3" >&2
  exit 1
fi

if [[ ! "${INPUT_FORMULA_FILE}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "formula_file may contain only letters, numbers, dots, underscores, and hyphens" >&2
  exit 1
fi

if [[ ! "${GITHUB_REPOSITORY:-}" =~ ^[^/]+/[^/]+$ ]]; then
  echo "GITHUB_REPOSITORY is missing or invalid; invoke this action from a GitHub repository" >&2
  exit 1
fi

release_tag="${INPUT_VERSION}"
formula_version="${release_tag#v}"
work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

release_json="${work_dir}/release.json"
api_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${release_tag}"
curl --fail --silent --show-error --location \
  --retry 3 \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --user-agent 'homebrew-tap-bump-action' \
  "${api_url}" --output "${release_json}"

if [[ "$(jq -r '.tag_name // empty' "${release_json}")" != "${release_tag}" ]]; then
  echo "GitHub release response did not match tag ${release_tag}" >&2
  exit 1
fi

find_asset() {
  local platform_regex="$1"
  local architecture_regex="$2"
  local matches
  local count

  matches="$(jq -c \
    --arg prefix "${INPUT_BIN,,}_" \
    --arg platform "${platform_regex}" \
    --arg architecture "${architecture_regex}" \
    '[.assets[] |
      select(.name | ascii_downcase as $name |
        ($name | startswith($prefix)) and
        ($name | test($platform)) and
        ($name | test($architecture)) and
        ($name | test("\\.(tar\\.gz|tgz|zip)$"))
      )]' \
    "${release_json}")"
  count="$(jq 'length' <<<"${matches}")"

  if [[ "${count}" != 1 ]]; then
    echo "Expected exactly one ${3} release archive; found ${count}. Matching candidates:" >&2
    jq -r '.[].name' <<<"${matches}" >&2
    echo "All release assets:" >&2
    jq -r '.assets[].name' "${release_json}" >&2
    exit 1
  fi

  jq -c '.[0]' <<<"${matches}"
}

macos_amd64="$(find_asset '(^|[_-])(darwin|macos|mac|osx)([_-]|$)' '(^|[_-])(amd64|x86_64)([_.-]|$)' 'macOS Intel')"
macos_arm64="$(find_asset '(^|[_-])(darwin|macos|mac|osx)([_-]|$)' '(^|[_-])(arm64|aarch64)([_.-]|$)' 'macOS Apple Silicon')"
linux_amd64="$(find_asset '(^|[_-])linux([_-]|$)' '(^|[_-])(amd64|x86_64)([_.-]|$)' 'Linux Intel')"
linux_arm64="$(find_asset '(^|[_-])linux([_-]|$)' '(^|[_-])(arm64|aarch64)([_.-]|$)' 'Linux ARM64')"

echo "Matched release assets for ${GITHUB_REPOSITORY}@${release_tag}:"
for asset in "${macos_amd64}" "${macos_arm64}" "${linux_amd64}" "${linux_arm64}"; do
  jq -r '"  \(.name) -> \(.browser_download_url)"' <<<"${asset}"
done

download_and_hash() {
  local asset="$1"
  local destination="$2"
  local url
  url="$(jq -r '.browser_download_url' <<<"${asset}")"
  curl --fail --silent --show-error --location --retry 3 "${url}" --output "${work_dir}/${destination}"
  sha256sum "${work_dir}/${destination}" | cut -d ' ' -f1
}

MACOS_AMD64_URL="$(jq -r '.browser_download_url' <<<"${macos_amd64}")"
MACOS_AMD64_SHA256="$(download_and_hash "${macos_amd64}" macos_amd64)"
MACOS_ARM64_URL="$(jq -r '.browser_download_url' <<<"${macos_arm64}")"
MACOS_ARM64_SHA256="$(download_and_hash "${macos_arm64}" macos_arm64)"
LINUX_AMD64_URL="$(jq -r '.browser_download_url' <<<"${linux_amd64}")"
LINUX_AMD64_SHA256="$(download_and_hash "${linux_amd64}" linux_amd64)"
LINUX_ARM64_URL="$(jq -r '.browser_download_url' <<<"${linux_arm64}")"
LINUX_ARM64_SHA256="$(download_and_hash "${linux_arm64}" linux_arm64)"

export MACOS_AMD64_URL MACOS_AMD64_SHA256
export MACOS_ARM64_URL MACOS_ARM64_SHA256
export LINUX_AMD64_URL LINUX_AMD64_SHA256
export LINUX_ARM64_URL LINUX_ARM64_SHA256

tap_dir="${work_dir}/tap"
auth_header="AUTHORIZATION: basic $(printf 'x-access-token:%s' "${INPUT_TOKEN}" | base64 | tr -d '\n')"
git -c "http.extraheader=${auth_header}" clone --depth=1 -b "${INPUT_TAP_BRANCH}" \
  "https://github.com/${INPUT_TAP_REPO}.git" "${tap_dir}"
cd "${tap_dir}"

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'

confgen -o "Formula/${INPUT_FORMULA_FILE}.rb" /etc/formula.rb.tpl
git add "Formula/${INPUT_FORMULA_FILE}.rb"

if git diff --cached --quiet; then
  echo "Formula ${INPUT_FORMULA_FILE} is already up to date for ${formula_version}."
  pull_request_url=""
else
  git commit -m "${INPUT_FORMULA_FILE} ${formula_version}"

  pull_branch="bump-${INPUT_FORMULA_FILE}-${formula_version}"
  git -c "http.extraheader=${auth_header}" push --force origin "HEAD:${pull_branch}"

  tap_owner="${INPUT_TAP_REPO%%/*}"
  api_headers=(
    --header 'Accept: application/vnd.github+json'
    --header 'X-GitHub-Api-Version: 2022-11-28'
    --header "Authorization: Bearer ${INPUT_TOKEN}"
    --header 'User-Agent: homebrew-tap-bump-action'
  )
  pull_list="${work_dir}/pulls.json"
  curl --fail --silent --show-error --location --get \
    "${api_headers[@]}" \
    --data-urlencode "state=open" \
    --data-urlencode "head=${tap_owner}:${pull_branch}" \
    --data-urlencode "base=${INPUT_TAP_BRANCH}" \
    "https://api.github.com/repos/${INPUT_TAP_REPO}/pulls" \
    --output "${pull_list}"

  pull_request_url="$(jq -r '.[0].html_url // empty' "${pull_list}")"
  if [[ -n "${pull_request_url}" ]]; then
    echo "Updated existing pull request: ${pull_request_url}"
  else
    pull_request_payload="$(jq -cn \
      --arg title "${INPUT_FORMULA_FILE} ${formula_version}" \
      --arg body "Automated Homebrew formula update for ${GITHUB_REPOSITORY} release ${release_tag}." \
      --arg head "${pull_branch}" \
      --arg base "${INPUT_TAP_BRANCH}" \
      '{title:$title,body:$body,head:$head,base:$base}')"
    pull_response="${work_dir}/pull.json"
    curl --fail --silent --show-error --location \
      --request POST \
      "${api_headers[@]}" \
      --header 'Content-Type: application/json' \
      --data "${pull_request_payload}" \
      "https://api.github.com/repos/${INPUT_TAP_REPO}/pulls" \
      --output "${pull_response}"
    pull_request_url="$(jq -er '.html_url' "${pull_response}")"
    echo "Created pull request: ${pull_request_url}"
  fi
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  jq -cn \
    --arg macos_amd64 "$(jq -r '.name' <<<"${macos_amd64}")" \
    --arg macos_arm64 "$(jq -r '.name' <<<"${macos_arm64}")" \
    --arg linux_amd64 "$(jq -r '.name' <<<"${linux_amd64}")" \
    --arg linux_arm64 "$(jq -r '.name' <<<"${linux_arm64}")" \
    '{macos_amd64:$macos_amd64,macos_arm64:$macos_arm64,linux_amd64:$linux_amd64,linux_arm64:$linux_arm64}' \
    | sed 's/^/assets=/' >> "${GITHUB_OUTPUT}"
  echo "pull_request=${pull_request_url}" >> "${GITHUB_OUTPUT}"
fi
