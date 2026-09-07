import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final conn = context.read<MySqlConnection>();

  if (request.method == HttpMethod.put) {
    final body = await request.json() as Map<String, dynamic>;
    await conn.query(
      'UPDATE contacts SET name=?, organizationName=?, phone=?, email=?, project=?, address=?, status=?, source=?, tags=?, date=? WHERE id=?',
      [
        body['name'], body['organizationName'], body['phone'], body['email'],
        body['project'], body['address'], body['status'], body['source'],
        jsonEncode(body['tags'] ?? []), body['date'],
        id
      ]
    );
    return Response(statusCode: 200);
  } else if (request.method == HttpMethod.delete) {
    await conn.query('DELETE FROM contacts WHERE id=?', [id]);
    return Response(statusCode: 200);
  }
  return Response(statusCode: 405);
}
