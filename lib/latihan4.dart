import 'package:flutter/material.dart'; // Impor paket flutter untuk membangun UI aplikasi
import 'package:http/http.dart' as http; // Impor paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Impor pustaka convert untuk konversi data JSON
import 'package:provider/provider.dart'; // Impor paket provider untuk manajemen state

// Kelas University adalah model data yang merepresentasikan sebuah universitas.
class University {
  String name; // Properti untuk menyimpan nama universitas.
  String website; // Properti untuk menyimpan URL situs web universitas.

  // Konstruktor untuk kelas University.
  // Mengambil dua parameter wajib: name dan website.
  University({required this.name, required this.website});
}

// Kelas UniversityProvider yang bertanggung jawab menyediakan data universitas dan memberi tahu widget terkait tentang perubahan data
class UniversityProvider extends ChangeNotifier {
  late Future<List<University>> futureUniversities; // Future untuk menyimpan daftar universitas yang akan datang
  late String url; // URL untuk mengambil data universitas

  UniversityProvider() { // Konstruktor kelas UniversityProvider.
    url = "http://universities.hipolabs.com/search?country=Indonesia"; // URL awal untuk mengambil data universitas dari Indonesia
    futureUniversities = fetchUniversities(); // Memanggil fungsi untuk mengambil data universitas
  }

  Future<List<University>> fetchUniversities() async { // Fungsi untuk mengambil data universitas dari API
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP ke API

    if (response.statusCode == 200) { // Jika status code dari respons HTTP adalah 200 (OK),
      List<dynamic> data = json.decode(response.body); // Mendecode respons JSON menjadi daftar dinamis
      List<University> universities = []; // Daftar untuk menyimpan objek University

      for (var item in data) { // Loop ini digunakan untuk mengiterasi melalui setiap item dalam data respons JSON.
        // Menambahkan instance University baru ke dalam daftar universities
        // dengan menggunakan data dari respons JSON.
        universities.add(
          University(
            name: item['name'], // Mendapatkan nama universitas dari respons JSON
            website: item['web_pages'][0], // Mendapatkan situs web universitas dari respons JSON
          ),
        );
      }

      return universities; // Mengembalikan daftar universitas
    } else {
      throw Exception('Failed to load universities'); // Melempar exception jika gagal mengambil data
    }
  }

  void changeCountry(String country) { // Fungsi untuk mengubah negara dan memperbarui daftar universitas
    url = "http://universities.hipolabs.com/search?country=$country"; // Mengubah URL dengan negara yang dipilih
    futureUniversities = fetchUniversities(); // Memanggil fungsi untuk mengambil data universitas
    notifyListeners(); // Memberitahu widget terkait tentang perubahan data
  }
}

class MyApp extends StatelessWidget { //deklarasi sebuah kelas bernama MyApp yang merupakan turunan dari kelas StatelessWidget.
  @override //mendeklarasikan ulang metode build dari kelas StatelessWidget.
  Widget build(BuildContext context) {  //deklarasi metode build. 
    return ChangeNotifierProvider( // Membungkus root widget dengan provider untuk manajemen state
      create: (context) => UniversityProvider(), // Membuat instance UniversityProvider
      child: MaterialApp( //Widget MyApp memiliki satu child, yaitu instance dari MaterialApp.
        title: 'Universitas App', //Properti title dari MaterialApp menetapkan judul aplikasi 
        home: Scaffold( //Properti home dari MaterialApp menetapkan halaman utama aplikasi.
          appBar: AppBar( //Properti appBar dari Scaffold menetapkan bilah aplikasi yang akan ditampilkan di bagian atas layar.
            title: Text( //Properti title dari AppBar menetapkan teks yang akan ditampilkan sebagai judul di dalam bilah aplikasi. 
              'Universitas di Negara ASEAN', // Judul AppBar
              style: TextStyle(color: Colors.white), // Mengubah warna teks header menjadi putih
            ),
            backgroundColor: Color(0xFF283593), // Mengatur warna latar belakang AppBar
          ),
          body: UniversityList(), // Widget body aplikasi
        ),
      ),
    );
  }
}

