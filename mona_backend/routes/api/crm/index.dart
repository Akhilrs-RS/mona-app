import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final conn = context.read<MySqlConnection>();

  if (request.method == HttpMethod.get) {
    final results = await conn.query('SELECT * FROM contacts');
    final contacts = results.map((row) {
      final tagsData = row['tags']?.toString();
      List<dynamic> parsedTags = [];
      if (tagsData != null && tagsData.isNotEmpty) {
        try {
          parsedTags = jsonDecode(tagsData);
        } catch (_) {}
      }
      return {
        'id': row['id'].toString(),
        'name': row['name']?.toString(),
        'organizationName': row['organizationName']?.toString(),
        'phone': row['phone']?.toString(),
        'email': row['email']?.toString(),
        'project': row['project']?.toString(),
        'address': row['address']?.toString(),
        'status': row['status']?.toString(),
        'source': row['source']?.toString(),
        'tags': parsedTags,
        'date': row['date']?.toString(),
      };
    }).toList();
    return Response.json(body: contacts);
  } else if (request.method == HttpMethod.post) {
    final body = await request.json() as Map<String, dynamic>;
    final result = await conn.query(
      'INSERT INTO contacts (name, organizationName, phone, email, project, address, status, source, tags, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        body['name'], body['organizationName'], body['phone'], body['email'],
        body['project'], body['address'], body['status'], body['source'],
        jsonEncode(body['tags'] ?? []), body['date']
      ]
    );
    return Response.json(body: {'id': result.insertId.toString()});
  }
  return Response(statusCode: 405);
}
