# Recycle Lebs - ريسايكل لبوس

A Flutter marketplace app for recyclable materials connecting sellers and buyers in Lebanon.

## Features

### 🌟 Core Features
- **Multi-role system**: Sellers, Buyers, and Admins
- **Offline functionality**: All data stored locally in JSON files
- **Arabic/English support**: Bilingual interface
- **Material categories**: Plastic, Glass, Paper, Electronics, etc.
- **Real-time search and filtering**
- **User authentication and profiles**

### 👥 User Roles

#### Sellers
- Create and manage ads for recyclable materials
- View dashboard with statistics
- Track views and inquiries
- Manage inventory and pricing

#### Buyers
- Browse and search for materials
- Filter by type, location, and price
- View detailed ad information
- Track purchase history

#### Admins
- System overview and statistics
- User management
- Ad moderation
- Revenue tracking

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd recycle_lebs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Demo Accounts

For testing purposes, use these demo accounts:

#### Seller Account
- **Email**: `ahmed@example.com`
- **Password**: `password`

#### Buyer Account
- **Email**: `fatima@example.com`
- **Password**: `password`

#### Admin Account
- **Email**: `admin@recyclelebs.com`
- **Password**: `password`

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── ad.dart
│   ├── material_type.dart
│   └── transaction.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── ad_provider.dart
│   └── material_provider.dart
├── screens/                  # UI screens
│   ├── auth/                 # Login/Register
│   ├── seller/               # Seller interface
│   ├── buyer/                # Buyer interface
│   ├── admin/                # Admin interface
│   └── common/               # Shared screens
├── widgets/                  # Reusable components
├── services/                 # Data services
├── utils/                    # Utilities and themes
└── assets/
    ├── data/                 # JSON data files
    └── images/               # App images
```

## 🎨 Design System

### Colors
- **Primary Green**: `#4CAF50` - Main brand color
- **Secondary Blue**: `#2196F3` - Accent color
- **Accent Green**: `#8BC34A` - Light green
- **Recycle Orange**: `#FF9800` - Warning/highlight
- **Background**: `#FAFAFA` - Light background

### Typography
- **Font Family**: Cairo (Arabic support)
- **Weights**: Regular (400), Bold (700)

## 📊 Data Structure

The app uses local JSON files for offline functionality:

### Sample Data Files
- `assets/data/users.json` - User accounts
- `assets/data/material_types.json` - Material categories
- `assets/data/ads.json` - Marketplace ads
- `assets/data/transactions.json` - Transaction history

## 🧪 Testing

Run tests with:
```bash
flutter test
```

### Test Coverage
- Widget tests for main components
- Unit tests for data models
- Validation tests for forms
- Theme and UI tests

## 🔧 Configuration

### Adding New Material Types
Edit `assets/data/material_types.json`:
```json
{
  "id": "mat_new",
  "nameEn": "New Material",
  "nameAr": "مادة جديدة",
  "category": "other",
  "description": "Description",
  "icon": "🔧",
  "unit": "kg",
  "averagePrice": 1.0,
  "isActive": true
}
```

### Customizing Theme
Modify `lib/utils/app_theme.dart` to change colors and styling.

## 📱 Screenshots

*Note: Add screenshots here when available*

## 🌍 Localization

The app supports:
- **Arabic**: Primary language for Lebanese users
- **English**: Secondary language for international users

## 🚀 Future Enhancements

- [ ] Real-time chat between buyers and sellers
- [ ] GPS integration for location services
- [ ] Push notifications
- [ ] Payment gateway integration
- [ ] Photo upload for ads
- [ ] Rating and review system
- [ ] Advanced analytics dashboard

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Email: support@recyclelebs.com
- GitHub Issues: [Create an issue](https://github.com/your-repo/issues)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI guidelines
- Lebanese recycling community for inspiration

---

**Made with ♻️ for a sustainable Lebanon**
