import 'package:aplikasikeempat/profileadmin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loginadmin.dart';
import 'signuppemilih.dart';
import 'dashboard.dart';
import 'loginpemilih.dart';
import 'datapemilih.dart';
import 'dart:ui';

void main() {
  runApp(const OSISApp());
}

class OSISApp extends StatelessWidget {
  const OSISApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSIS SMKN 1 Kota Bengkulu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.caudexTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
      routes: {
        '/loginadmin': (context) => const LoginAdminPage(),
        '/signuppemilih': (context) => const SignUpPemilihPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/loginpemilih': (context) => const LoginPemilihPage(),
        '/datapemilih': (context) => const DataPemilihPage(),
        '/profileadmin': (context) => const ProfileAdminPage(),
        '/home': (context) => const HomePage(),
      },     
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OSIS SMKN 1 Kota Bengkulu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                Navigator.pop(context); // Tutupan drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text(
                'Login Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, '/loginadmin'); // Navigasi ke halaman LoginAdmin
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text(
                'Login Pemilih',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, '/loginpemilih'); // Navigasi ke halaman LoginAdmin
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text(
                'Sign Up Pemilih',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(context,
                    '/signuppemilih'); // Navigasi ke halaman SignUpPemilih
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          // Gambar background
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/images/background.jpg', // Pastikan gambar ada di path yang benar
              fit: BoxFit.cover,
            ),
          ),
          // Efek blur pada gambar
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Efek blur
            child: Container(
              color: Colors.black.withOpacity(0), // Transparan
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logoosis.png',
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Gambar tidak ditemukan');
                  },
                  height: 200,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Aksi untuk button Mulai Voting
                    Navigator.pushNamed(context, '/loginpemilih');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 108, 140, 155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Mulai Voting',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signuppemilih');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 108, 140, 155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Sign Up Pemilih',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical:
                          10), // Memberikan padding agar teks tidak terlalu mepet dengan tepi
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                        0.7), // Warna hitam dengan transparansi 50%
                    borderRadius:
                        BorderRadius.circular(19), // Membuat sudut yang membulat
                  ),
                  child: const Text(
                    'by Cessa Aqillah Jhonaidy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(
                          255, 255, 255, 255), // Teks berwarna putih
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
