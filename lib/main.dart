import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class University {
  String name;
  String website;

  University({required this.name, required this.website});
}

class UniversityProvider extends ChangeNotifier {
  late Future<List<University>> futureUniversities;
  late String url;

  UniversityProvider() {
    url = "http://universities.hipolabs.com/search?country=Indonesia";
    futureUniversities = fetchUniversities();
  }

  Future<List<University>> fetchUniversities() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<University> universities = [];

      for (var item in data) {
        universities.add(
          University(
            name: item['name'],
            website: item['web_pages'][0],
          ),
        );
      }

      return universities;
    } else {
      throw Exception('Failed to load universities');
    }
  }

  void changeCountry(String country) {
    url = "http://universities.hipolabs.com/search?country=$country";
    futureUniversities = fetchUniversities();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UniversityProvider(),
      child: MaterialApp(
        title: 'Universitas App',
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Universitas di Negara ASEAN',
              style: TextStyle(color: Colors.white), // Mengubah warna teks header menjadi putih
            ),
            backgroundColor: Color(0xFF283593),
          ),
          body: UniversityList(),
        ),
      ),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Pilih Negara ASEAN',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            items: <String>[
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
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                universityProvider.changeCountry(newValue);
              }
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<University>>(
            future: universityProvider.futureUniversities,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No data available'),
                );
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text(snapshot.data![index].website),
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

void main() {
  runApp(MyApp());
}