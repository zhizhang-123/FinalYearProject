import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'menu.dart';

const Map<String, Map<String, String>> diseaseSolutions = {
  'anthracnose': {
    'symptoms': '',
    'causes': '2',
    'solution': '3',
    'pesticide': '-',
  },
  'powdery_mildew': {
    'symptoms': 'White powdery spots: Leaves look like they are dusted with flour of sugar.',
    'causes': '1. Fungal spores spread by wind.\n2. Plants are too crowded\n3. Warm days and humid nights.\n4. Not enough sunlight',
    'solution': "1. Remove infected leaves, cut them off and don't compost them\n2. Space out plants or prune them.",
    'pesticide': 'Use Neem oil or sulfur sprays',
  },
  'wither': {
    'symptoms': 'Wilting/Drying Out/Browning Tips/Yellowing',
    'causes': '1. Water Issues\nUnderwatering/Overwatering\n2. Environment\nHeat Stress/Low Humidity/Sunburn/Cold Shock\n3. Nutrients & Soil\nNutrient Deficiency/Fertilizer Burn/Root-bound',
    'solution': 'Underwatering->Water the plant deeply until water runs out of the drainage holes.\n\nOverwatering->Stop watering immediately. Let the soil dry out completely, and ensure the pot has good drainage.\n\nHeat/Sunburn->Move the plant to a shadier spot or use a sheer curtain to filter the light.\n\nLow Humidity: Mist the leaves with water or use a humidifier nearby.\n\nCold Shock->Move plants away from cold windows or air conditioning vents.\n\nNutrient Deficiency->Apply a balanced fertilizer (follow the instructions on the label).\n\nFertilizer Burn->Flush the soil with plenty of plain water to wash away excess salts.\n\nRoot-bound->Repot the plant into a larger container with fresh potting mix.',
    'pesticide': '-',
  },
  'rust':{
    'symptoms': 'Small, raised bumps on the underside of leaves that look like "iron rust.',
    'causes': '1. Caused by a group of fungi (like Puccina)\n2. Wet leaves cause the spores germinate\n3. Overcrowded plants create a damp environment',
    'solution': '1. Isolate plants that have rust disease to prevent spread\n2. Remove infected leaves, cut them off and dont compost them\n3. Space out plants or prune them',
    'pesticide': '1. Use fungicides containing Copper or specialized anti-rust sprays.',
  },
};

class SolutionPage extends StatelessWidget {
  final String diseaseName;

  const SolutionPage({Key? key, required this.diseaseName}) : super(key: key);

  Future<void> _searchNearbyFlowerShops(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError(context, "Location Permission Denied");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final String url = "https://www.google.com/maps/search/?api=1&query=potted+plant+shop&location=${position.latitude},${position.longitude}";
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      _showError(context, "Cannot open Google Maps: $e");
    }
  }

  Future<void> _searchPesticideOnShopee(BuildContext context) async {
    try {
      String searchQuery = "$diseaseName pesticide treatment";

      String encodedQuery = Uri.encodeComponent(searchQuery);

      final Uri uri = Uri.parse("https://shopee.com.my/search?keyword=$encodedQuery");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      _showError(context, "Cannot open Shopee: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
   Widget build(BuildContext context) {
    final info = diseaseSolutions[diseaseName] ?? {
      'symptoms': 'Information not available for this specific disease yet.',
      'causes': 'Unknown',
      'solution': 'Please consult a local agricultural expert.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MenuPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
                        const SizedBox(height: 10),
                        Text(
                          'Plant Problem\n$diseaseName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoCard(
                    title: "Symptoms",
                    icon: Icons.search,
                    content: info['symptoms']!,
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: "Possible Causes",
                    icon: Icons.science,
                    content: info['causes']!,
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: "Solution",
                    icon: Icons.medical_information,
                    content: info['solution']!,
                    color: Colors.green.shade100,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: "Pesticide Need",
                    icon: Icons.medical_services,
                    content: info['pesticide']!,
                    color: Colors.green.shade100,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _searchNearbyFlowerShops(context),
                      icon: const Icon(Icons.storefront, color: Colors.white),
                      label: const Text(
                        "Find Nearby Potted Plant Shops",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _searchPesticideOnShopee(context),
                      icon: const Icon(Icons.storefront, color: Colors.white),
                      label: const Text(
                        "Find Pesticides on Shopee",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54)),
        ],
      ),
    );
  }
}