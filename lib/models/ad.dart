enum AdStatus { active, sold, expired, pending, rejected }

class Ad {
  final String id;
  final String sellerId;
  final String materialTypeId;
  final String title;
  final String description;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalPrice;
  final List<String> images;
  final String location;
  final double? latitude;
  final double? longitude;
  final AdStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int views;
  final int inquiries;
  final bool isFeatured;

  Ad({
    required this.id,
    required this.sellerId,
    required this.materialTypeId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalPrice,
    this.images = const [],
    required this.location,
    this.latitude,
    this.longitude,
    this.status = AdStatus.active,
    required this.createdAt,
    this.expiresAt,
    this.views = 0,
    this.inquiries = 0,
    this.isFeatured = false,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      sellerId: json['sellerId'],
      materialTypeId: json['materialTypeId'],
      title: json['title'],
      description: json['description'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'],
      pricePerUnit: (json['pricePerUnit'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: AdStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AdStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      views: json['views'] ?? 0,
      inquiries: json['inquiries'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'materialTypeId': materialTypeId,
      'title': title,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'images': images,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'views': views,
      'inquiries': inquiries,
      'isFeatured': isFeatured,
    };
  }

  Ad copyWith({
    String? id,
    String? sellerId,
    String? materialTypeId,
    String? title,
    String? description,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? totalPrice,
    List<String>? images,
    String? location,
    double? latitude,
    double? longitude,
    AdStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? views,
    int? inquiries,
    bool? isFeatured,
  }) {
    return Ad(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      materialTypeId: materialTypeId ?? this.materialTypeId,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      images: images ?? this.images,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      views: views ?? this.views,
      inquiries: inquiries ?? this.inquiries,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
