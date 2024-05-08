import 'package:flutter/material.dart'; // Mengimpor paket flutter/material.dart untuk mengakses widget dan fitur UI Flutter.
import 'package:http/http.dart' as http; // Mengimpor paket http untuk membuat HTTP requests.
import 'dart:convert'; // Mengimpor paket dart:convert untuk mengonversi data dari/ke JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor paket flutter_bloc untuk menggunakan Flutter Bloc.

class University { // Deklarasi kelas University sebagai model data universitas.
  String name; // Properti untuk menyimpan nama universitas.
  String website; // Properti untuk menyimpan website universitas.

  University({required this.name, required this.website}); // Konstruktor untuk inisialisasi objek University.
}

abstract class UniversityEvent {} // Kelas abstrak UniversityEvent untuk mendefinisikan event yang terkait dengan universitas.

class CountrySelected extends UniversityEvent { // Event CountrySelected yang dipicu ketika pengguna memilih negara pada dropdown.
  final String country; // Properti untuk menyimpan nama negara yang dipilih.

  CountrySelected(this.country); // Konstruktor untuk inisialisasi event dengan nama negara yang dipilih.
}

class UniversitiesUpdated extends UniversityEvent {} // Event UniversitiesUpdated yang dipicu setelah daftar universitas diperbarui.

class UniversityState { // Kelas untuk merepresentasikan state aplikasi terkait dengan universitas.
  final List<University> universities; // Properti untuk menyimpan daftar universitas.
  final String selectedCountry; // Properti untuk menyimpan nama negara yang dipilih.

  UniversityState({required this.universities, required this.selectedCountry}); // Konstruktor untuk inisialisasi state.

}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> { // Kelas UniversityBloc yang mengelola state aplikasi terkait dengan universitas.
  UniversityBloc() : super(UniversityState(universities: [], selectedCountry: 'Indonesia')); // Konstruktor untuk menginisialisasi state awal dengan daftar universitas kosong dan negara yang dipilih adalah Indonesia.

  @override
  Stream<UniversityState> mapEventToState(UniversityEvent event) async* { // Method untuk memetakan event menjadi state baru.
    if (event is CountrySelected) { // Jika event yang dipicu adalah CountrySelected.
      yield* _mapCountrySelectedToState(event.country); // Memanggil method _mapCountrySelectedToState untuk memproses pemilihan negara.
    } else if (event is UniversitiesUpdated) { // Jika event yang dipicu adalah UniversitiesUpdated.
      yield state; // Tidak ada perubahan state, hanya memicu efek samping.
    }
  }

  Stream<UniversityState> _mapCountrySelectedToState(String country) async* { // Method untuk memproses pemilihan negara.
    yield UniversityState(universities: [], selectedCountry: country); // Mengeluarkan state baru dengan daftar universitas kosong dan negara yang dipilih adalah negara yang baru dipilih.
    yield await _fetchUniversities(country); // Memuat daftar universitas dari server berdasarkan negara yang dipilih.
  }

  Future<UniversityState> _fetchUniversities(String country) async { // Method untuk memuat daftar universitas dari server.
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL endpoint untuk mengambil data universitas berdasarkan negara.
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request untuk mengambil data dari server.

    if (response.statusCode == 200) { // Jika respons sukses (status code 200).
      List<dynamic> data = json.decode(response.body); // Mendekode respons JSON menjadi List<dynamic>.
      List<University> universities = []; // Inisialisasi list untuk menyimpan objek University.

      for (var item in data) { // Melakukan iterasi untuk setiap item dalam data.
        universities.add( // Menambahkan objek University ke dalam list universities.
          University( // Membuat objek University baru.
            name: item['name'], // Mendapatkan nama universitas dari item.
            website: item['web_pages'][0], // Mendapatkan website universitas dari item.
          ),
        );
      }

      return UniversityState(universities: universities, selectedCountry: country); // Mengembalikan state baru dengan daftar universitas yang berhasil dimuat dan negara yang dipilih.
    } else { // Jika respons gagal.
      throw Exception('Failed to load universities'); // Memicu exception bahwa gagal memuat data universitas dari server.
    }
  }
}

class MyApp extends StatelessWidget { // Kelas MyApp sebagai root widget aplikasi.
  @override
  Widget build(BuildContext context) { // Method untuk membangun UI aplikasi.
    return MaterialApp( // Mengembalikan MaterialApp sebagai root widget.
      title: 'Universitas App', // Judul aplikasi.
      home: BlocProvider( // Menyediakan UniversityBloc ke dalam pohon widget.
        create: (context) => UniversityBloc(), // Membuat instance baru dari UniversityBloc.
        child: UniversitiesPage(), // Menampilkan halaman UniversitiesPage sebagai halaman utama.
      ),
    );
  }
}

