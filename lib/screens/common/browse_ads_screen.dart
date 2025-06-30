import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/material_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/ad_card.dart';
import '../../widgets/filter_bottom_sheet.dart';

class BrowseAdsScreen extends StatefulWidget {
  const BrowseAdsScreen({super.key});

  @override
  State<BrowseAdsScreen> createState() => _BrowseAdsScreenState();
}

class _BrowseAdsScreenState extends State<BrowseAdsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final materialProvider = Provider.of<MaterialProvider>(context, listen: false);
    
    await Future.wait([
      adProvider.loadActiveAds(),
      materialProvider.loadMaterialTypes(),
    ]);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تصفح الإعلانات',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن المواد...',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<AdProvider>(context, listen: false)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.lightGreen,
              ),
              onChanged: (value) {
                Provider.of<AdProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),
          
          // Filter chips
          Consumer2<AdProvider, MaterialProvider>(
            builder: (context, adProvider, materialProvider, child) {
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Clear filters chip
                    if (adProvider.searchQuery.isNotEmpty ||
                        adProvider.selectedMaterialTypeId != null ||
                        adProvider.selectedLocation != null ||
                        adProvider.minPrice != null ||
                        adProvider.maxPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text(
                            'مسح الفلاتر',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          onSelected: (selected) {
                            adProvider.clearFilters();
                          },
                          backgroundColor: Colors.red.shade100,
                          selectedColor: Colors.red.shade200,
                          checkmarkColor: Colors.red,
                        ),
                      ),
                    
                    // Material type chips
                    ...materialProvider.getActiveMaterialTypes().map(
                      (materialType) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            materialType.getLocalizedName('ar'),
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          selected: adProvider.selectedMaterialTypeId == materialType.id,
                          onSelected: (selected) {
                            adProvider.setMaterialTypeFilter(
                              selected ? materialType.id : null,
                            );
                          },
                          backgroundColor: AppTheme.lightGreen,
                          selectedColor: AppTheme.accentGreen,
                          checkmarkColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Ads list
          Expanded(
            child: Consumer<AdProvider>(
              builder: (context, adProvider, child) {
                if (adProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          adProvider.errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textLight,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => adProvider.refresh(),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final ads = adProvider.filteredAds;

                if (ads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد إعلانات متاحة',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textLight,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'جرب تغيير معايير البحث',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adProvider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      return AdCard(ad: ads[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
