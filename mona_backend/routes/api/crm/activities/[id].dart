import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final conn = context.read<MySqlConnection>();

  if (request.method == HttpMethod.put) {
    final body = await request.json() as Map<String, dynamic>;
    await conn.query(
      'UPDATE activities SET type=?, date=?, client=?, status=? WHERE id=?',
      [body['type'], body['date'], body['client'], body['status'], id]
    );
    return Response(statusCode: 200);
  } else if (request.method == HttpMethod.delete) {
    await conn.query('DELETE FROM activities WHERE id=?', [id]);
    return Response(statusCode: 200);
  }
  return Response(statusCode: 405);
}
