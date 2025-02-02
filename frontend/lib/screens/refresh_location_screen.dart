import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class RefreshLocationScreen extends StatefulWidget {
  final String authToken; // Pass the auth token from login

  const RefreshLocationScreen({super.key, required this.authToken});

  @override
  _RefreshLocationScreenState createState() => _RefreshLocationScreenState();
}

class _RefreshLocationScreenState extends State<RefreshLocationScreen> {
  bool isButtonDisabled = false; // To manage cooldown state
  String statusMessage = "Press the button to refresh your location.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Refresh Location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonDisabled ? null : _refreshLocation,
              child: Text(isButtonDisabled
                  ? "Please wait..."
                  : "Refresh Location"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    setState(() {
      statusMessage = "Fetching location...";
    });

    try {
      // Get user's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Send location to the backend
      await _sendLocationToBackend(latitude, longitude);

      setState(() {
        statusMessage = "Location updated successfully!";
      });

      // Start cooldown timer
      _startCooldown();
    } catch (e) {
      setState(() {
        statusMessage = "Failed to refresh location: $e";
      });
    }
  }

  Future<void> _sendLocationToBackend(double latitude, double longitude) async {
    try {
      Dio dio = Dio();
      dio.options.headers["Authorization"] = "Bearer ${widget.authToken}";

      final response = await dio.post(
        "http://127.0.0.1:8000/api/update-location",
        data: {
          "latitude": latitude,
          "longitude": longitude,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = "Location updated successfully!";
        });
      } else {
        throw Exception("Failed to update location. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error sending location to backend: $e");
    }
  }

  void _startCooldown() {
    setState(() {
      isButtonDisabled = true; // Disable the button
    });

    Timer(Duration(seconds: 20), () {
      setState(() {
        isButtonDisabled = false; // Re-enable the button after 20 seconds
        statusMessage = "Press the button to refresh your location.";
      });
    });
  }
}
