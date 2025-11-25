/// Fatal errors that can occur inside Mesh SDK.
enum MeshErrorType {
  /// Error occurred while connecting to the Mesh Link.
  connectionError,

  /// User cancelled the operation (such as tapping the "Close" button).
  userCancelled,

  /// An unknown error occurred.
  unknown,
}
