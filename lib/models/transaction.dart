enum TransactionStatus { pending, confirmed, completed, cancelled }

class Transaction {
  final String id;
  final String adId;
  final String sellerId;
  final String buyerId;
  final double quantity;
  final double pricePerUnit;
  final double totalAmount;
  final double commissionRate;
  final double commissionAmount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? cancellationReason;

  Transaction({
    required this.id,
    required this.adId,
    required this.sellerId,
    required this.buyerId,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    this.commissionRate = 0.05, // 5% default commission
    required this.commissionAmount,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.notes,
    this.cancellationReason,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      adId: json['adId'],
      sellerId: json['sellerId'],
      buyerId: json['buyerId'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      pricePerUnit: (json['pricePerUnit'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      commissionRate: (json['commissionRate'] ?? 0.05).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0.0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adId': adId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
    };
  }

  Transaction copyWith({
    String? id,
    String? adId,
    String? sellerId,
    String? buyerId,
    double? quantity,
    double? pricePerUnit,
    double? totalAmount,
    double? commissionRate,
    double? commissionAmount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    String? notes,
    String? cancellationReason,
  }) {
    return Transaction(
      id: id ?? this.id,
      adId: adId ?? this.adId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
