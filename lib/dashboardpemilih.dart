import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginpemilih.dart';

import 'dart:convert';

class Calon {
  final String id;
  final String nomorPaslon;
  final String namaCalon;
  final String kelasCalon;
  final String jurusanCalon;
  final String jabatan;
  final String foto;

  Calon({
    required this.id,
    required this.nomorPaslon,
    required this.namaCalon,
    required this.kelasCalon,
    required this.jurusanCalon,
    required this.jabatan,
    required this.foto,
  });

  factory Calon.fromJson(Map<String, dynamic> json) {
    return Calon(
      id: json['id'],
      nomorPaslon: json['nomorpaslon'],
      namaCalon: json['namacalon'],
      kelasCalon: json['kelascalon'],
      jurusanCalon: json['jurusancalon'],
      jabatan: json['jabatan'],
      foto: json['potopaslon'] ?? '', // mencegah null
    );
  }
}

class DashboardPemilihPage extends StatefulWidget {
  final String namaPemilih;

  const DashboardPemilihPage({super.key, required this.namaPemilih});

  @override
  _DashboardPemilihPageState createState() => _DashboardPemilihPageState();
}


class _DashboardPemilihPageState extends State<DashboardPemilihPage> {
  List<Calon> _listCalon = [];
  String? _kandidatTerpilih;
  bool _isVoteSubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchCalon();
  }

  Future<void> _fetchCalon() async {
    final response = await http.get(Uri.parse('http://10.243.219.88/votingapp/get_calon.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("Data calon: $data");

      setState(() {
        _listCalon = data.map((item) => Calon.fromJson(item)).toList();
      });
    } else {
      throw Exception('Gagal mengambil data calon');
    }
  }

  void _pilihKandidat(String nomorKandidat) {
    if (!_isVoteSubmitted) {
      setState(() {
        _kandidatTerpilih = nomorKandidat;
      });
    }
  }

 Future<void> _submitVote(String nomorPaslon, String namaPemilih) async {
  print('Mengirim data ke server...');
  print('Nomor Paslon: $nomorPaslon');
  print('Nama Pemilih: $namaPemilih');

  final response = await http.post(
  Uri.parse('http://10.243.219.88/votingapp/insert_vote.php'),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'nomorpaslon': nomorPaslon,
    'namapemilih': namaPemilih,
  }),
);


  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  final result = jsonDecode(response.body);
  if (result['message'] == 'success') {
    setState(() {
      _isVoteSubmitted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suara Anda telah dikirim!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengirim suara')),
    );
  }
}

  void _konfirmasiSuara() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 40, 79, 97)),
          ),
          backgroundColor: const Color.fromARGB(255, 169, 204, 221),
          content: Text(
            'Anda akan memilih Paslon Nomor $_kandidatTerpilih. Apakah Anda yakin?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final calonTerpilih =
                    _listCalon.firstWhere((c) => c.nomorPaslon == _kandidatTerpilih);
_submitVote(calonTerpilih.namaCalon, widget.namaPemilih);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    int gridCount = screenWidth > 600 ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard OSIS SMKN 1 Kota Bengkulu',
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
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
  'Selamat datang, ${widget.namaPemilih}!',
  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 10),

                _listCalon.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada data calon',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: gridCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: _listCalon.map((calon) {
                          return CandidateCard(
                            candidateNumber: calon.nomorPaslon,
                            candidateImage: calon.foto.isEmpty
                                ? 'https://via.placeholder.com/150'
                                : 'http://localhost/votingapp/foto/${calon.foto}',
                            isSelected: _kandidatTerpilih == calon.nomorPaslon,
                            onTap: () => _pilihKandidat(calon.nomorPaslon),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor:
                        _isVoteSubmitted ? Colors.grey : const Color.fromARGB(255, 108, 140, 155),
                    elevation: 6,
                  ),
                  onPressed: _isVoteSubmitted || _kandidatTerpilih == null
                      ? null
                      : () => _konfirmasiSuara(),
                  child: const Text(
                    'Kirim Suara',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: const Color.fromARGB(255, 108, 140, 155),
                    elevation: 6,
                  ),
onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Logout'),
      content: const Text('Apakah Anda yakin ingin keluar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPemilihPage()),
              (_) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
},

                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final String candidateNumber;
  final String candidateImage;
  final bool isSelected;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.candidateNumber,
    required this.candidateImage,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isSelected ? const Color.fromARGB(255, 167, 214, 236) : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                candidateImage,
                height: screenWidth * 0.18,
                width: screenWidth * 0.18,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Paslon Nomor $candidateNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
