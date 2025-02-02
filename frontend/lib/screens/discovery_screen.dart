import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'purchase_screen.dart';
import 'profile_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List nearbyUsers = [];
  bool _isLoading = false;
  bool _isRefreshing = false; // To manage the state of the refresh button
  final double _searchRadius = 10;

  @override
  void initState() {
    super.initState();
    _updateLocationAndFetchNearby();
  }

  Future<void> _updateLocationAndFetchNearby() async {
    setState(() {
      _isLoading = true;
      _isRefreshing = true; // Indicates refresh is in progress
    });

    try {
      // Fetch current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Send updated location to the backend
      await ApiService().updateLocation(position.latitude, position.longitude);

      // Fetch nearby users
      final response = await ApiService().getNearbyUsers(_searchRadius);
      if (response.statusCode == 200) {
        setState(() {
          nearbyUsers = response.data;
        });
      } else {
        _showSnackBar('Failed to fetch nearby users');
      }
    } catch (e) {
      debugPrint('Error fetching location or users: $e');
      _showSnackBar('An error occurred while refreshing: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false; // Reset the refresh button state
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _openChat(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: userId)),
    );
  }

  void _openPurchaseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PurchaseScreen()),
    );
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectify Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: _openPurchaseScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Refresh Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isRefreshing ? null : _updateLocationAndFetchNearby,
              child: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Refresh Location'),
            ),
          ),

          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : nearbyUsers.isEmpty
                    ? const Center(child: Text('No users nearby'))
                    : ListView.builder(
                        itemCount: nearbyUsers.length,
                        itemBuilder: (context, index) {
                          final user = nearbyUsers[index];
                          return ListTile(
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Text('User ID: ${user['id']}'),
                            onTap: () => _openChat(user['id']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
