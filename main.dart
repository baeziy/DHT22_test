import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF8B0ABF,
          <int, Color>{
            50: Color(0xFFE5CFF3),
            100: Color(0xFFD3A0E9),
            200: Color(0xFFC170DE),
            300: Color(0xFFAE41D3),
            400: Color(0xFF9D21C9),
            500: Color(0xFF8B0ABF),
            600: Color(0xFF7E00B8),
            700: Color(0xFF7500B1),
            800: Color(0xFF6A00A9),
            900: Color(0xFF5A009C),
          },
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  Stream<DatabaseEvent>? _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseDatabase.instance.ref().child("sensor_data").onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Info'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _dataStream,
          builder:
              (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasData &&
                snapshot.data!.snapshot.value is Map<dynamic, dynamic>) {
              Map<dynamic, dynamic> data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              double? temperature = (data['temperature'] as num).toDouble();
              int? humidity = (data['humidity'] as num).toInt();

              return ListView(
                children: <Widget>[
                  SizedBox(height: 50),
                  Text(
                    'Temperature: $temperature°C',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Humidity: $humidity%',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

  // Future<void> fetchWeatherData() async {
  //   print("Attempting to fetch data...");
  //   final dbRef = FirebaseDatabase.instance.ref().child("sensor_data");
  //   dbRef.once().then((DatabaseEvent event) {
  //     if (event.snapshot.value != null &&
  //         event.snapshot.value is Map<dynamic, dynamic>) {
  //       print("Data fetched: ${event.snapshot.value}");
  //       Map<String, dynamic> data = Map<String, dynamic>.from(
  //           event.snapshot.value as Map<dynamic, dynamic>);
  //       setState(() {
  //         temperature = (data['temperature'] as num).toDouble();
  //         humidity = (data['humidity'] as num).toInt();
  //       });
  //     } else {
  //       print("No data found at the specified reference.");
  //     }
  //   }).catchError((error) {
  //     print("Error fetching data: $error");
  //   });
  // }
  //}
