import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedMaterialTypeId;
  String _selectedLocation = '';
  double _minPrice = 0.0;
  double _maxPrice = 100.0;
  RangeValues _priceRange = const RangeValues(0.0, 100.0);

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    _selectedMaterialTypeId = adProvider.selectedMaterialTypeId;
    _selectedLocation = adProvider.selectedLocation ?? '';
    _minPrice = adProvider.minPrice ?? 0.0;
    _maxPrice = adProvider.maxPrice ?? 100.0;

    // Ensure the range values are within bounds
    final startValue = _minPrice.clamp(0.0, 100.0);
    final endValue = _maxPrice.clamp(startValue, 100.0);
    _priceRange = RangeValues(startValue, endValue);
  }

  void _applyFilters() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    adProvider.setMaterialTypeFilter(_selectedMaterialTypeId);
    adProvider.setLocationFilter(_selectedLocation.isEmpty ? null : _selectedLocation);
    adProvider.setPriceFilter(
      minPrice: _priceRange.start == 0 ? null : _priceRange.start,
      maxPrice: _priceRange.end == 100 ? null : _priceRange.end,
    );
    
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedMaterialTypeId = null;
      _selectedLocation = '';
      _priceRange = const RangeValues(0.0, 100.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Material type filter
          const Text(
            'نوع المادة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          
          Consumer<MaterialProvider>(
            builder: (context, materialProvider, child) {
              final materialTypes = materialProvider.getActiveMaterialTypes();
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text(
                      'الكل',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    selected: _selectedMaterialTypeId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMaterialTypeId = selected ? null : _selectedMaterialTypeId;
                      });
                    },
                    backgroundColor: AppTheme.lightGreen,
                    selectedColor: AppTheme.primaryGreen,
                    checkmarkColor: Colors.white,
                  ),
                  ...materialTypes.map(
                    (materialType) => FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            materialType.icon ?? '📦',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            materialType.getLocalizedName('ar'),
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                      selected: _selectedMaterialTypeId == materialType.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMaterialTypeId = selected ? materialType.id : null;
                        });
                      },
                      backgroundColor: AppTheme.lightGreen,
                      selectedColor: AppTheme.primaryGreen,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Location filter
          const Text(
            'الموقع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'ابحث بالمدينة أو المنطقة...',
              hintStyle: TextStyle(fontFamily: 'Cairo'),
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: _selectedLocation),
          ),
          
          const SizedBox(height: 24),
          
          // Price range filter
          const Text(
            'نطاق السعر (دولار)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Text(
                '${_priceRange.start.round()}\$',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: _priceRange,
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  activeColor: AppTheme.primaryGreen,
                  inactiveColor: AppTheme.lightGreen,
                  onChanged: (values) {
                    setState(() {
                      // Ensure values are within bounds and start <= end
                      final start = values.start.clamp(0.0, 100.0);
                      final end = values.end.clamp(start, 100.0);
                      _priceRange = RangeValues(start, end);
                    });
                  },
                ),
              ),
              Text(
                '${_priceRange.end.round()}\$',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ],
          ),
          
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
