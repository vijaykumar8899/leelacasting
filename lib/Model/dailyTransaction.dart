class DailyTransaction {
  final int? dailyTransactionsId;
  final String generatedBarCode;
  final String name;
  final String phoneNumber;
  final String city;
  final int quantity;
  final double advanceGold;
  final double ornamentWeight;
  final double pendingGold;
  final String payables;
  final String receivables;
  final String active;
  final String transactionClosed;
  final String createdBy;
  final String createdDate;
  final String lastUpdatedBy;
  final String lastUpdatedTs;

  DailyTransaction({
    this.dailyTransactionsId,
    required this.generatedBarCode,
    required this.name,
    required this.phoneNumber,
    required this.city,
    required this.quantity,
    required this.advanceGold,
    required this.ornamentWeight,
    required this.pendingGold,
    required this.payables,
    required this.receivables,
    required this.active,
    required this.transactionClosed,
    required this.createdBy,
    required this.createdDate,
    required this.lastUpdatedBy,
    required this.lastUpdatedTs,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyTransactionsId': dailyTransactionsId,
      'generatedBarCode': generatedBarCode,
      'name': name,
      'phoneNumber': phoneNumber,
      'city': city,
      'quantity': quantity,
      'advanceGold': advanceGold,
      'ornamentWeight': ornamentWeight,
      'pendingGold': pendingGold,
      'payables': payables,
      'receivables': receivables,
      'active': active,
      'transactionClosed': transactionClosed,
      'createdBy': createdBy,
      'createdDate': createdDate,
      'lastUpdatedBy': lastUpdatedBy,
      'lastUpdatedTs': lastUpdatedTs,
    };
  }
}
