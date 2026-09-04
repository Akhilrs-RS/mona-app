import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    // Note: 10.0.2.2 is used to access localhost from an Android emulator.
    // For iOS simulator or real devices, use the specific IP address.
    baseUrl: 'http://10.0.2.2:5050/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Add authentication token if needed here
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      // Handle global errors here
      return handler.next(e);
    },
  ));

  return dio;
});
