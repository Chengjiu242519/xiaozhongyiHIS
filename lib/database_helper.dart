import 'package:mysql1/mysql1.dart';

// 配置数据库连接信息
Future<MySqlConnection> createConnection() async {
  final conn = await MySqlConnection.connect(
    ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'mijiu', // 你的数据库用户名
      db: 'clinic_system',
      password: '242519', // 你的数据库密码
    ),
  );
  return conn;
}

// 获取所有患者信息
Future<List<Map<String, dynamic>>> getPatients() async {
  final conn = await createConnection();
  var results = await conn.query('SELECT * FROM patients');
  List<Map<String, dynamic>> patients = [];
  for (var row in results) {
    patients.add({'id': row[0], 'name': row[1], 'mobile': row[2]});
  }
  await conn.close();
  return patients;
}

// 插入一名患者
Future<void> addPatient(String name, String mobile) async {
  final conn = await createConnection();
  await conn.query('INSERT INTO patients (name, mobile) VALUES (?, ?)', [
    name,
    mobile,
  ]);
  print('Inserted patient: $name');
  await conn.close();
}

// 获取所有就诊记录
Future<List<Map<String, dynamic>>> getVisits(int patientId) async {
  final conn = await createConnection();
  var results = await conn.query('SELECT * FROM visits WHERE patient_id = ?', [
    patientId,
  ]);
  List<Map<String, dynamic>> visits = [];
  for (var row in results) {
    visits.add({
      'id': row[0],
      'chief_complaint': row[2],
      'diagnosis': row[3],
      'doctor': row[4],
      'visit_time': row[5],
    });
  }
  await conn.close();
  return visits;
}

// 获取所有处方记录
Future<List<Map<String, dynamic>>> getPrescriptions(int patientId) async {
  final conn = await createConnection();
  var results = await conn.query(
    'SELECT * FROM prescriptions WHERE patient_id = ?',
    [patientId],
  );
  List<Map<String, dynamic>> prescriptions = [];
  for (var row in results) {
    prescriptions.add({
      'id': row[0],
      'patient_id': row[1],
      'type': row[2],
      'created_at': row[3],
    });
  }
  await conn.close();
  return prescriptions;
}

// 获取所有理疗项目记录
Future<List<Map<String, dynamic>>> getTherapies() async {
  final conn = await createConnection();
  var results = await conn.query('SELECT * FROM therapies');
  List<Map<String, dynamic>> therapies = [];
  for (var row in results) {
    therapies.add({'id': row[0], 'name': row[1], 'price': row[2]});
  }
  await conn.close();
  return therapies;
}

// 获取药品库存信息
Future<List<Map<String, dynamic>>> getInventory() async {
  final conn = await createConnection();
  var results = await conn.query('SELECT * FROM drugs'); // 假设 drug 表包含药品信息
  List<Map<String, dynamic>> inventory = [];
  for (var row in results) {
    inventory.add({'id': row[0], 'name': row[1], 'stock': row[2]});
  }
  await conn.close();
  return inventory;
}

// 获取套餐信息
Future<List<Map<String, dynamic>>> getPackages() async {
  final conn = await createConnection();
  var results = await conn.query(
    'SELECT * FROM packages',
  ); // 假设 package 表包含套餐信息
  List<Map<String, dynamic>> packages = [];
  for (var row in results) {
    packages.add({'id': row[0], 'name': row[1], 'price': row[2]});
  }
  await conn.close();
  return packages;
}
