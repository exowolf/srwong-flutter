
import 'package:flutter/material.dart';
import 'package:flutter_pdg/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_pdg/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_pdg/data/model/response/base/api_response.dart';
import 'package:flutter_pdg/utill/app_constants.dart';

class NewsLetterRepo {
  final DioClient dioClient;

  NewsLetterRepo({@required this.dioClient});

  Future<ApiResponse> addToNewsLetter(String  email) async {
    try {
      final response = await dioClient.post(AppConstants.EMAIL_SUBSCRIBE_URI, data: {'email':email});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}
