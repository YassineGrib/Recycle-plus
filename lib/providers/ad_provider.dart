import 'package:flutter/foundation.dart';
import '../models/ad.dart';
import '../models/material_type.dart';
import '../services/data_service.dart';
import 'package:flutter/widgets.dart';

class AdProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  List<Ad> _ads = [];
  List<Ad> _filteredAds = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter parameters
  String _searchQuery = '';
  String? _selectedMaterialTypeId;
  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;
  AdStatus? _selectedStatus;

  List<Ad> get ads => _ads;
  List<Ad> get filteredAds => _filteredAds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String get searchQuery => _searchQuery;
  String? get selectedMaterialTypeId => _selectedMaterialTypeId;
  String? get selectedLocation => _selectedLocation;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  AdStatus? get selectedStatus => _selectedStatus;

  // Load all ads
  Future<void> loadAds() async {
    _isLoading = true;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _ads = await _dataService.loadAds();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load ads: ${e.toString()}';
      print('Ads loading error: $e');
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Get active ads only
  Future<void> loadActiveAds() async {
    _isLoading = true;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _ads = await _dataService.getActiveAds();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load active ads: ${e.toString()}';
      print('Active ads loading error: $e');
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Get featured ads
  Future<List<Ad>> getFeaturedAds() async {
    try {
      return await _dataService.getFeaturedAds();
    } catch (e) {
      print('Featured ads loading error: $e');
      return [];
    }
  }

  // Get ads by seller
  Future<List<Ad>> getAdsBySeller(String sellerId) async {
    try {
      return await _dataService.getAdsBySeller(sellerId);
    } catch (e) {
      print('Seller ads loading error: $e');
      return [];
    }
  }

  // Get ad by ID
  Future<Ad?> getAdById(String id) async {
    try {
      return await _dataService.getAdById(id);
    } catch (e) {
      print('Ad loading error: $e');
      return null;
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setMaterialTypeFilter(String? materialTypeId) {
    _selectedMaterialTypeId = materialTypeId;
    _applyFilters();
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _selectedLocation = location;
    _applyFilters();
    notifyListeners();
  }

  void setPriceFilter({double? minPrice, double? maxPrice}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(AdStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedMaterialTypeId = null;
    _selectedLocation = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAds = _ads.where((ad) {
      bool matches = true;

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        matches = matches && (
          ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ad.description.toLowerCase().contains(_searchQuery.toLowerCase())
        );
      }

      // Material type filter
      if (_selectedMaterialTypeId != null) {
        matches = matches && ad.materialTypeId == _selectedMaterialTypeId;
      }

      // Location filter
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        matches = matches && ad.location.toLowerCase().contains(_selectedLocation!.toLowerCase());
      }

      // Price filter
      if (_minPrice != null) {
        matches = matches && ad.pricePerUnit >= _minPrice!;
      }
      if (_maxPrice != null) {
        matches = matches && ad.pricePerUnit <= _maxPrice!;
      }

      // Status filter
      if (_selectedStatus != null) {
        matches = matches && ad.status == _selectedStatus;
      }

      return matches;
    }).toList();

    // Sort by creation date (newest first)
    _filteredAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Create new ad (for demo purposes)
  Future<bool> createAd({
    required String materialTypeId,
    required String title,
    required String description,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String location,
    List<String> images = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In a real app, you would send this to backend
      final newAd = Ad(
        id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
        sellerId: 'current_user', // Would get from auth provider
        materialTypeId: materialTypeId,
        title: title,
        description: description,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        totalPrice: quantity * pricePerUnit,
        images: images,
        location: location,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Add to local list for demo
      _ads.insert(0, newAd);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create ad: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update ad status
  Future<bool> updateAdStatus(String adId, AdStatus status) async {
    try {
      final adIndex = _ads.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _ads[adIndex] = _ads[adIndex].copyWith(status: status);
        _applyFilters();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update ad status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Increment ad views
  Future<void> incrementAdViews(String adId) async {
    try {
      final adIndex = _ads.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _ads[adIndex] = _ads[adIndex].copyWith(views: _ads[adIndex].views + 1);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to increment ad views: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh ads
  Future<void> refresh() async {
    _dataService.clearCache();
    await loadAds();
  }
}
