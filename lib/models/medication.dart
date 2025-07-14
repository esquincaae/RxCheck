class Medication {
  final String text;

  Medication({required this.text});

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(text: json['text']);
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
