enum MaterialCategory {
  plastic,
  glass,
  paper,
  cardboard,
  electronics,
  organic,
  metal,
  textile,
  other
}

class MaterialType {
  final String id;
  final String nameEn;
  final String nameAr;
  final MaterialCategory category;
  final String description;
  final String? icon;
  final String unit; // kg, ton, piece, etc.
  final double averagePrice; // per unit
  final bool isActive;

  MaterialType({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.description,
    this.icon,
    required this.unit,
    required this.averagePrice,
    this.isActive = true,
  });

  factory MaterialType.fromJson(Map<String, dynamic> json) {
    return MaterialType(
      id: json['id'],
      nameEn: json['nameEn'],
      nameAr: json['nameAr'],
      category: MaterialCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      description: json['description'],
      icon: json['icon'],
      unit: json['unit'],
      averagePrice: (json['averagePrice'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'category': category.toString().split('.').last,
      'description': description,
      'icon': icon,
      'unit': unit,
      'averagePrice': averagePrice,
      'isActive': isActive,
    };
  }

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? nameAr : nameEn;
  }
}
