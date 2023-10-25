import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/component/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  double lat = 0.0;
  double lon = 0.0;
  double temperature = 0.0;
  String? name;
  String? description;
  String date = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
  Location location = Location();

  Future<void> getWeatherData() async {
    LocationData locationData = await location.getLocation();
    lat = locationData.latitude!;
    lon = locationData.longitude!;
    final response = await http.get(
      Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temp = data['main']['temp'];
      final city = data['name'];

      final weather = data['weather'][0];
      final desc = weather['description'];
      // final desc = data['weather']['main'];

      setState(() {
        temperature = temp - 273.15;
        name = city;
        description = desc;
        // print('Latitude : $lat');
        // print('Longitude : $lon');
      });
    }
  }

  @override
  void initState() {
    getWeatherData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: backgroundColor1,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.clamp,
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor1,
                backgroundColor2,
              ],
            ),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                Text(
                  name ?? 'waiting...',
                  style: const TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://cdn.icon-icons.com/icons2/3191/PNG/512/sunny_sun_cloud_weather_cloudy_icon_194237.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, progress) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(color: Colors.white, fontSize: 60),
                ),
                Text(
                  description ?? 'waiting...',
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 14,
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
