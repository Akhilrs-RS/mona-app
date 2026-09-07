import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response(statusCode: 405);
  final conn = context.read<MySqlConnection>();
  final results = await conn.query('SELECT * FROM activities');
  final activities = results.map((row) => {
    'id': row['id'].toString(),
    'type': row['type'],
    'date': row['date'],
    'client': row['client'],
    'status': row['status'],
  }).toList();
  return Response.json(body: activities);
}
