import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_resa/controllers/materi_controller.dart';
import 'package:tugas_resa/services/auth_services.dart';
import 'login.dart';
import 'MateriDetail.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Remove the late Future<void> _materiFuture declaration

  @override
  void initState() {
    super.initState();
    // Move the fetchMateri call to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data after the widget is fully initialized
    // This is safer than using Provider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MateriController>(context, listen: false).fetchMateri();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().removeToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Future<void> _refreshMateri() async {
    await Provider.of<MateriController>(context, listen: false).fetchMateri();
    setState(() {}); // Trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Consumer<MateriController>(
        builder: (context, materiController, child) {
          // Use Consumer pattern for better provider integration
          
          // Menampilkan loading indicator ketika data sedang dimuat
          if (materiController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Menampilkan error jika ada masalah saat mengambil materi
          if (materiController.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Gagal memuat materi: ${materiController.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshMateri,
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Menampilkan pesan jika tidak ada materi
          if (materiController.materiList.isEmpty) {
            return Center(child: Text('Tidak ada materi tersedia'));
          }

          // Menampilkan list materi
          return RefreshIndicator(
            onRefresh: _refreshMateri,
            child: ListView.builder(
              itemCount: materiController.materiList.length,
              itemBuilder: (context, index) {
                final materi = materiController.materiList[index];
                return ListTile(
                  title: Text(materi.title),
                  onTap: () {
                    // Menavigasi ke halaman detail materi ketika judul materi ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MateriDetailScreen(materi: materi),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}