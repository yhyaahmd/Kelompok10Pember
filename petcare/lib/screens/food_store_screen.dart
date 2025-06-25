import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_product.dart';
import '../services/food_service.dart';
import 'food_detail_screen.dart';
import 'petshop_list_screen.dart';

class FoodStoreScreen extends StatefulWidget {
  @override
  _FoodStoreScreenState createState() => _FoodStoreScreenState();
}

class _FoodStoreScreenState extends State<FoodStoreScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodProduct> _products = [];
  List<FoodProduct> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);
      final products = await _foodService.getFoodProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts =
            _products
                .where(
                  (product) =>
                      product.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      product.brand.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FD),
      appBar: AppBar(
        title: Text(
          'Toko Makanan Hewan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2686C2),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.store, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetshopListScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Cari makanan hewan...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF2686C2)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Products Grid
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2686C2),
                      ),
                    )
                    : _filteredProducts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada produk ditemukan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(FoodProduct product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child:
                    product.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 48,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                        : Icon(Icons.pets, size: 48, color: Colors.grey),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.weight,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(product.price),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2686C2),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
