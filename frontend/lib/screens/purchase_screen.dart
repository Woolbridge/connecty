import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isLoading = false;

  Future<void> _buyPremium() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().makePurchase(9.99, 'premium');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium purchased successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buyBalance() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().makePurchase(5.00, 'balance');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balance added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Options'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _buyPremium,
                    child: const Text('Buy Premium - \$9.99'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _buyBalance,
                    child: const Text('Add \$5.00 to Balance'),
                  ),
                ],
              ),
      ),
    );
  }
}
