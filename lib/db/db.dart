import 'package:mysql_client/mysql_client.dart';

class Db {
  static MySQLConnection? _conn;

  // *** 按你的实际数据库信息修改这里 ***
  static const _host = '100.99.37.48'; // li ru: 192.168.1.10
  static const _port = 3306;
  static const _user = 'mijiu';
  static const _pass = '242519';
  static const _db = 'his';

  // lan jia zai （懒加载）
  static Future<MySQLConnection> get connection async {
    if (_conn != null) return _conn!;
    _conn = await MySQLConnection.createConnection(
      host: _host,
      port: _port,
      userName: _user,
      password: _pass,
      databaseName: _db,
      // secure: true, // 如你的 MySQL 开启了 SSL，这里可以打开
    );
    await _conn!.connect();
    return _conn!;
  }

  // cha xun：返回 IResultSet（yong row.colByName('lie ming') 取值）
  static Future<IResultSet> query(
    String sql, [
    Map<String, dynamic>? params,
  ]) async {
    final conn = await connection;
    return await conn.execute(sql, params);
  }

  // xiu gai（INSERT/UPDATE/DELETE）：返回影响行数
  static Future<int> execute(String sql, [Map<String, dynamic>? params]) async {
    final conn = await connection;
    final res = await conn.execute(sql, params);
    return res.affectedRows.toInt();
  }
}
