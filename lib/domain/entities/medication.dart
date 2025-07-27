class Medication {
  final int id;
  final String text;
  bool supplied;
  bool wasSuppliedInitially;

  Medication({
    required this.id,
    required this.text,
    required this.supplied,
    this.wasSuppliedInitially = false,
  });
}
