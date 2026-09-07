import 'package:mysql1/mysql1.dart';

void main() async {
  final settings = ConnectionSettings(
    host: '127.0.0.1', 
    port: 3310,
    user: 'mona_user',
    password: 'StrongPassword123!',
    db: 'mona_interior'
  );
  
  try {
    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query('SELECT * FROM contacts');
    for (var row in results) {
      print('ID: \${row[0]}, Name: \${row[1]}, Org: \${row[2]}');
    }
    await conn.close();
  } catch (e) {
    print('Error: $e');
  }
}
