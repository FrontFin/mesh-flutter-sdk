/// Mesh environment a session token belongs to.
///
/// Only needed by `MeshConfiguration.session`, the entry point for clients that
/// mint a session directly (`POST /v2/sessions`) and receive a bare session
/// token rather than a link token. A link token already carries its own host,
/// so the default `MeshConfiguration` constructor never needs this.
///
/// Names match the web SDK's `LinkEnvironment`. Its `local` value is
/// deliberately absent: it points at `localhost`, which on a device is the
/// device itself, and plain `http` is not allowlisted. Test against a local
/// Link through a LocalCan tunnel instead (`*.localcan.dev` is allowlisted).
///
/// These URLs are compiled into the SDK, so a host change needs a new SDK
/// release and clients updating. If that becomes a problem, resolve them from
/// remote config instead of this enum.
enum MeshLinkEnvironment {
  prod('https://link.meshpay.com'),
  sbx('https://link.sbx.meshpay.com'),
  dev('https://link.dev.meshpay.com');

  const MeshLinkEnvironment(this.linkUrl);

  /// Base URL of the Link UI for this environment.
  final String linkUrl;
}
