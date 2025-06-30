import 'package:flutter/foundation.dart';
import '../models/material_type.dart';
import '../services/data_service.dart';
import '../models/ad.dart';
import 'package:flutter/widgets.dart';

class MaterialProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  List<MaterialType> _materialTypes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MaterialType> get materialTypes => _materialTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all material types
  Future<void> loadMaterialTypes() async {
    _isLoading = true;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _materialTypes = await _dataService.loadMaterialTypes();
    } catch (e) {
      _errorMessage = 'Failed to load material types: ${e.toString()}';
      print('Material types loading error: $e');
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Get material type by ID
  MaterialType? getMaterialTypeById(String id) {
    try {
      return _materialTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get material types by category
  List<MaterialType> getMaterialTypesByCategory(MaterialCategory category) {
    return _materialTypes.where((type) => type.category == category).toList();
  }

  // Get active material types
  List<MaterialType> getActiveMaterialTypes() {
    return _materialTypes.where((type) => type.isActive).toList();
  }

  // Get all categories
  List<MaterialCategory> getAllCategories() {
    return _materialTypes
        .map((type) => type.category)
        .toSet()
        .toList();
  }

  // Get category display name
  String getCategoryDisplayName(MaterialCategory category, {bool isArabic = false}) {
    switch (category) {
      case MaterialCategory.plastic:
        return isArabic ? 'بلاستيك' : 'Plastic';
      case MaterialCategory.glass:
        return isArabic ? 'زجاج' : 'Glass';
      case MaterialCategory.paper:
        return isArabic ? 'ورق' : 'Paper';
      case MaterialCategory.cardboard:
        return isArabic ? 'كرتون' : 'Cardboard';
      case MaterialCategory.electronics:
        return isArabic ? 'إلكترونيات' : 'Electronics';
      case MaterialCategory.organic:
        return isArabic ? 'عضوي' : 'Organic';
      case MaterialCategory.metal:
        return isArabic ? 'معدن' : 'Metal';
      case MaterialCategory.textile:
        return isArabic ? 'منسوجات' : 'Textile';
      case MaterialCategory.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }

  // Search material types
  List<MaterialType> searchMaterialTypes(String query, {String locale = 'en'}) {
    if (query.isEmpty) return getActiveMaterialTypes();
    
    final lowercaseQuery = query.toLowerCase();
    return _materialTypes.where((type) {
      final nameToSearch = locale.startsWith('ar') ? type.nameAr : type.nameEn;
      return type.isActive && (
        nameToSearch.toLowerCase().contains(lowercaseQuery) ||
        type.description.toLowerCase().contains(lowercaseQuery)
      );
    }).toList();
  }

  // Get material types with statistics
  Future<List<Map<String, dynamic>>> getMaterialTypesWithStats() async {
    final ads = await _dataService.loadAds();
    
    return _materialTypes.map((type) {
      final typeAds = ads.where((ad) => ad.materialTypeId == type.id).toList();
      final activeAds = typeAds.where((ad) => ad.status == AdStatus.active).length;
      final totalQuantity = typeAds.fold(0.0, (sum, ad) => sum + ad.quantity);
      
      return {
        'materialType': type,
        'totalAds': typeAds.length,
        'activeAds': activeAds,
        'totalQuantity': totalQuantity,
        'averagePrice': type.averagePrice,
      };
    }).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh material types
  Future<void> refresh() async {
    _dataService.clearCache();
    await loadMaterialTypes();
  }
}
