class Record {
  double amount;
  int isIncome;
  String date;

  final String createdAt;
  final String? updatedAt;

  Record(
      {
      required this.amount,
      required this.isIncome,
      required this.date,
      required this.createdAt,
      this.updatedAt});
}
