import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/material_type.dart';
import '../models/ad.dart';
import '../models/transaction.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Cache for loaded data
  List<User>? _users;
  List<MaterialType>? _materialTypes;
  List<Ad>? _ads;
  List<Transaction>? _transactions;

  // Load users from JSON
  Future<List<User>> loadUsers() async {
    if (_users != null) return _users!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _users = jsonList.map((json) => User.fromJson(json)).toList();
      return _users!;
    } catch (e) {
      print('Error loading users: $e');
      _users = []; // Initialize empty list to prevent null issues
      return _users!;
    }
  }

  // Load material types from JSON
  Future<List<MaterialType>> loadMaterialTypes() async {
    if (_materialTypes != null) return _materialTypes!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/material_types.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _materialTypes = jsonList.map((json) => MaterialType.fromJson(json)).toList();
      return _materialTypes!;
    } catch (e) {
      print('Error loading material types: $e');
      _materialTypes = []; // Initialize empty list to prevent null issues
      return _materialTypes!;
    }
  }

  // Load ads from JSON
  Future<List<Ad>> loadAds() async {
    if (_ads != null) return _ads!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/ads.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _ads = jsonList.map((json) => Ad.fromJson(json)).toList();
      return _ads!;
    } catch (e) {
      print('Error loading ads: $e');
      _ads = []; // Initialize empty list to prevent null issues
      return _ads!;
    }
  }

  // Load transactions from JSON
  Future<List<Transaction>> loadTransactions() async {
    if (_transactions != null) return _transactions!;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/transactions.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
      return _transactions!;
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  // User-related methods
  Future<User?> getUserById(String id) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    final users = await loadUsers();
    return users.where((user) => user.role == role).toList();
  }

  // Material type methods
  Future<MaterialType?> getMaterialTypeById(String id) async {
    final materialTypes = await loadMaterialTypes();
    try {
      return materialTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<MaterialType>> getMaterialTypesByCategory(MaterialCategory category) async {
    final materialTypes = await loadMaterialTypes();
    return materialTypes.where((type) => type.category == category).toList();
  }

  // Ad-related methods
  Future<Ad?> getAdById(String id) async {
    final ads = await loadAds();
    try {
      return ads.firstWhere((ad) => ad.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Ad>> getAdsBySeller(String sellerId) async {
    final ads = await loadAds();
    return ads.where((ad) => ad.sellerId == sellerId).toList();
  }

  Future<List<Ad>> getAdsByMaterialType(String materialTypeId) async {
    final ads = await loadAds();
    return ads.where((ad) => ad.materialTypeId == materialTypeId).toList();
  }

  Future<List<Ad>> getActiveAds() async {
    final ads = await loadAds();
    return ads.where((ad) => ad.status == AdStatus.active).toList();
  }

  Future<List<Ad>> getFeaturedAds() async {
    final ads = await loadAds();
    return ads.where((ad) => ad.isFeatured && ad.status == AdStatus.active).toList();
  }

  // Transaction-related methods
  Future<Transaction?> getTransactionById(String id) async {
    final transactions = await loadTransactions();
    try {
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getTransactionsBySeller(String sellerId) async {
    final transactions = await loadTransactions();
    return transactions.where((transaction) => transaction.sellerId == sellerId).toList();
  }

  Future<List<Transaction>> getTransactionsByBuyer(String buyerId) async {
    final transactions = await loadTransactions();
    return transactions.where((transaction) => transaction.buyerId == buyerId).toList();
  }

  Future<List<Transaction>> getTransactionsByStatus(TransactionStatus status) async {
    final transactions = await loadTransactions();
    return transactions.where((transaction) => transaction.status == status).toList();
  }

  // Search and filter methods
  Future<List<Ad>> searchAds({
    String? query,
    String? materialTypeId,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    final ads = await getActiveAds();
    
    return ads.where((ad) {
      bool matches = true;
      
      if (query != null && query.isNotEmpty) {
        matches = matches && (
          ad.title.toLowerCase().contains(query.toLowerCase()) ||
          ad.description.toLowerCase().contains(query.toLowerCase())
        );
      }
      
      if (materialTypeId != null) {
        matches = matches && ad.materialTypeId == materialTypeId;
      }
      
      if (location != null && location.isNotEmpty) {
        matches = matches && ad.location.toLowerCase().contains(location.toLowerCase());
      }
      
      if (minPrice != null) {
        matches = matches && ad.pricePerUnit >= minPrice;
      }
      
      if (maxPrice != null) {
        matches = matches && ad.pricePerUnit <= maxPrice;
      }
      
      return matches;
    }).toList();
  }

  // Statistics methods
  Future<Map<String, dynamic>> getStatistics() async {
    final users = await loadUsers();
    final ads = await loadAds();
    final transactions = await loadTransactions();
    
    final activeAds = ads.where((ad) => ad.status == AdStatus.active).length;
    final completedTransactions = transactions.where((t) => t.status == TransactionStatus.completed).length;
    final totalRevenue = transactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.commissionAmount);
    
    return {
      'totalUsers': users.length,
      'totalSellers': users.where((u) => u.role == UserRole.seller).length,
      'totalBuyers': users.where((u) => u.role == UserRole.buyer).length,
      'totalAds': ads.length,
      'activeAds': activeAds,
      'totalTransactions': transactions.length,
      'completedTransactions': completedTransactions,
      'totalRevenue': totalRevenue,
    };
  }

  // Clear cache method
  void clearCache() {
    _users = null;
    _materialTypes = null;
    _ads = null;
    _transactions = null;
  }
}
