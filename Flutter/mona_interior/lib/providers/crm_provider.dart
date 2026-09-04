import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/api/api_client.dart';
import 'package:mona_interior/models/crm_models.dart';

class CrmState {
  final List<Contact> contacts;
  final List<Deal> deals;
  final List<Activity> activities;
  final List<Quotation> quotations;

  CrmState({
    required this.contacts,
    required this.deals,
    required this.activities,
    required this.quotations,
  });

  factory CrmState.empty() => CrmState(contacts: [], deals: [], activities: [], quotations: []);
}

class CrmNotifier extends AsyncNotifier<CrmState> {
  @override
  Future<CrmState> build() async {
    return _fetchData();
  }

  Future<CrmState> _fetchData() async {
    final dio = ref.watch(dioProvider);
    try {
      final responses = await Future.wait([
        dio.get('/crm/contacts'),
        dio.get('/crm/deals'),
        dio.get('/crm/activities'),
        dio.get('/quotations'),
      ]);

      final contactsList = (responses[0].data as List<dynamic>?) ?? [];
      final dealsList = (responses[1].data as List<dynamic>?) ?? [];
      final activitiesList = (responses[2].data as List<dynamic>?) ?? [];
      final quotesList = (responses[3].data as List<dynamic>?) ?? [];

      return CrmState(
        contacts: contactsList.map((c) => Contact.fromJson(c as Map<String, dynamic>)).toList(),
        deals: dealsList.map((d) => Deal.fromJson(d as Map<String, dynamic>)).toList(),
        activities: activitiesList.map((a) => Activity.fromJson(a as Map<String, dynamic>)).toList(),
        quotations: quotesList.map((q) => Quotation.fromJson(q as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return CrmState.empty();
    }
  }

  Future<void> addContact(Contact contact) async {
    final dio = ref.read(dioProvider);
    await dio.post('/crm', data: contact.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateContact(Contact contact) async {
    final dio = ref.read(dioProvider);
    await dio.put('/crm/${contact.id}', data: contact.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteContact(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/crm/$id');
    ref.invalidateSelf();
  }

  Future<void> addDeal(Deal deal) async {
    final dio = ref.read(dioProvider);
    await dio.post('/crm/deals', data: deal.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateDeal(Deal deal) async {
    final dio = ref.read(dioProvider);
    await dio.put('/crm/deals/${deal.id}', data: deal.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteDeal(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/crm/deals/$id');
    ref.invalidateSelf();
  }

  Future<void> addActivity(Activity activity) async {
    final dio = ref.read(dioProvider);
    await dio.post('/crm/activities', data: activity.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateActivity(Activity activity) async {
    final dio = ref.read(dioProvider);
    await dio.put('/crm/activities/${activity.id}', data: activity.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteActivity(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/crm/activities/$id');
    ref.invalidateSelf();
  }

  Future<void> addQuotation(Quotation quotation) async {
    final dio = ref.read(dioProvider);
    await dio.post('/quotations', data: quotation.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateQuotation(Quotation quotation) async {
    final dio = ref.read(dioProvider);
    await dio.put('/quotations/${quotation.id}', data: quotation.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteQuotation(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/quotations/$id');
    ref.invalidateSelf();
  }
}

final crmProvider = AsyncNotifierProvider<CrmNotifier, CrmState>(() {
  return CrmNotifier();
});
