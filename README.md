# Homebrew Tap Bump Action

This action updates a formula from a published GitHub release. It reads the release belonging to the calling repository, finds the macOS and Linux Intel and ARM64 archives, calculates their SHA256 checksums, and commits the updated formula to the tap.

The release archives must start with the executable name (default: `pbin`) and include an OS and architecture in their names. For example:

- `pbin_darwin_amd64.tar.gz`
- `pbin_darwin_arm64.tar.gz`
- `pbin_linux_amd64.tar.gz`
- `pbin_linux_arm64.tar.gz`

All four archives are required. If an asset is missing or more than one asset matches a platform, the action fails and prints the release asset names to help diagnose the mismatch.

## Usage

Add a release workflow to the CLI repository:

```yaml
name: Update Homebrew formula

on:
  release:
    types: [published]

permissions:
  contents: read

jobs:
  bump-formula:
    runs-on: ubuntu-latest
    steps:
      - name: Update tap formula
        uses: fopina/homebrew-tap@bump-action
        with:
          version: ${{ github.event.release.tag_name }}
          token: ${{ secrets.TAP_TOKEN }}
```

The `version` is the only release value the caller needs to provide. The token is still required because the action pushes to a different repository. It needs contents write access to the tap. The action commits directly to the configured tap branch.

Defaults target `fopina/homebrew-tap` on `main`, updating `Formula/pbin.rb`. The formula class, filename, description, homepage, license, executable name, tap repository, and tap branch can be customized through the action inputs.
