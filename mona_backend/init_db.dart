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
  
  await conn.query('''
    CREATE TABLE IF NOT EXISTS contacts (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255),
      organizationName VARCHAR(255),
      phone VARCHAR(255),
      email VARCHAR(255),
      project VARCHAR(255),
      address TEXT,
      status VARCHAR(50),
      source VARCHAR(50),
      tags JSON,
      date VARCHAR(50)
    )
  ''');

  await conn.query('''
    CREATE TABLE IF NOT EXISTS deals (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255),
      value DOUBLE,
      contact_id VARCHAR(255),
      stage VARCHAR(50),
      close_date VARCHAR(50)
    )
  ''');

  await conn.query('''
    CREATE TABLE IF NOT EXISTS activities (
      id INT AUTO_INCREMENT PRIMARY KEY,
      type VARCHAR(255),
      date VARCHAR(50),
      client VARCHAR(255),
      status VARCHAR(50)
    )
  ''');

  await conn.query('''
    CREATE TABLE IF NOT EXISTS quotations (
      id INT AUTO_INCREMENT PRIMARY KEY,
      quoteNo VARCHAR(255),
      clientName VARCHAR(255),
      projectTitle VARCHAR(255),
      total DOUBLE,
      status VARCHAR(50),
      date VARCHAR(50),
      items JSON
    )
  ''');

  try {
    await conn.query('INSERT INTO contacts (name, organizationName, phone, email, project, address, status, source, tags, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
      ['John Doe', 'Acme Corp', '1234567890', 'john@acme.com', 'Acme HQ', '123 Acme St', 'Active', 'Website', '["VIP", "New"]', '2026-09-07']
    );
  } catch (_) {}

  print('Database initialized with tables.');
  await conn.close();
}
