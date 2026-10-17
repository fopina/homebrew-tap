# Homebrew Tap Bump Action

This action updates a formula from a published GitHub release. It reads the release belonging to the calling repository, finds the macOS and Linux Intel and ARM64 archives, calculates their SHA256 checksums, and commits the updated formula to the tap.

The release archives must start with the executable name (default: `pbin`) and include an OS and architecture in their names. For example:

- `pbin_darwin_amd64.tar.gz`
- `pbin_darwin_arm64.tar.gz`
- `pbin_linux_amd64.tar.gz`
- `pbin_linux_arm64.tar.gz`

All four archives are required. If an asset is missing or more than one asset matches a platform, the action fails and prints the release asset names to help diagnose the mismatch.

## Usage

Run the action only after all four release archives have been uploaded. Where to place it and which tag expression to use depend on how the release starts.

### A workflow creates the release

If a workflow starts from a tag push and then builds and publishes the release, add the action after the release/publish step. Use `github.ref_name` for the tag:

```yaml
- name: Update Homebrew formula
  uses: fopina/homebrew-tap@bump-action
  with:
    version: ${{ github.ref_name }}
    token: ${{ secrets.TAP_TOKEN }}
```

### Creating a release triggers the workflow

If you create or publish a release manually and that event starts the workflow that builds and uploads its assets, add the action after the upload step. Use `github.event.release.tag_name`:

```yaml
- name: Update Homebrew formula
  uses: fopina/homebrew-tap@bump-action
  with:
    version: ${{ github.event.release.tag_name }}
    token: ${{ secrets.TAP_TOKEN }}
```

For either flow, if the upload happens in a separate job, put the bump action in a job that `needs` the upload job. This ordering prevents the action from querying the release before its archives exist.

The `version` is the only release value the caller needs to provide. The token is still required because the action writes to a different repository. This version commits directly to the configured tap branch; it does not open a pull request.

## Create the token

Create a fine-grained personal access token for the action:

1. Open [GitHub personal access tokens](https://github.com/settings/personal-access-tokens), then choose **Fine-grained tokens → Generate new token**.
2. Set **Resource owner** to `fopina`.
3. Under **Repository access**, choose **Only select repositories** and select `homebrew-tap`.
4. Under **Repository permissions**, set **Contents** to **Read and write**. Leave all other permissions at **No access**; GitHub grants **Metadata: Read-only** automatically.
5. Choose an expiration that fits your rotation policy, generate the token, and copy it. GitHub only shows the token once.
6. In the CLI repository (`fopina/privatebin`), open **Settings → Secrets and variables → Actions → New repository secret**. Name it `TAP_TOKEN` and paste the token value.

The workflow passes that secret as the action's `token` input. The source repository's `GITHUB_TOKEN` cannot write to the separate tap repository. Do not put the token directly in the workflow file.

If the action is changed to open a pull request instead of committing directly, also grant **Pull requests: Read and write** on `homebrew-tap`. The current action does not use that permission.

Defaults target `fopina/homebrew-tap` on `main`, updating `Formula/pbin.rb`. The formula class, filename, description, homepage, license, executable name, tap repository, and tap branch can be customized through the action inputs.
