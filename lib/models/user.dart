enum UserRole { seller, buyer, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String location;
  final String? profileImage;
  final double rating;
  final int totalTransactions;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.location,
    this.profileImage,
    this.rating = 0.0,
    this.totalTransactions = 0,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      location: json['location'],
      profileImage: json['profileImage'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'location': location,
      'profileImage': profileImage,
      'rating': rating,
      'totalTransactions': totalTransactions,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? location,
    String? profileImage,
    double? rating,
    int? totalTransactions,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
