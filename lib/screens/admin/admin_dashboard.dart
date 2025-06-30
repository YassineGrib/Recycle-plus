import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/data_service.dart';
import '../../models/user.dart';
import '../../models/ad.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  final int initialTab;
  
  const AdminDashboard({super.key, this.initialTab = 0});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DataService _dataService = DataService();
  
  Map<String, dynamic> _statistics = {};
  List<User> _users = [];
  List<Ad> _ads = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final safeInitialTab = (widget.initialTab >= 0 && widget.initialTab < 3) ? widget.initialTab : 0;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: safeInitialTab,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
      final results = await Future.wait([
        _dataService.getStatistics(),
        _dataService.loadUsers(),
        _dataService.loadAds(),
        _dataService.loadTransactions(),
      ]);

      _statistics = results[0] as Map<String, dynamic>;
      _users = results[1] as List<User>;
      _ads = results[2] as List<Ad>;
      _transactions = results[3] as List<Transaction>;
    } catch (e) {
      print('Error loading admin data: $e');
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
          'لوحة تحكم الإدارة',
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
              icon: Icon(Icons.analytics),
              text: 'الإحصائيات',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'المستخدمون',
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
          _buildStatisticsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.recycleOrange,
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                          color: Colors.white,
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
                            const Text(
                              'مدير النظام',
                              style: TextStyle(
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
              const Text(
                'إحصائيات سريعة',
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
                      'إجمالي المستخدمين',
                      _statistics['totalUsers']?.toString() ?? '0',
                      Icons.people,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الإعلانات النشطة',
                      _statistics['activeAds']?.toString() ?? '0',
                      Icons.visibility,
                      AppTheme.secondaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'المعاملات المكتملة',
                      _statistics['completedTransactions']?.toString() ?? '0',
                      Icons.check_circle,
                      AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الإيرادات',
                      '${_statistics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'} \$',
                      Icons.attach_money,
                      AppTheme.recycleOrange,
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

  Widget _buildStatisticsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات مفصلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          
          // User statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات المستخدمين',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'البائعون',
                          _statistics['totalSellers']?.toString() ?? '0',
                          Icons.sell,
                          AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'المشترون',
                          _statistics['totalBuyers']?.toString() ?? '0',
                          Icons.shopping_cart,
                          AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ad statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات الإعلانات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الإعلانات',
                          _statistics['totalAds']?.toString() ?? '0',
                          Icons.list,
                          AppTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'الإعلانات النشطة',
                          _statistics['activeAds']?.toString() ?? '0',
                          Icons.visibility,
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transaction statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات المعاملات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي المعاملات',
                          _statistics['totalTransactions']?.toString() ?? '0',
                          Icons.receipt,
                          AppTheme.secondaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'المعاملات المكتملة',
                          _statistics['completedTransactions']?.toString() ?? '0',
                          Icons.check_circle,
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'إجمالي الإيرادات (العمولات)',
                    '${_statistics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'} \$',
                    Icons.attach_money,
                    AppTheme.recycleOrange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getUserRoleColor(user.role),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  Text(
                    _getUserRoleText(user.role),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${user.rating.toStringAsFixed(1)} ⭐',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${user.totalTransactions} معاملة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
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

  Color _getAdStatusColor(AdStatus status) {
    switch (status) {
      case AdStatus.active:
        return AppTheme.primaryGreen;
      case AdStatus.sold:
        return AppTheme.accentGreen;
      case AdStatus.expired:
        return AppTheme.textLight;
      case AdStatus.pending:
        return AppTheme.recycleOrange;
      case AdStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getAdStatusIcon(AdStatus status) {
    switch (status) {
      case AdStatus.active:
        return Icons.visibility;
      case AdStatus.sold:
        return Icons.check_circle;
      case AdStatus.expired:
        return Icons.schedule;
      case AdStatus.pending:
        return Icons.pending;
      case AdStatus.rejected:
        return Icons.cancel;
    }
  }

  Color _getTransactionStatusColor(TransactionStatus status) {
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

  IconData _getTransactionStatusIcon(TransactionStatus status) {
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

  Color _getUserRoleColor(UserRole role) {
    switch (role) {
      case UserRole.seller:
        return AppTheme.primaryGreen;
      case UserRole.buyer:
        return AppTheme.secondaryBlue;
      case UserRole.admin:
        return AppTheme.recycleOrange;
    }
  }

  String _getUserRoleText(UserRole role) {
    switch (role) {
      case UserRole.seller:
        return 'بائع';
      case UserRole.buyer:
        return 'مشتري';
      case UserRole.admin:
        return 'مدير';
    }
  }
}
