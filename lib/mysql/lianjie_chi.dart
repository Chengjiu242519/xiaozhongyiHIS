import 'package:mysql_client/mysql_client.dart';

class LianJieChi {
  static MySQLConnectionPool? _chi;

  static Future<void> chushihua() async {
    _chi = MySQLConnectionPool(
      host: '100.99.37.48',
      port: 3306,
      userName: 'mijiu',
      password: '242519',
      databaseName: 'his',
      maxConnections: 6,
    );
  }

  static MySQLConnectionPool get chi {
    final c = _chi;
    if (c == null) throw StateError('MySQL lianjie chi wei chushihua');
    return c;
  }
}