class UniversitiesPage extends StatelessWidget { // Halaman utama aplikasi yang menampilkan daftar universitas dan dropdown untuk memilih negara.
  @override
  Widget build(BuildContext context) { // Method untuk membangun UI halaman.
    return Scaffold( // Mengembalikan Scaffold sebagai kerangka UI halaman.
      appBar: AppBar( // AppBar sebagai header halaman.
        title: Text( // Judul pada AppBar.
          'Universitas di Negara ASEAN', // Judul halaman.
          style: TextStyle(color: Colors.white), // Gaya teks untuk judul halaman (warna putih).
        ),
        backgroundColor: Color(0xFF283593), // Warna latar belakang AppBar.
      ),
      body: Column( // Menggunakan widget Column untuk menempatkan widget secara vertikal.
        children: [ // Daftar widget yang akan ditampilkan secara vertikal dalam Column.
          BlocBuilder<UniversityBloc, UniversityState>( // Membangun widget berdasarkan state UniversityBloc.
            builder: (context, state) { // Fungsi builder untuk membangun UI berdasarkan state terbaru.
              return Padding( // Widget Padding untuk menambahkan padding di sekeliling DropdownButtonFormField.
                padding: const EdgeInsets.all(8.0), // Padding sebesar 8.0 di sekeliling DropdownButtonFormField.
                child: DropdownButtonFormField<String>( // DropdownButtonFormField untuk memilih negara ASEAN.
                  value: state.selectedCountry, // Nilai dropdown berdasarkan negara yang dipilih di state.
                  decoration: InputDecoration( // Dekorasi untuk DropdownButtonFormField.
                    labelText: 'Pilih Negara ASEAN', // Label untuk dropdown.
                    border: OutlineInputBorder(), // Jenis border untuk dropdown.
                    filled: true, // Mengisi latar belakang dropdown.
                    fillColor: Colors.grey[200], // Warna latar belakang dropdown.
                  ),
                  items: <String>[ // Daftar item yang dapat dipilih dalam dropdown.
                    'Indonesia',
                    'Singapura',
                    'Malaysia',
                    'Thailand',
                    'Vietnam',
                    'Filipina',
                    'Myanmar',
                    'Kamboja',
                    'Laos',
                    'Brunei Darussalam'
                  ].map((String value) { // Mengonversi daftar string menjadi daftar widget DropdownMenuItem.
                    return DropdownMenuItem<String>( // Membuat DropdownMenuItem untuk setiap negara dalam daftar.
                      value: value, // Nilai dari DropdownMenuItem.
                      child: Text(value), // Widget child berisi teks nama negara.
                    );
                  }).toList(), // Mengonversi daftar DropdownMenuItem menjadi list.
                  onChanged: (String? newValue) { // Fungsi yang dipanggil saat negara dipilih.
                    if (newValue != null) { // Memastikan nilai yang dipilih tidak null.
                      context.read<UniversityBloc>().add(CountrySelected(newValue)); // Memicu event CountrySelected dengan nilai negara yang baru dipilih.
                    }
                  },
                ),
              );
            },
          ),
          Expanded( // Widget Expanded untuk memperluas daftar universitas agar mengisi ruang yang tersedia.
            child: BlocBuilder<UniversityBloc, UniversityState>( // Membangun widget berdasarkan state UniversityBloc.
              builder: (context, state) { // Fungsi builder untuk membangun UI berdasarkan state terbaru.
                if (state.universities.isEmpty) { // Jika daftar universitas kosong.
                  return Center( // Widget Center untuk menengahkan widget secara horizontal dan vertikal.
                    child: CircularProgressIndicator(), // Menampilkan indikator loading.
                  );
                } else { // Jika daftar universitas tidak kosong.
                  return ListView.separated( // ListView untuk menampilkan daftar universitas.
                    shrinkWrap: true, // Menyusutkan ListView agar sesuai dengan ruang yang tersedia.
                    itemCount: state.universities.length, // Jumlah item dalam ListView sesuai dengan panjang daftar universitas.
                    separatorBuilder: (BuildContext context, int index) => Divider(), // Membangun widget pemisah antar item dalam ListView.
                    itemBuilder: (context, index) { // Fungsi untuk membangun setiap item dalam ListView.
                      return ListTile( // Widget ListTile untuk menampilkan informasi universitas.
                        title: Text(state.universities[index].name), // Teks nama universitas.
                        subtitle: Text(state.universities[index].website), // Teks website universitas.
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

void main() { // Fungsi utama yang menjalankan aplikasi Flutter.
  runApp(MyApp()); // Memulai aplikasi Flutter dengan MyApp sebagai root widget.
}
