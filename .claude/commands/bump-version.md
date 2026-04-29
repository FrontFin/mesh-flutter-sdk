---
name: bump-version
description: >
  Bumps the mesh-flutter-sdk version using semantic versioning, then updates CHANGELOG.md.
  Use this skill whenever the user asks to bump the version, release a new version, update
  the version number, prepare a release, or update the changelog. Also trigger when the user
  says things like "we're ready to release" or "what version should this be?".

  Steps: diff HEAD against the latest git tag → classify changes as MAJOR/MINOR/PATCH →
  increment the version in pubspec.yaml → prepend a new entry to CHANGELOG.md.
---

## bump-version skill

### Step 1 — Sync with remote, find the latest tag, and build the diff

First, fetch the latest commits and all tags from origin so the diff reflects the true
published state rather than a stale local snapshot:

```bash
git fetch origin main --tags
```

Then find the latest tag:

```bash
git describe --tags --abbrev=0
```

If no tags exist, treat the full history as the diff (use `git log --oneline` for context) and
assume the current version in `pubspec.yaml` is the starting point.

```bash
git diff <latest-tag>..HEAD --stat
git diff <latest-tag>..HEAD -- \
  'lib/mesh_sdk_flutter.dart' \
  'lib/src/mesh_sdk_flutter.dart' \
  'lib/src/model/' \
  'lib/src/ui/' \
  'lib/src/util/'
```

Also capture the commit log for the changelog summary:

```bash
git log <latest-tag>..HEAD --oneline
```

---

### Step 2 — Classify the bump

Analyse the diff output against these rules (apply the highest matching level):

#### MAJOR — any of:
- A public class, sealed class, or `enum` in `lib/src/model/` is **deleted or renamed**
- A field is **removed** from a public model class (e.g. `MeshConfiguration`, `MeshResult`
  subtypes, `IntegrationConnectedPayload`, `TransferFinishedPayload`, `AccountToken`)
- A callback signature in `MeshConfiguration` is changed in a breaking way
- The JS bridge channel name or any message type passed between the WebView and Dart is changed
  in a way that breaks existing integrations
- A method in the public `MeshSdk` API (`lib/mesh_sdk_flutter.dart`) is removed or renamed

#### MINOR — any of (and no MAJOR):
- A **new field** is added to `MeshConfiguration`, any `MeshResult` subtype, or another public
  model class
- A **new sealed subtype** is added to `MeshResult`, `MeshEvent`, or `SuccessPayload`
- A **new public callback** is added to `MeshConfiguration`
- A **new enum value** is added to any public enum (e.g. `MeshTheme`, `Language`)
- A **new entry** is added to the domain whitelist or externally-opened origins
- `MeshSdk.show()` gains new optional parameters

#### PATCH — everything else:
- Bug fixes, internal refactors, test additions or changes
- README, CHANGELOG, or `CLAUDE.md` edits
- Dependency version bumps that don't affect the public API
- New or changed private/internal functions
- Changes confined to `example/`, `test/`, or `lib/src/util/` internals
- Localization string changes or new locale additions

When in doubt between MINOR and PATCH, prefer MINOR. When in doubt between MAJOR and MINOR,
**ask the user** before proceeding — a wrong MAJOR bump is hard to undo after publishing.

---

### Step 3 — Read and bump the version

Read the current version:

```bash
grep '^version:' pubspec.yaml
```

The line looks like:
```
version: 1.1.2
```

Apply the bump:
- **MAJOR**: increment first number, reset others to 0  →  `1.1.2` → `2.0.0`
- **MINOR**: increment second number, reset third to 0  →  `1.1.2` → `1.2.0`
- **PATCH**: increment third number                     →  `1.1.2` → `1.1.3`

Write the new version back using Edit — change only the `version:` line, nothing else.

---

### Step 4 — Update CHANGELOG.md

Read `CHANGELOG.md`.

Prepend a new section at the very top (above any existing content):

```markdown
## X.Y.Z

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...
```

Rules for the summary:
- Do **not** include a date — use only the version number: `## X.Y.Z`.
- **Always** include at least one `### Added` / `### Changed` / `### Fixed` / `### Removed`
  sub-heading — never write bare bullets directly under a version heading. Omit section
  headings that have no items, but every version block must have at least one.
- Keep each bullet to one line — describe **what changed and why it matters** to a consumer of
  the SDK, not internal implementation details. Examples:
  - ✅ `Added \`theme\` parameter to \`MeshConfiguration\` for light/dark/system UI theming`
  - ❌ `Modified MeshLinkController to pass theme query param to WebView URL`
- Changes in `example/`, tests, `CLAUDE.md`, and `README.md` go under **Changed** only if they
  affect the developer experience; skip purely internal ones.

---

### Step 5 — Report to the user

After writing the files, summarise:

```
Bumped version: 1.1.2 → 1.2.0  (MINOR)

Reason: new `displayFiatCurrency` field added to MeshConfiguration,
        new Language enum values added.

Files updated:
  • pubspec.yaml   (version field)
  • CHANGELOG.md   (new entry prepended)
```

Then ask the user:

> Would you like me to commit these changes?

If they say yes, stage only the two modified files and create a commit:

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to X.Y.Z"
```

If they say no, leave the files as-is.
