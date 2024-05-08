import 'package:flutter/material.dart'; // Mengimpor library Flutter untuk membuat UI
import 'package:http/http.dart' as http; // Mengimpor library http untuk melakukan HTTP requests
import 'dart:convert'; // Mengimpor library dart:convert untuk mengonversi data JSON
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor library flutter_bloc untuk mengelola state aplikasi dengan BloC pattern

// Model untuk merepresentasikan universitas
class University {
  String name; // Nama universitas
  String website; // Website universitas

  University({required this.name, required this.website}); // Constructor untuk inisialisasi objek University
}

// Cubit untuk mengelola state aplikasi terkait daftar universitas
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]); // Constructor untuk UniversityCubit

  // Fungsi untuk mengambil daftar universitas dari server berdasarkan negara
  void fetchUniversities(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL endpoint untuk mengambil data universitas
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request untuk mengambil data universitas dari server

    if (response.statusCode == 200) { // Memeriksa apakah responsenya berhasil (status code 200)
      List<dynamic> data = json.decode(response.body); // Mendekode respons JSON menjadi List<dynamic>
      List<University> universities = []; // List untuk menyimpan objek University

      // Melooping data respons dan membuat objek University untuk setiap entri
      for (var item in data) { // Iterasi melalui setiap item dalam data
        universities.add( // Menambahkan objek University ke dalam daftar universities
          University( // Membuat objek University
            name: item['name'], // Menggunakan nilai 'name' dari item sebagai nama universitas
            website: item['web_pages'][0], // Menggunakan nilai pertama dari 'web_pages' sebagai website universitas
          ),
        );
      }

      // Mengeluarkan daftar universitas yang baru diambil dari server
      emit(universities);
    } else {
      throw Exception('Failed to load universities'); // Melempar exception jika gagal mengambil data universitas
    }
  }
}

// Widget utama aplikasi
class MyApp extends StatelessWidget { // Widget MyApp merupakan StatelessWidget
  @override
  Widget build(BuildContext context) { // Override method build untuk membangun UI
    return MaterialApp( // MaterialApp sebagai root widget aplikasi
      title: 'Universitas App', // Judul aplikasi
      home: BlocProvider( // Memberikan UniversityCubit ke UniversitesPage
        create: (context) => UniversityCubit(), // Membuat instance baru dari UniversityCubit
        child: UniversitiesPage(), // Widget untuk menampilkan daftar universitas
      ),
    );
  }
}

class UniversitiesPage extends StatelessWidget { // Widget UniversitiesPage merupakan Stateless Widget
  @override
  Widget build(BuildContext context) { // Override method build untuk membangun UI
    return Scaffold( // Scaffold sebagai kerangka utama halaman
      appBar: AppBar( // AppBar sebagai header halaman
        title: Text( // Judul pada AppBar
          'Universitas di Negara ASEAN', // Judul halaman
          style: TextStyle(color: Colors.white), // Gaya teks untuk judul
        ),
        backgroundColor: Color(0xFF283593), // Warna latar belakang appbar
      ),
      body: Column( // Widget Column untuk menempatkan widget secara vertikal
        children: [ // Daftar widget yang akan ditampilkan secara vertikal dalam Column
          BlocBuilder<UniversityCubit, List<University>>( // Membangun widget berdasarkan state UniversityCubit
            builder: (context, universityList) { // Fungsi untuk membangun UI berdasarkan state terbaru
              return Padding( // Widget Padding untuk menambahkan padding di sekitar DropdownButtonFormField
                padding: const EdgeInsets.all(8.0), // Menetapkan padding 8.0 di sekeliling DropdownButtonFormField
                child: DropdownButtonFormField<String>( // DropdownButtonFormField untuk memilih negara ASEAN
                  decoration: InputDecoration( // Mendefinisikan dekorasi untuk DropdownButtonFormField

                    labelText: 'Pilih Negara ASEAN', // Label dropdown
                    border: OutlineInputBorder(), // Gaya border
                    filled: true, // Mengisi latar belakang
                    fillColor: Colors.grey[200], // Warna latar belakang
                  ),
                  items: <String>[ // Daftar negara ASEAN
                    'Indonesia',
                    'Singapore',
                    'Malaysia',
                    'Thailand',
                    'Vietnam',
                    'Philippines',
                    'Myanmar',
                    'Cambodia',
                    'Laos',
                    'Brunei Darussalam'
                  ].map((String value) { // Memetakan setiap elemen dalam daftar negara ASEAN menjadi objek DropdownMenuItem<String>
                    return DropdownMenuItem<String>( // Membuat objek DropdownMenuItem<String> untuk setiap elemen negara
                      value: value, // Nilai dropdown
                      child: Text(value), // Teks yang ditampilkan
                    );
                  }).toList(), // Mengonversi daftar negara ASEAN menjadi daftar DropdownMenuItem<String>
                  onChanged: (String? newValue) { // Callback ketika nilai dropdown berubah
                    if (newValue != null) { //memeriksa apakah nilai baru dari dropdown tidak null sebelum memanggil fungsi fetchUniversities dari UniversityCubit.
                      context.read<UniversityCubit>().fetchUniversities(newValue); // Memanggil fetchUniversities dari UniversityCubit
                    }
                  },
                ),
              );
            },
          ),
          Expanded( // Widget Expanded untuk menyesuaikan ukuran child dengan sisa ruang yang tersedia
            child: BlocBuilder<UniversityCubit, List<University>>( // Membangun widget berdasarkan state UniversityCubit
              builder: (context, universityList) { // Fungsi untuk membangun UI berdasarkan state terbaru
                if (universityList.isEmpty) { // Jika daftar universitas kosong
                  // Menampilkan indicator loading
                  return Center( // Menampilkan widget di tengah layar
                    child: CircularProgressIndicator(), // Menampilkan indikator loading
                  );
                } else { // Jika daftar universitas tidak kosong
                  return ListView.separated( // Menampilkan daftar universitas dalam bentuk ListView
                    shrinkWrap: true, // Membuat ListView mengikuti ukuran anak-anaknya
                    itemCount: universityList.length, // Jumlah item dalam daftar
                    separatorBuilder: (BuildContext context, int index) => // Fungsi untuk membangun pemisah antara setiap item dalam ListView
                        Divider(), // Pemisah antar item
                    itemBuilder: (context, index) { // Fungsi untuk membangun setiap item dalam ListView
                      return ListTile( // Widget untuk menampilkan setiap item universitas
                        title: Text(universityList[index].name), // Nama universitas
                        subtitle: Text(universityList[index].website), // Website universitas
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() { // Fungsi untuk menjalankan aplikasi Flutter
  runApp(MyApp()); // Memulai aplikasi Flutter
}
