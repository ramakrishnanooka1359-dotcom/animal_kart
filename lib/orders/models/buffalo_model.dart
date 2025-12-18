class BuffaloModel {
  final String id;
  final String? parentId;
  final String breedId;
  final double ageYears;
  final String status;
  final String type;
  final int assetValue;

  final DateTime? cpfDueDate;
  final DateTime? expectedMaturationDate;

  final String shedNumber;
  final String farmName;
  final String farmLocation;
  final String healthStatus;

  BuffaloModel({
    required this.id,
    this.parentId,
    required this.breedId,
    required this.ageYears,
    required this.status,
    required this.type,
    required this.assetValue,
    this.cpfDueDate,
    this.expectedMaturationDate,
    required this.shedNumber,
    required this.farmName,
    required this.farmLocation,
    required this.healthStatus,
  });

  factory BuffaloModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.parse(value);
    }

    return BuffaloModel(
      id: json['id'] ?? '',
      parentId: json['parentId'],
      breedId: json['breedId'] ?? '',
      ageYears: (json['ageYears'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      assetValue: parseInt(json['assetValue']),
      cpfDueDate: parseDate(json['cpfDueDate']),
      expectedMaturationDate: parseDate(json['expectedMaturationDate']),
      shedNumber: json['shedNumber'] ?? '',
      farmName: json['farmName'] ?? '',
      farmLocation: json['farmLocation'] ?? '',
      healthStatus: json['healthStatus'] ?? '',
    );
  }
}

int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
