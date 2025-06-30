import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/material_provider.dart';
import '../../providers/ad_provider.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';
import '../seller/seller_dashboard.dart';
import '../buyer/buyer_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../common/browse_ads_screen.dart';
import '../common/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final materialProvider = Provider.of<MaterialProvider>(context, listen: false);
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    await Future.wait([
      materialProvider.loadMaterialTypes(),
      adProvider.loadActiveAds(),
    ]);
  }

  List<BottomNavigationBarItem> _getBottomNavItems(UserRole role) {
    switch (role) {
      case UserRole.seller:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'لوحة التحكم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'تصفح الإعلانات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'إضافة إعلان',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ];
      case UserRole.buyer:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'مشترياتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ];
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'الإدارة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمون',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ];
    }
  }

  Widget _getScreenForIndex(int index, UserRole role) {
    switch (role) {
      case UserRole.seller:
        switch (index) {
          case 0:
            return const SellerDashboard();
          case 1:
            return const BrowseAdsScreen();
          case 2:
            return const SellerDashboard(initialTab: 1); // Add ad tab
          case 3:
            return const ProfileScreen();
          default:
            return const SellerDashboard();
        }
      case UserRole.buyer:
        switch (index) {
          case 0:
            return const BuyerDashboard();
          case 1:
            return const BrowseAdsScreen();
          case 2:
            return const BuyerDashboard(initialTab: 1); // Purchases tab
          case 3:
            return const ProfileScreen();
          default:
            return const BuyerDashboard();
        }
      case UserRole.admin:
        switch (index) {
          case 0:
            return const AdminDashboard();
          case 1:
            return const AdminDashboard(initialTab: 1); // Statistics tab
          case 2:
            return const AdminDashboard(initialTab: 2); // Users tab
          case 3:
            return const ProfileScreen();
          default:
            return const AdminDashboard();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.currentUser!;
        final bottomNavItems = _getBottomNavItems(user.role);

        return Scaffold(
          body: _getScreenForIndex(_currentIndex, user.role),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: bottomNavItems,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: AppTheme.textLight,
            backgroundColor: Colors.white,
            elevation: 8,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
            ),
          ),
          drawer: _buildDrawer(context, user),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.name,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('تصفح الإعلانات', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrowseAdsScreen()),
              );
            },
          ),
          
          if (user.role == UserRole.seller) ...[
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('إضافة إعلان', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
          ],
          
          if (user.role == UserRole.admin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('لوحة الإدارة', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('الإحصائيات', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
          ],
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('المساعدة', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red, fontFamily: 'Cairo'),
            ),
            onTap: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
