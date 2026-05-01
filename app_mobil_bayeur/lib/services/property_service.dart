import 'dart:io';
import 'package:dio/dio.dart';
import 'package:app_mobil_bayeur/models/property_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class PropertyService {
  final ApiService _apiService;

  PropertyService(this._apiService);

  Future<List<Property>> getProperties({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.dio.get('/properties', queryParameters: filters);
      return (response.data as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Property> createProperty(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post('/properties', data: data);
      return Property.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPropertyImages(String propertyId, List<File> images) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (var file in images) {
        multipartFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ));
      }

      FormData formData = FormData.fromMap({
        'images': multipartFiles,
      });

      await _apiService.dio.post(
        '/properties/$propertyId/images',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadVerificationDocument(String propertyId, File document) async {
    try {
      FormData formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      });

      await _apiService.dio.post(
        '/properties/$propertyId/verify-doc',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Property> getPropertyById(String id) async {
    try {
      final response = await _apiService.dio.get('/properties/$id');
      return Property.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Property> updateProperty(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put('/properties/$id', data: data);
      return Property.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _apiService.dio.delete('/properties/$id');
    } catch (e) {
      rethrow;
    }
  }
}