class UniversityList extends StatelessWidget { // Kelas UniversityList untuk menampilkan daftar universitas
  @override //mendeklarasikan ulang metode build dari kelas StatelessWidget.
  Widget build(BuildContext context) { //deklarasi metode build. 
    var universityProvider = Provider.of<UniversityProvider>(context); // Mendapatkan instance UniversityProvider dari provider

    return Column( //menandakan bahwa sedang mengembalikan sebuah widget Column
      children: [ // Daftar widget yang akan ditampilkan secara vertikal
        Padding( // Widget Padding untuk memberikan jarak tambahan di sekitar widget-child-nya
          padding: const EdgeInsets.all(8.0), // Memberikan jarak 8.0 pada setiap sisi dari Padding
          child: DropdownButtonFormField<String>( // Widget dropdown button form field
            decoration: InputDecoration( // Properti decoration untuk menyesuaikan tampilan dropdown button
              labelText: 'Pilih Negara ASEAN', // Label dropdown
              border: OutlineInputBorder(), // Mengatur border dropdown
              filled: true, // Mengisi latar dropdown dengan warna
              fillColor: Colors.grey[200], // Warna latar dropdown
            ),
            items: <String>[ // Mendefinisikan list yang berisi nama-nama negara ASEAN dalam bentuk String
              'Indonesia', 'Singapore', 'Malaysia', 'Thailand', 'Vietnam', 'Philippines', 'Myanmar', 'Cambodia', 'Laos', 'Brunei Darussalam'
            ].map((String value) { // Menerapkan fungsi map untuk setiap elemen dalam list
              return DropdownMenuItem<String>( // Membuat sebuah DropdownMenuItem dengan nilai dan teks yang sama
                value: value, // Nilai yang akan dikirimkan jika item ini dipilih
                child: Text(value), // Teks untuk setiap item dropdown
              );
            }).toList(), // Mengubah hasil dari map menjadi list
            onChanged: (String? newValue) { // Callback yang dipanggil ketika nilai dropdown berubah
              if (newValue != null) { // Memeriksa apakah nilai yang dipilih tidak null
                universityProvider.changeCountry(newValue); // Mengubah negara saat nilai dropdown berubah
              }
            },
          ),
        ),
        Expanded( // Widget Expanded digunakan untuk mengisi ruang yang tersedia di layar
          child: FutureBuilder<List<University>>( // Widget untuk membangun UI berdasarkan Future
            future: universityProvider.futureUniversities, // Future yang akan digunakan untuk membangun UI
            builder: (context, snapshot) { // Builder function untuk membangun UI berdasarkan snapshot dari Future
              if (snapshot.connectionState == ConnectionState.waiting) { // Memeriksa apakah Future sedang dalam keadaan menunggu
                return Center( // Menampilkan widget di tengah layar
                  child: CircularProgressIndicator(), // Indikator loading saat data sedang dimuat
                );
              } else if (snapshot.hasError) { // Memeriksa apakah terjadi kesalahan dalam memuat data
                return Center( // Menampilkan widget di tengah layar
                  child: Text('${snapshot.error}'), // Teks kesalahan jika gagal memuat data
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) { // Memeriksa apakah tidak ada data yang tersedia atau data kosong
                return Center( // Menampilkan widget di tengah layar
                  child: Text('No data available'), // Teks jika tidak ada data yang tersedia
                );
              } else { // Ketika tidak terjadi error dan data tersedia
                return ListView.separated( // Menampilkan daftar data dalam bentuk ListView dengan pemisah
                  shrinkWrap: true, // Menyusutkan listview sesuai dengan konten
                  itemCount: snapshot.data!.length, // Jumlah item dalam list
                  separatorBuilder: (BuildContext context, int index) => // Membangun pemisah antara setiap item dalam ListView
                      Divider(), // Pembuat pemisah antar item
                  itemBuilder: (context, index) { // Membangun setiap item dalam ListView
                    return ListTile( // Membuat widget ListTile untuk menampilkan item dalam ListView
                      title: Text(snapshot.data![index].name), // Teks nama universitas
                      subtitle: Text(snapshot.data![index].website), // Teks situs web universitas
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

void main() { // Titik masuk untuk aplikasi Flutter
  runApp(MyApp()); // Memulai aplikasi Flutter dengan widget MyApp
}