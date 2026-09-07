import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response(statusCode: 405);
  final conn = context.read<MySqlConnection>();
  final results = await conn.query('SELECT * FROM quotations');
  final quotations = results.map((row) => {
    'id': row['id'].toString(),
    'quoteNo': row['quoteNo'],
    'clientName': row['clientName'],
    'projectTitle': row['projectTitle'],
    'total': row['total'],
    'status': row['status'],
    'date': row['date'],
    'items': row['items'] != null ? jsonDecode(row['items']) : [],
  }).toList();
  return Response.json(body: quotations);
}
