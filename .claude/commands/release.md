---
name: release
description: >
  Run pre-flight checks and trigger the release workflow.
  Use this when you want to release the current version to pub.dev.
  Pre-conditions: version in pubspec.yaml must differ from the latest git tag,
  and CHANGELOG.md must have a matching entry.
---

Run pre-flight checks and trigger the release workflow.

## Steps

1. **Read the current version** from `pubspec.yaml`:
   ```bash
   grep '^version:' pubspec.yaml | awk '{print $2}'
   ```

2. **Get the latest git tag**:
   ```bash
   git tag --sort=-v:refname | head -n 1
   ```

3. **Check for a new version** — if the version matches the latest tag (e.g. `v1.1.2` matches
   `1.1.2`), stop and tell the user there is nothing to release.

4. **Validate the changelog** — check that `CHANGELOG.md` contains a `## {VERSION}` header
   (e.g. `## 1.2.0`). If it is missing, stop and tell the user to run `/bump-version` or add
   a changelog entry before releasing.

5. **Confirm with the user** before pushing the tag — show the version and ask:
   > Ready to release `v{VERSION}` to pub.dev. This will push a git tag and trigger the publish
   > workflow. Proceed?

   Do not continue unless the user confirms.

6. **Create and push the release tag** (the `publish.yml` workflow triggers on `v*.*.*` tags):
   ```bash
   git tag v{VERSION}
   git push origin v{VERSION}
   ```

7. **Get the workflow run** (wait 5 seconds for it to register, then fetch):
   ```bash
   gh run list --workflow=publish.yml --limit 1 --json databaseId,url
   ```

8. **Report** the run URL to the user and watch it:
   ```bash
   gh run watch <databaseId> --exit-status
   ```

9. On success, tell the user the release completed and show the GitHub Release URL:
   `https://github.com/FrontFin/mesh-flutter-sdk/releases/tag/v{VERSION}`

   On failure, tell the user which step failed and suggest checking the run logs at the URL
   from step 7.
