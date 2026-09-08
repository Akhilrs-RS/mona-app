import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final conn = context.read<MySqlConnection>();

  if (request.method == HttpMethod.get) {
    final results = await conn.query('SELECT * FROM Sites');
    final sites = results.map((row) {
      return {
        'id': row['Id'],
        'name': row['Name']?.toString(),
        'clientName': row['ClientName']?.toString(),
        'organizationName': row['OrganizationName']?.toString(),
        'assignedTeam': row['AssignedTeam']?.toString(),
        'address': row['Address']?.toString(),
        'status': row['Status']?.toString(),
        'startDate': row['StartDate']?.toString(),
        'budget': row['Budget']?.toString(),
        'description': row['Description']?.toString(),
        'isNegotiated': row['IsNegotiated'] == 1,
        'negotiationDetails': row['NegotiationDetails']?.toString(),
        'isArchived': row['IsArchived'] == 1,
        'workHistory': jsonDecode(row['WorkHistory']?.toString() ?? '[]'),
        'maintenance': jsonDecode(row['Maintenance']?.toString() ?? '{}' ),
        'media': jsonDecode(row['Media']?.toString() ?? '[]'),
      };
    }).toList();
    return Response.json(body: sites);
  } else if (request.method == HttpMethod.post) {
    final body = await request.json() as Map<String, dynamic>;
    await conn.query(
      'INSERT INTO Sites (Name, ClientName, OrganizationName, AssignedTeam, Address, Status, StartDate, Budget, Description, IsNegotiated, NegotiationDetails, IsArchived, WorkHistory, Maintenance, Media) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        body['name'], body['clientName'], body['organizationName'], body['assignedTeam'],
        body['address'], body['status'], body['startDate'], body['budget'], body['description'],
        body['isNegotiated'] == true ? 1 : 0, body['negotiationDetails'], body['isArchived'] == true ? 1 : 0,
        jsonEncode(body['workHistory'] ?? []), jsonEncode(body['maintenance'] ?? {}), jsonEncode(body['media'] ?? [])
      ]
    );
    return Response(statusCode: 201);
  }
  return Response(statusCode: 405);
}
