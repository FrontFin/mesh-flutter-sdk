/// Fatal errors that can occur inside Mesh SDK.
enum MeshErrorType {
  /// Error occurred while connecting to the Mesh Link.
  connectionError,

  /// User cancelled the operation (such as tapping the "Close" button).
  userCancelled,

  /// Navigation was blocked (for example, due to a domain whitelist check).
  blockedNavigation,

  /// An unknown error occurred.
  unknown,
}
