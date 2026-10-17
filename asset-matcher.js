function findAsset(assets, bin, platform, architecture, label) {
  const prefix = `${bin.toLowerCase()}_`;
  const matches = assets.filter(({ name }) => {
    const normalized = name.toLowerCase();
    return normalized.startsWith(prefix) && platform.test(normalized) && architecture.test(normalized) &&
      /(\.(tar\.gz|tgz|zip))?$/.test(normalized);
  });
  if (matches.length !== 1) {
    const candidates = matches.map(({ name }) => `  ${name}`).join('\n') || '  (none)';
    const allAssets = assets.map(({ name }) => `  ${name}`).join('\n') || '  (none)';
    throw new Error(`Expected exactly one ${label} release archive; found ${matches.length}. Matching candidates:\n${candidates}\nAll release assets:\n${allAssets}`);
  }
  return matches[0];
}

module.exports = { findAsset };
