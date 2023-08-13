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
      title: 'WeatherPulse',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
        scaffoldBackgroundColor: Colors.black,
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
        title: const Text('WeatherPulse'),
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
              double? humidity = (data['humidity'] as num)
                  .toDouble(); // Convert to double without changing the value

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildWeatherBox('Temperature',
                      temperature?.toStringAsFixed(1) ?? '', '°C'),
                  const SizedBox(height: 20),
                  _buildWeatherBox(
                      'Humidity',
                      humidity?.toStringAsFixed(1) ?? '',
                      ' %'), // Display as decimal
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

  Widget _buildWeatherBox(String title, String value, String unit) {
    return Container(
      width: 300, // Set a fixed width
      height: 130, // Set a fixed height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$value$unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
