import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboardpemilih.dart'; // pastikan ini sudah di-import

class LoginPemilihPage extends StatefulWidget {
  const LoginPemilihPage({Key? key}) : super(key: key);

  @override
  _LoginPemilihPageState createState() => _LoginPemilihPageState();
}

class _LoginPemilihPageState extends State<LoginPemilihPage> {
  final TextEditingController _idController = TextEditingController();

  // Fungsi untuk login
  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://10.243.219.88/VotingApp/loginpemilih.php'),
      body: {'id': _idController.text},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final String namaPemilih = data['nama']; // Ambil nama dari PHP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPemilihPage(namaPemilih: namaPemilih),
          ),
        );
      } else {
        _showErrorDialog('ID ini belum terdaftar, silahkan lakukan pendaftaran terlebih dahulu.');
      }
    } else {
      _showErrorDialog('Terjadi kesalahan pada server.');
    }
  }

  // Fungsi untuk menampilkan pop-up error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 79, 119, 138)),
        ),
        backgroundColor: const Color.fromARGB(255, 169, 204, 221),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ulangi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/signuppemilih');
            },
            child: const Text('Ya', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 79, 119, 138))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OSIS SMKN 1 Kota Bengkulu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 108, 140, 155),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 108, 140, 155)),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Admin', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/loginadmin'),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Pemilih', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/loginpemilih'),
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Sign Up Pemilih', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/signuppemilih'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: screenSize.width > 500 ? 500 : screenSize.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 165, 196, 212),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login Pemilih',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID Pemilih',
                  filled: true,
                  fillColor: Color.fromRGBO(228, 245, 250, 1),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(124, 156, 166, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
