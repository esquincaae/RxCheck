class Medication {
  final int id;
  final String text;
  bool supplied;
  bool wasSuppliedInitially;
  Medication({ required this.id, required this.text, required this.supplied, this.wasSuppliedInitially = false});

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(id: json['id'], text: json['text'], supplied: json['supplied']);
  }
}

class Recip {
  final String qrImage;
  final List<Medication> medications;

  Recip({
    required this.qrImage,
    required this.medications,
  });

  factory Recip.fromJson(Map<String, dynamic> json) {
    var medsJson = json['medications'] as List<dynamic>;
    List<Medication> meds = medsJson.map((m) => Medication.fromJson(m)).toList();

    return Recip(
      qrImage: json['qr_image'],
      medications: meds,
    );
  }
}
