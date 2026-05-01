import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_mobil_bayeur/models/property_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:app_mobil_bayeur/services/property_service.dart';

final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiService = ApiService();
  return PropertyService(apiService);
});

final propertiesProvider = StateNotifierProvider<PropertiesNotifier, AsyncValue<List<Property>>>((ref) {
  return PropertiesNotifier(ref.watch(propertyServiceProvider));
});

class PropertiesNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final PropertyService _service;

  PropertiesNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchMyProperties();
  }

  Future<void> fetchMyProperties() async {
    state = const AsyncValue.loading();
    try {
      final properties = await _service.getProperties(filters: {'owner_id': 'my_id'}); // Backend logic handles my_id or similar
      state = AsyncValue.data(properties);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetchMyProperties();
  }

  Future<Property> createProperty(Map<String, dynamic> data) async {
    try {
      final property = await _service.createProperty(data);
      await refresh();
      return property;
    } catch (e) {
      rethrow;
    }
  }
}

final propertyDetailProvider = FutureProvider.family<Property, String>((ref, id) {
  return ref.watch(propertyServiceProvider).getPropertyById(id);
});
