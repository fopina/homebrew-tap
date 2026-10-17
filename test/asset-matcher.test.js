const assert = require('node:assert/strict');
const test = require('node:test');
const { findAsset } = require('../asset-matcher');

const platforms = {
  macos: /([_-])(darwin|macos|mac|osx)([_-]|$)/,
  linux: /([_-])linux([_-]|$)/,
};
const architectures = {
  amd64: /([_-])(amd64|x86_64)([_.-]|$)/,
  arm64: /([_-])(arm64|aarch64)([_.-]|$)/,
};

const examples = [
  {
    project: 'Speedtest CLI',
    bin: 'speedtest-cli',
    assets: [
      'speedtest-cli_2.1.2_checksums.txt',
      'speedtest-cli_2.1.2_darwin_amd64',
      'speedtest-cli_2.1.2_darwin_arm64',
      'speedtest-cli_2.1.2_linux_amd64',
      'speedtest-cli_2.1.2_linux_arm64',
      'speedtest-cli_2.1.2_linux_armv7',
      'speedtest-cli_2.1.2_windows_amd64.exe',
    ],
    expected: {
      'macos/amd64': 'speedtest-cli_2.1.2_darwin_amd64',
      'macos/arm64': 'speedtest-cli_2.1.2_darwin_arm64',
      'linux/amd64': 'speedtest-cli_2.1.2_linux_amd64',
      'linux/arm64': 'speedtest-cli_2.1.2_linux_arm64',
    },
  },
  {
    project: 'PrivateBin CLI',
    bin: 'pbin',
    assets: [
      'pbin_darwin_amd64.tar.gz',
      'pbin_darwin_arm64.tar.gz',
      'pbin_linux_amd64.tar.gz',
      'pbin_linux_arm64.tar.gz',
    ],
    expected: {
      'macos/amd64': 'pbin_darwin_amd64.tar.gz',
      'macos/arm64': 'pbin_darwin_arm64.tar.gz',
      'linux/amd64': 'pbin_linux_amd64.tar.gz',
      'linux/arm64': 'pbin_linux_arm64.tar.gz',
    },
  },
];

for (const example of examples) {
  test(`${example.project} release assets match the four supported platforms`, () => {
    const assets = example.assets.map((name) => ({ name }));
    for (const [platformName, platform] of Object.entries(platforms)) {
      for (const [architectureName, architecture] of Object.entries(architectures)) {
        const key = `${platformName}/${architectureName}`;
        assert.equal(
          findAsset(assets, example.bin, platform, architecture, key).name,
          example.expected[key],
        );
      }
    }
  });
}
