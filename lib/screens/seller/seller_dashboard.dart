import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/material_provider.dart';
import '../../models/ad.dart';
import '../../utils/app_theme.dart';
import '../../widgets/ad_card.dart';
import 'add_ad_screen.dart';

class SellerDashboard extends StatefulWidget {
  final int initialTab;
  
  const SellerDashboard({super.key, this.initialTab = 0});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Ad> _myAds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadMyAds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyAds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        _myAds = await adProvider.getAdsBySeller(authProvider.currentUser!.id);
      }
    } catch (e) {
      print('Error loading seller ads: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم البائع',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'نظرة عامة',
            ),
            Tab(
              icon: Icon(Icons.add_circle),
              text: 'إضافة إعلان',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'إعلاناتي',
            ),
          ],
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAddAdTab(),
          _buildMyAdsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        final activeAds = _myAds.where((ad) => ad.status == AdStatus.active).length;
        final soldAds = _myAds.where((ad) => ad.status == AdStatus.sold).length;
        final totalViews = _myAds.fold(0, (sum, ad) => sum + ad.views);
        final totalInquiries = _myAds.fold(0, (sum, ad) => sum + ad.inquiries);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryGreen,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً، ${user.name}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تقييمك: ${user.rating.toStringAsFixed(1)} ⭐',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textLight,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics cards
              const Text(
                'إحصائياتك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'الإعلانات النشطة',
                      activeAds.toString(),
                      Icons.visibility,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الإعلانات المباعة',
                      soldAds.toString(),
                      Icons.check_circle,
                      AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المشاهدات',
                      totalViews.toString(),
                      Icons.remove_red_eye,
                      AppTheme.secondaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الاستفسارات',
                      totalInquiries.toString(),
                      Icons.message,
                      AppTheme.recycleOrange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick actions
              const Text(
                'إجراءات سريعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'إضافة إعلان جديد',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _tabController.animateTo(2);
                      },
                      icon: const Icon(Icons.list),
                      label: const Text(
                        'عرض إعلاناتي',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddAdTab() {
    return const AddAdScreen();
  }

  Widget _buildMyAdsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد إعلانات بعد',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textLight,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة إعلانك الأول',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text(
                'إضافة إعلان',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myAds.length,
        itemBuilder: (context, index) {
          return AdCard(
            ad: _myAds[index],
            showSellerActions: true,
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
