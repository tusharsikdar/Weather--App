import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    print("Latitude is ${lat} ${lon}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=23.7509358&lon=90.3931551&appid=756fa267e01fa4eb7a6f3da9927d317f";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=23.7509358&lon=90.3931551&appid=756fa267e01fa4eb7a6f3da9927d317f";

    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    print("result is ${forecastResponce.body}");
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
      Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
  }

  var lat;
  var lon;
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String nowDateTime = DateFormat('hh:mm a – yyyy-MM-dd')
        .format(DateTime.parse(DateTime.now().toString()));
    var celsius = ((weatherMap!["main"]["temp"]) - 273.15);
    return SafeArea(
      child: weatherMap == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[700],
            title: Text('Weather App'),
            actions: [
              Icon(Icons.search),
              SizedBox(width: 30),
              Padding(
                padding: const EdgeInsets.only(right:15),
                child: Icon(Icons.my_location),
              )
            ],
          ),
          backgroundColor: Colors.blueGrey[200],
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 170),
                      child: Text(Jiffy(DateTime.now()).format("MMM do, yyyy h:mm"),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 200),
                      child: Container(
                        child: Text(
                          "${weatherMap!["name"]}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ), // SizedBox
                    SizedBox(height: 40),
                    Container(height: 80,width: 80,
                      child:Image.network('https://cdn-icons-png.flaticon.com/512/3093/3093390.png'),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Text(
                        "${celsius.toInt()}°c",
                        style: TextStyle(fontSize: 100, color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(right: 170),
                      child: Text(
                        "Feels like ${weatherMap!["main"]["feels_like"]}°",
                        style: TextStyle(fontSize: 22,color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 300),
                      child: Text(
                        "${weatherMap!["weather"][0]["main"]}",
                        style: TextStyle(fontSize: 22,color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Humidity : ${weatherMap!["main"]["humidity"]}, Pressure : ${weatherMap!["main"]["pressure"]}",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    Text(
                      "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}   Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                      style: TextStyle(fontSize: 18,color: Colors.white),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 14),
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              width: 130,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("E,h:mm ")}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Container(
                                    height: 50, width: 50,
                                    child: Image.network('https://cdn-icons-png.flaticon.com/512/3222/3222798.png'),
                                  ),
                                  Text(
                                    "${forecastMap!["list"][index]["weather"][0]["description"]}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
