import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataPemilihPage extends StatefulWidget {
  const DataPemilihPage({Key? key}) : super(key: key);

  @override
  _DataPemilihPageState createState() => _DataPemilihPageState();
}

class _DataPemilihPageState extends State<DataPemilihPage> {
  List _pemilihList = [];
  List _filteredPemilihList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPemilihData();
    _searchController.addListener(_filterPemilih);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPemilihData() async {
    final response =
        await http.get(Uri.parse('http://10.243.219.88/VotingApp/get_pemilih.php'));

    if (response.statusCode == 200) {
      setState(() {
        _pemilihList = json.decode(response.body);
        _filteredPemilihList =
            _pemilihList; // Inisialisasi daftar yang difilter
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data')),
      );
    }
  }

  void _filterPemilih() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPemilihList = _pemilihList.where((pemilih) {
        final id = pemilih['id'].toString(); // Mengambil ID sebagai string
        final nama = pemilih['nama'].toLowerCase();
        final kelas = pemilih['kelas'].toLowerCase();
        final jurusan = pemilih['jurusan'].toLowerCase();
        final gender = pemilih['gender'].toLowerCase();

        // Mencari berdasarkan ID, nama, kelas, jurusan, atau gender
        return id.contains(query) ||
            nama.contains(query) ||
            kelas.contains(query) ||
            jurusan.contains(query) ||
            gender.contains(query);
      }).toList();
    });
  }

  Future<void> _addPemilih() async {
    await showDialog(
      context: context,
      builder: (context) => PemilihForm(
        onSubmit: (nama, gender, kelas, jurusan) async {
          final response = await http.post(
            Uri.parse('http://10.243.219.88/VotingApp/add_pemilih.php'),
            body: {
              'nama': nama,
              'gender': gender,
              'kelas': kelas,
              'jurusan': jurusan,
            },
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            if (responseData['status'] == 'success') {
              final pemilihData = {
                'id': responseData['id'],
                'nama': nama,
                'kelas': kelas,
                'jurusan': jurusan,
                'gender': gender,
              };

              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Pendaftaran Berhasil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Data berhasil dimasukkan ke dalam database:'),
                      const SizedBox(height: 10),
                      Text('ID: ${pemilihData['id']}'),
                      Text('Nama: ${pemilihData['nama']}'),
                      Text('Kelas: ${pemilihData['kelas']}'),
                      Text('Jurusan: ${pemilihData['jurusan']}'),
                      Text('Gender: ${pemilihData['gender']}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              Navigator.of(context).pop();
              _fetchPemilihData();
            }
          } else {
            // Handle error
          }
        },
      ),
    );
  }

  Future<void> _editPemilih(Map pemilih) async {
    await showDialog(
      context: context,
      builder: (context) => PemilihForm(
        pemilih: pemilih,
        onSubmit: (nama, gender, kelas, jurusan) async {
          final response = await http.post(
            Uri.parse('http://10.243.219.88/VotingApp/update_pemilih.php'),
            body: {
              'id': pemilih['id'].toString(),
              'nama': nama,
              'gender': gender,
              'kelas': kelas,
              'jurusan': jurusan,
            },
          );

          if (response.statusCode == 200) {
            Navigator.of(context).pop();
            _fetchPemilihData();
          } else {
            // Handle error
          }
        },
      ),
    );
  }

  Future<void> _deletePemilih(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(
            255, 169, 204, 221), // Sesuaikan dengan warna dashboard
        title: const Text(
          'Data Akan Dihapus',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 40, 79, 97)),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: const Text('Batal',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255))),
            onPressed: () {
              Navigator.of(context).pop(false); // Pengguna menekan batal
            },
          ),
          ElevatedButton(
            child: const Text('Ya',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 79, 119, 138))),
            onPressed: () {
              Navigator.of(context).pop(true); // Pengguna menekan ya
            },
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.post(
        Uri.parse('http://10.243.219.88/VotingApp/delete_pemilih.php'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        _fetchPemilihData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text(
                'Profile Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, '/profileadmin'); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text(
                'Data Pemilih',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, '/datapemilih'); 
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPemilihData,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search ',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Color.fromRGBO(209, 238, 247, 1),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPemilihList.length,
                  itemBuilder: (context, index) {
                    final pemilih = _filteredPemilihList[index];
                    return Card(
                        color: const Color.fromRGBO(228, 245, 250, 1),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(pemilih['nama']),
                          subtitle: Text(
                            'ID: ${pemilih['id']}, Kelas: ${pemilih['kelas']}, Jurusan: ${pemilih['jurusan']}, Gender: ${pemilih['gender']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color.fromARGB(255, 21, 119, 205)),
                                onPressed: () => _editPemilih(pemilih),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color.fromARGB(255, 205, 21, 21)),
                                onPressed: () =>
                                    _deletePemilih(int.parse(pemilih['id'])),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPemilih,
        backgroundColor: const Color.fromARGB(255, 108, 140, 155),
        child: const Icon(
          Icons.add, // Ikon tambah
          color: Colors.white, // Warna ikon
        ),
      ),
    );
  }
}

class PemilihForm extends StatefulWidget {
  final Map? pemilih;
  final Function(String, String, String, String) onSubmit;

  const PemilihForm({Key? key, this.pemilih, required this.onSubmit})
      : super(key: key);

  @override
  _PemilihFormState createState() => _PemilihFormState();
}

class _PemilihFormState extends State<PemilihForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _kelasController;
  late TextEditingController _jurusanController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.pemilih?['nama'] ?? '');
    _kelasController =
        TextEditingController(text: widget.pemilih?['kelas'] ?? '');
    _jurusanController =
        TextEditingController(text: widget.pemilih?['jurusan'] ?? '');
    _selectedGender = widget.pemilih?['gender'];
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pemilih == null ? 'Tambah Pemilih' : 'Edit Pemilih',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 108, 140, 155),
      ),
      body: Center(
        child: Container(
          width:
              screenWidth > 600 ? 500 : screenWidth * 0.9, // Responsive width
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 165, 196, 212), // Warna sesuai dashboard
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.pemilih == null ? 'Tambah Pemilih' : 'Edit Pemilih',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Harus diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _kelasController,
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Harus diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _jurusanController,
                    decoration: const InputDecoration(
                      labelText: 'Jurusan',
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Harus diisi' : null,
                  ),
                  const SizedBox(height: 10),
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
                      fillColor: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          _namaController.text,
                          _selectedGender ?? '',
                          _kelasController.text,
                          _jurusanController.text,
                        );
                      }
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(74, 105, 130, 1)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(255, 255, 255, 1))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
