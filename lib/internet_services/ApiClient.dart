import 'package:dio/dio.dart';

class ApiClient{

  static var baseUrl = "http://62.72.3.200/api";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json
    )
  );


  Future login(String email, String password) async{
    try {
      Response response = await _dio.post("/login_driver_api",
      data: {
        'driver_email':"rahmat@gmail.com",
        'driver_password':password,
      },
     );
      return response.data;
    }on DioException catch (e){
      return e.response!.data;
    }
  }

  // Future<Response> logut() async{
  //
  // }
}