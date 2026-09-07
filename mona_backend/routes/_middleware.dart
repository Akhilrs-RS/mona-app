import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

final settings = ConnectionSettings(
  host: '127.0.0.1', 
  port: 3310,
  user: 'mona_user',
  password: 'StrongPassword123!',
  db: 'mona_interior'
);

MySqlConnection? _connection;

Future<MySqlConnection> getConnection() async {
  if (_connection == null) {
    _connection = await MySqlConnection.connect(settings);
  } else {
    try {
      await _connection!.query('SELECT 1');
    } catch (e) {
      _connection = await MySqlConnection.connect(settings);
    }
  }
  return _connection!;
}

Handler middleware(Handler handler) {
  return (context) async {
    // Handle CORS preflight
    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 204,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        },
      );
    }

    final connection = await getConnection();
    final response = await handler.use(provider<MySqlConnection>((_) => connection)).call(context);
    
    // Add CORS headers to all responses
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      },
    );
  };
}
