import 'package:flutter/material.dart';
import '../models/materi.dart';
import '../services/api_services.dart';

class MateriController with ChangeNotifier {
  List<Materi> _materiList = [];
  bool _isLoading = false;
  String? _error;

  List<Materi> get materiList => _materiList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMateri() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Update status loading duluan

    try {
      final response = await ApiService().getMateri();

      if (response.isNotEmpty) {
        _materiList = response.map<Materi>((json) => Materi.fromJson(json)).toList();
      } else {
        _error = 'Tidak ada materi yang ditemukan';
      }
    } catch (e) {
      _error = 'Gagal memuat materi: $e';
      print("Error fetching materi: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Update status akhir
    }
  }
}
