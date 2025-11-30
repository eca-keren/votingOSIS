import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPemilihPage extends StatefulWidget {
  const SignUpPemilihPage({super.key});

  @override
  _SignUpPemilihPageState createState() => _SignUpPemilihPageState();
}

class _SignUpPemilihPageState extends State<SignUpPemilihPage> {
  final TextEditingController _namaController = TextEditingController();
  String? _selectedKelas;
  String? _selectedJurusan;
  String? _selectedGender;

  Future<void> _signUpPemilih() async {
    final String nama = _namaController.text;
    final String? kelas = _selectedKelas;
    final String? jurusan = _selectedJurusan;
    final String? gender = _selectedGender;

    if (nama.isEmpty || gender == null || kelas == null || jurusan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    const String url = 'http://10.243.219.88/VotingApp/signuppemilih.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'Nama': nama,
          'Gender': gender,
          'Kelas': kelas,
          'Jurusan': jurusan,
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pendaftaran berhasil")),
        );
        _namaController.clear();
        setState(() {
          _selectedGender = null;
          _selectedKelas = null;
          _selectedJurusan = null;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Pendaftaran Berhasil"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Id: ${data['id']}"),
                  Text("Nama: $nama"),
                  Text("Kelas: $kelas"),
                  Text("Jurusan: $jurusan"),
                  Text("Gender: $gender"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OSIS SMKN 1 Kota Bengkulu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 108, 140, 155),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 108, 140, 155),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Admin',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/loginadmin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Pemilih',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/loginpemilih');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Sign Up Pemilih',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/signuppemilih');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: screenSize.width > 500
              ? 500
              : screenSize.width * 0.9, // Responsive width
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 165, 196, 212),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sign Up Pemilih',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  filled: true,
                  fillColor: Color.fromRGBO(228, 245, 250, 1),
                ),
              ),
              const SizedBox(height: 10),
              // Kelas
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                items: const [
                  DropdownMenuItem(
                    value: '10',
                    child: Text('10'),
                  ),
                  DropdownMenuItem(
                    value: '11',
                    child: Text('11'),
                  ),
                  DropdownMenuItem(
                    value: '12',
                    child: Text('12'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKelas = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  filled: true,
                  fillColor: Color.fromRGBO(228, 245, 250, 1),
                ),
              ),
              const SizedBox(height: 10),
              // Jurusan
              DropdownButtonFormField<String>(
                value: _selectedJurusan,
                items: const [
                  DropdownMenuItem(
                    value: 'AM',
                    child: Text('AM'),
                  ),
                  DropdownMenuItem(
                    value: 'PM',
                    child: Text('PM'),
                  ),
                  DropdownMenuItem(
                    value: 'AKL',
                    child: Text('AKL'),
                  ),
                  DropdownMenuItem(
                    value: 'DKV',
                    child: Text('DKV'),
                  ),
                  DropdownMenuItem(
                    value: 'ULP',
                    child: Text('ULP'),
                  ),
                  DropdownMenuItem(
                    value: 'MPLB',
                    child: Text('MPLB'),
                  ),
                  DropdownMenuItem(
                    value: 'PPLG',
                    child: Text('PPLG'),
                  ),
                  DropdownMenuItem(
                    value: 'TJKT',
                    child: Text('TJKT'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedJurusan = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  filled: true,
                  fillColor: Color.fromRGBO(228, 245, 250, 1),
                ),
              ),
              const SizedBox(height: 10),
              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(
                    value: 'Pria',
                    child: Text('Pria'),
                  ),
                  DropdownMenuItem(
                    value: 'Wanita',
                    child: Text('Wanita'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: Color.fromRGBO(228, 245, 250, 1),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUpPemilih,
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(124, 156, 166, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
