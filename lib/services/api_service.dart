import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // 或其他后端服务地址

  // 获取患者信息
  Future<List<dynamic>> fetchPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patients');
    }
  }

  // 添加患者
  Future<void> addPatient(String name, String mobile) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'mobile': mobile}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add patient');
    }
  }

  // 获取就诊记录
  Future<List<dynamic>> fetchVisits(int patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$patientId/visits'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load visits');
    }
  }

  // 获取处方信息
  Future<List<dynamic>> fetchPrescriptions(int patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$patientId/prescriptions'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load prescriptions');
    }
  }
}
