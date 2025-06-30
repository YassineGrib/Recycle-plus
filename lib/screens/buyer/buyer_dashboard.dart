import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ad_provider.dart';
import '../../services/data_service.dart';
import '../../models/ad.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';
import '../../widgets/ad_card.dart';
import '../common/browse_ads_screen.dart';

class BuyerDashboard extends StatefulWidget {
  final int initialTab;
  
  const BuyerDashboard({super.key, this.initialTab = 0});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Ad> _featuredAds = [];
  List<Transaction> _myTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      final dataService = DataService();
      
      _featuredAds = await adProvider.getFeaturedAds();
      
      if (authProvider.currentUser != null) {
        _myTransactions = await dataService.getTransactionsByBuyer(
          authProvider.currentUser!.id,
        );
      }
    } catch (e) {
      print('Error loading buyer data: $e');
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
          'لوحة تحكم المشتري',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
              text: 'الرئيسية',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'مشترياتي',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'البحث',
            ),
          ],
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildPurchasesTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        final completedTransactions = _myTransactions
            .where((t) => t.status == TransactionStatus.completed)
            .length;
        final pendingTransactions = _myTransactions
            .where((t) => t.status == TransactionStatus.pending)
            .length;
        final totalSpent = _myTransactions
            .where((t) => t.status == TransactionStatus.completed)
            .fold(0.0, (sum, t) => sum + t.totalAmount);

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
                        backgroundColor: AppTheme.secondaryBlue,
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
                      'المشتريات المكتملة',
                      completedTransactions.toString(),
                      Icons.check_circle,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الطلبات المعلقة',
                      pendingTransactions.toString(),
                      Icons.pending,
                      AppTheme.recycleOrange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المبلغ المنفق',
                      '${totalSpent.toStringAsFixed(2)} \$',
                      Icons.attach_money,
                      AppTheme.secondaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المعاملات',
                      _myTransactions.length.toString(),
                      Icons.receipt,
                      AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Featured ads section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إعلانات مميزة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BrowseAdsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_featuredAds.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'لا توجد إعلانات مميزة حالياً',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredAds.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 300,
                        child: AdCard(ad: _featuredAds[index]),
                      );
                    },
                  ),
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
                        _tabController.animateTo(2);
                      },
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'البحث عن مواد',
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
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'عرض مشترياتي',
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

  Widget _buildPurchasesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مشتريات بعد',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textLight,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بتصفح الإعلانات المتاحة',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(2);
              },
              child: const Text(
                'تصفح الإعلانات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _myTransactions[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(transaction.status),
                child: Icon(
                  _getStatusIcon(transaction.status),
                  color: Colors.white,
                ),
              ),
              title: Text(
                'معاملة #${transaction.id.substring(0, transaction.id.length < 8 ? transaction.id.length : 8)}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكمية: ${transaction.quantity} ${transaction.pricePerUnit}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  Text(
                    'المبلغ: ${transaction.totalAmount.toStringAsFixed(2)} \$',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  _getStatusText(transaction.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _getStatusColor(transaction.status),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTab() {
    return const BrowseAdsScreen();
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
                fontSize: 20,
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

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppTheme.recycleOrange;
      case TransactionStatus.confirmed:
        return AppTheme.secondaryBlue;
      case TransactionStatus.completed:
        return AppTheme.primaryGreen;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.pending;
      case TransactionStatus.confirmed:
        return Icons.check;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'معلق';
      case TransactionStatus.confirmed:
        return 'مؤكد';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.cancelled:
        return 'ملغي';
    }
  }
}
