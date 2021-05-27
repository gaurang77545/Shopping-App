class HttpException implements Exception {//Gonna implement the methods of Exception
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;//Whenever we call this class toSString will be called
    // return super.toString(); // Instance of HttpException
  }
}