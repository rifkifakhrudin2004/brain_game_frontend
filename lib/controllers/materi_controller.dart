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
  try {
    // Set loading state tanpa notifyListeners()
    _isLoading = true;
    _error = null;
    
    // Memanggil API
    final response = await ApiService().getMateri();
    
    if (response.isNotEmpty) {
      _materiList = response.map<Materi>((json) => Materi.fromJson(json)).toList();
    } else {
      _error = 'Tidak ada materi yang ditemukan';
    }
    
    _isLoading = false;
    // Panggil notifyListeners() sekali saja di akhir
    notifyListeners();
    
  } catch (e) {
    _isLoading = false;
    _error = 'Gagal memuat materi: $e';
    print("Error fetching materi: $e");
    notifyListeners();
  }
}
}
