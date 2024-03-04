# Get Image Layer Size Difference

This GitHub Action compares Docker image layer sizes between two releases to determine pull size differences effortlessly.

## Inputs

- `REPO_LIST`: (Required) A list of repositories to compare.
- `LAST_RELEASE`: (Required) The last release to compare.
- `NEW_RELEASE`: (Required) The new release to compare.

## Example Usage

```yaml
uses: ftasbasi/docker-image-size-diff@<tag>
with:
  REPO_LIST: 'repository1 repository2'
  LAST_RELEASE: 'v1.0'
  NEW_RELEASE: 'v1.1'
