import 'package:animal_kart_demo2/orders/models/buffalo_model.dart';

class OrderUnit {
  final String id;
  final String userId;
  final DateTime? userCreatedAt;
  final DateTime? paymentSessionDate;
  final String breedId;

  final int numUnits;
  final int buffaloCount;
  final int calfCount;

  final String? status;
  final String paymentStatus;
  final String? paymentType;

  final DateTime placedAt;
  final DateTime? approvalDate;

  final int baseUnitCost;
  final int cpfUnitCost;
  final int unitCost;
  final int totalCost;

  final bool withCpf;
  final List<BuffaloModel> buffalos;

  OrderUnit({
    required this.id,
    required this.userId,
    required this.userCreatedAt,
    required this.paymentSessionDate,
    required this.breedId,
    required this.numUnits,
    required this.buffaloCount,
    required this.calfCount,
    required this.status,
    required this.paymentStatus,
    required this.paymentType,
    required this.placedAt,
    required this.approvalDate,
    required this.baseUnitCost,
    required this.cpfUnitCost,
    required this.unitCost,
    required this.totalCost,
    required this.withCpf,
    required this.buffalos,
  });

  factory OrderUnit.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.parse(value);
    }

    return OrderUnit(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userCreatedAt: parseDate(json['userCreatedAt']),
      paymentSessionDate: parseDate(json['paymentSessionDate']),
      breedId: json['breedId'] ?? '',

      numUnits: parseInt(json['numUnits']),
      buffaloCount: parseInt(json['buffaloCount']),
      calfCount: parseInt(json['calfCount']),

      status: json['status'],
      paymentStatus: json['paymentStatus'] ?? 'UNKNOWN',
      paymentType: json['paymentType'],

      placedAt: DateTime.parse(json['placedAt']),
      approvalDate: parseDate(json['approvalDate']),

      baseUnitCost: parseInt(json['baseUnitCost']),
      cpfUnitCost: parseInt(json['cpfUnitCost']),
      unitCost: parseInt(json['unitCost']),
      totalCost: parseInt(json['totalCost']),

      withCpf: json['withCpf'] ?? false,

      buffalos: (json['buffalos'] as List? ?? [])
          .map((e) => BuffaloModel.fromJson(e))
          .toList(),
    );
  }
}




int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
