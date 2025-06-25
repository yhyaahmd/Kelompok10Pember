import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/petshop.dart';
import '../services/food_service.dart';

class PetshopListScreen extends StatefulWidget {
  @override
  _PetshopListScreenState createState() => _PetshopListScreenState();
}

class _PetshopListScreenState extends State<PetshopListScreen> {
  final FoodService _foodService = FoodService();
  List<Petshop> _petshops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetshops();
  }

  Future<void> _loadPetshops() async {
    try {
      final petshops = await _foodService.getPetshops();
      setState(() {
        _petshops = petshops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data petshop: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openMaps(Petshop petshop) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${petshop.latitude},${petshop.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _callPetshop(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat melakukan panggilan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FD),
      appBar: AppBar(
        title: Text('Petshop Terdekat'),
        backgroundColor: const Color(0xFF2686C2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2686C2),
              ),
            )
          : _petshops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada petshop tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPetshops,
                  color: Color(0xFF2686C2),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _petshops.length,
                    itemBuilder: (context, index) {
                      final petshop = _petshops[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with name and distance
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          petshop.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              petshop.rating.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (petshop.distance != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2686C2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${petshop.distance!.toStringAsFixed(1)} km',
                                        style: TextStyle(
                                          color: Color(0xFF2686C2),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 12),
                              
                              // Address
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      petshop.address,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              
                              // Phone
                              if (petshop.phone != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      petshop.phone!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 16),
                              
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openMaps(petshop),
                                      icon: Icon(
                                        Icons.directions,
                                        size: 18,
                                        color: Color(0xFF2686C2),
                                      ),
                                      label: Text(
                                        'Navigasi',
                                        style: TextStyle(
                                          color: Color(0xFF2686C2),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Color(0xFF2686C2)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  if (petshop.phone != null)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _callPetshop(petshop.phone!),
                                        icon: Icon(
                                          Icons.call,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Telepon',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2686C2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
