class AppResult<T> {
  const AppResult._({this.data, this.errorMessage});

  final T? data;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;

  static AppResult<T> success<T>(T data) {
    return AppResult<T>._(data: data);
  }

  static AppResult<T> failure<T>(String message) {
    return AppResult<T>._(errorMessage: message);
  }
}