import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qubeez/model/auth/LoginResponse.dart';
import 'package:qubeez/model/auth/SignUpResponse.dart';
import 'package:qubeez/model/auth/verify_otp_response.dart';
import 'package:qubeez/utils/constant.dart';

class ApiProvider{
  final Dio _dioClient = Dio(BaseOptions(
      baseUrl: Constants.TESTING_URL,
      headers: {
        'Appversion': '1.0',
        'Ostype': Platform.isAndroid ? 'ANDRIOD' : 'ios'
      }));

  Future<SignUpResponse> signUp(String name, String email,
      String phone, String password, String deviceToken) async {

    final map = {
      "name": name,
      "email": email,
      "mobile": phone,
      "password": password,
      "user_type": Constants.USER_TYPE,
      "country_code": "+91",
      "device_token": deviceToken
    };

    FormData data = FormData.fromMap(map);
    print("register -> $map");
    try {
      Response response = await _dioClient.post('register', data: data);
      dynamic json = jsonDecode(response.toString());
      print(response.data);
      if (response.data != "") {
        print("dataValue :- ${json['status']}");
        if (json['status'] == true)
          return SignUpResponse.fromJson(json);
        else
          return SignUpResponse.fromError(json['message'], response.statusCode);
      } else {
        return SignUpResponse.fromError("No data", 396);
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      var e = error;
      if (error is DioError) {
        e = getErrorMsg(e.type);
      }
      return SignUpResponse.fromError("$e", 397);
    }
  }

  Future<LoginResponse> login(String userCred, String password) async {
    final map = {
      "userid": userCred,
      "password": password,
    };
    try {
      Response response = await _dioClient.post('login', data: map);
      dynamic json = jsonDecode(response.toString());
      print(response.data);
      if (response.data != "") {
        print("dataValue :- ${json['status']}");
        if (json['status'] == true)
          return LoginResponse.fromJson(json);
        else
          return LoginResponse.fromError(
              json['message']/*,
            response.data['error_code'],*/
          );
      } else {
        return LoginResponse.fromError("No data"/*, 396*/);
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      var e = error;
      if (error is DioError) {
        e = getErrorMsg(e.type);
      }
      return LoginResponse.fromError("$e"/*, 397*/);
    }
  }

  Future<VerifyOtpResponse> verifyOtp(String userCred, String otp) async {
    final map = {
      "userid": userCred,
      "otp": otp,
    };
    try {
      Response response = await _dioClient.post('VerifyOtp', data: map);
      dynamic json = jsonDecode(response.toString());
      print(response.data);
      if (response.data != "") {
        print("dataValue :- ${json['status']}");
        if (json['status'] == true)
          return VerifyOtpResponse.fromJson(json);
        else
          return VerifyOtpResponse.fromError(
              json['message'],
            response.data['error_code'],
          );
      } else {
        return VerifyOtpResponse.fromError("No data", 396);
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      var e = error;
      if (error is DioError) {
        e = getErrorMsg(e.type);
      }
      return VerifyOtpResponse.fromError("$e", 397);
    }
  }

  String getErrorMsg(DioErrorType type) {
    switch (type) {
      case DioErrorType.CONNECT_TIMEOUT:
        return "Connection timeout";
        break;
      case DioErrorType.SEND_TIMEOUT:
        return "Send timeout";
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        return "Receive timeout";
        break;
      case DioErrorType.RESPONSE:
        return "Response timeout";
        break;
      case DioErrorType.CANCEL:
        return "Request has been cancelled";
        break;
      case DioErrorType.DEFAULT:
        return "Could not connect";
        break;
      default:
        return "Something went wrong";
        break;
    }
  }
}