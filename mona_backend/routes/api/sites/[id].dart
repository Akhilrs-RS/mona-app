import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final conn = context.read<MySqlConnection>();

  if (request.method == HttpMethod.put) {
    final body = await request.json() as Map<String, dynamic>;
    await conn.query(
      'UPDATE Sites SET Name=?, ClientName=?, OrganizationName=?, AssignedTeam=?, Address=?, Status=?, StartDate=?, Budget=?, Description=?, IsNegotiated=?, NegotiationDetails=?, IsArchived=?, WorkHistory=?, Maintenance=?, Media=? WHERE Id=?',
      [
        body['name'], body['clientName'], body['organizationName'], body['assignedTeam'],
        body['address'], body['status'], body['startDate'], body['budget'], body['description'],
        body['isNegotiated'] == true ? 1 : 0, body['negotiationDetails'], body['isArchived'] == true ? 1 : 0,
        jsonEncode(body['workHistory'] ?? []), jsonEncode(body['maintenance'] ?? {}), jsonEncode(body['media'] ?? []), id
      ]
    );
    return Response(statusCode: 200);
  } else if (request.method == HttpMethod.delete) {
    await conn.query('DELETE FROM Sites WHERE Id=?', [id]);
    return Response(statusCode: 200);
  }
  return Response(statusCode: 405);
}
