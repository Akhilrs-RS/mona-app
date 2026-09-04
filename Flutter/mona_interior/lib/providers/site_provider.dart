import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/api/api_client.dart';
import 'package:mona_interior/models/site_models.dart';

class SitesNotifier extends AsyncNotifier<List<Site>> {
  @override
  Future<List<Site>> build() async {
    return _fetchData();
  }

  Future<List<Site>> _fetchData() async {
    final dio = ref.watch(dioProvider);
    try {
      final response = await dio.get('/sites');
      final data = (response.data as List<dynamic>?) ?? [];
      return data.map((json) => Site.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addSite(Site site) async {
    final dio = ref.read(dioProvider);
    await dio.post('/sites', data: site.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateSite(Site site) async {
    final dio = ref.read(dioProvider);
    await dio.put('/sites/${site.id}', data: site.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateSiteProperty(int id, String property, dynamic value) async {
    final currentSites = state.value ?? [];
    final site = currentSites.firstWhere((s) => s.id == id, orElse: () => throw Exception('Site not found'));
    
    final siteJson = site.toJson();
    siteJson[property] = value;
    final updatedSite = Site.fromJson(siteJson);
    
    await updateSite(updatedSite);
  }

  Future<void> deleteSite(int id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/sites/$id');
    ref.invalidateSelf();
  }
}

final sitesProvider = AsyncNotifierProvider<SitesNotifier, List<Site>>(() {
  return SitesNotifier();
});
