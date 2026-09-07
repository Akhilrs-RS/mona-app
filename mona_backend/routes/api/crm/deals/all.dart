import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response(statusCode: 405);
  final conn = context.read<MySqlConnection>();
  final results = await conn.query('SELECT * FROM deals');
  final deals = results.map((row) => {
    'id': row['id'].toString(),
    'title': row['title'],
    'value': row['value'],
    'contact_id': row['contact_id'],
    'stage': row['stage'],
    'close_date': row['close_date'],
  }).toList();
  return Response.json(body: deals);
}
