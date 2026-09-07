import 'package:mysql1/mysql1.dart';

void main() async {
  final settings = ConnectionSettings(
    host: '127.0.0.1', 
    port: 3310,
    user: 'mona_user',
    password: 'StrongPassword123!',
    db: 'mona_interior'
  );
  final conn = await MySqlConnection.connect(settings);
  final results = await conn.query('SELECT COUNT(*) FROM contacts');
  print('Count: \${results.first[0]}');
  await conn.close();
}
