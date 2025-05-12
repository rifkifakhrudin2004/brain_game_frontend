import 'dart:convert';
import 'package:http/http.dart' as http;  
import 'package:tugas_resa/services/auth_services.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.5:8000/api'; // URL API
  final AuthService _authService = AuthService(); // Instance AuthService

  // Fungsi untuk mendapatkan semua materi
  Future<List<dynamic>> getMateri() async {
    try {
      // Dapatkan token dari AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silahkan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/materi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Response materi success: ${response.body}'); // Debugging
        return json.decode(response.body);
      } else {
        print('Response materi error: ${response.statusCode}, ${response.body}'); // Debugging
        throw Exception('Gagal memuat materi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getMateri: $e'); // Debugging
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan soal berdasarkan materi
  Future<List<dynamic>> getQuestions(int materiId) async {
    try {
      // Dapatkan token dari AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silahkan login kembali.');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$materiId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Response questions success: ${response.body}'); // Debugging
        return json.decode(response.body);
      } else {
        print('Response questions error: ${response.statusCode}, ${response.body}'); // Debugging
        throw Exception('Gagal memuat soal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getQuestions: $e'); // Debugging
      rethrow;
    }
  }
}