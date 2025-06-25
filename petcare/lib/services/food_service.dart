import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_product.dart';
import '../models/petshop.dart';
import '../models/order.dart';

class FoodService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all food products
  Future<List<FoodProduct>> getFoodProducts() async {
    try {
      final response = await _supabase
          .from('food_products')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FoodProduct.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting food products: $e');
      throw Exception('Gagal memuat produk makanan');
    }
  }

  // Search food products
  Future<List<FoodProduct>> searchFoodProducts(String query) async {
    try {
      final response = await _supabase
          .from('food_products')
          .select()
          .or('name.ilike.%$query%,brand.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FoodProduct.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching food products: $e');
      throw Exception('Gagal mencari produk');
    }
  }

  // Get food product by ID
  Future<FoodProduct?> getFoodProductById(String id) async {
    try {
      final response = await _supabase
          .from('food_products')
          .select()
          .eq('id', id)
          .single();

      return FoodProduct.fromJson(response);
    } catch (e) {
      print('Error getting food product by ID: $e');
      return null;
    }
  }

  // Get all petshops
  Future<List<Petshop>> getPetshops() async {
    try {
      final response = await _supabase
          .from('petshops')
          .select()
          .order('distance', ascending: true);

      return (response as List)
          .map((json) => Petshop.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting petshops: $e');
      throw Exception('Gagal memuat daftar petshop');
    }
  }

  // Create order
  Future<bool> createOrder(Order order) async {
    try {
      await _supabase
          .from('orders')
          .insert(order.toJson());

      return true;
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Gagal membuat pesanan');
    }
  }

  // Get orders by user
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      throw Exception('Gagal memuat riwayat pesanan');
    }
  }
}
