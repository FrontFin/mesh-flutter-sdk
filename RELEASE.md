# Release Flutter SDK

## ✨ With Claude Code (recommended)

1. Run `/bump-version` — bumps version according to [Semantic Versioning](https://semver.org/) and prepends a new entry to `CHANGELOG.md`.
2. Merge into `main`.
3. The release workflow starts automatically on merge to `main`. Optionally run [Release](https://github.com/FrontFin/mesh-flutter-sdk/actions/workflows/release.yaml) workflow manually.
4. Ensure the new version appears on [pub.dev](https://pub.dev/packages/mesh_sdk_flutter).

## ✍🏼️ Manually

1. Update `version` in [pubspec.yaml](./pubspec.yaml) according to [Semantic Versioning](https://semver.org/).
2. Add a new entry to `CHANGELOG.md`.
2. Merge into `main`.
3. The release workflow starts automatically on merge to `main`. Optionally run [Release](https://github.com/FrontFin/mesh-flutter-sdk/actions/workflows/release.yaml) workflow manually.
4. Ensure the new version appears on [pub.dev](https://pub.dev/packages/mesh_sdk_flutter).

> [!NOTE]
> Publication on pub.dev is usually available within a minute after the workflow finishes.