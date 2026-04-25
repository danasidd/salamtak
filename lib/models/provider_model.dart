class ProviderModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String specialtyEn;
  final String specialtyAr;
  final String clinicNameEn;
  final String clinicNameAr;
  final String cityEn;
  final String cityAr;
  final List<String> insuranceAccepted;
  final List<String> languagesSpoken;
  final double rating;
  final int consultationFeeJOD;
  final String phone;
  final String avatarInitials;

  const ProviderModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.clinicNameEn,
    required this.clinicNameAr,
    required this.cityEn,
    required this.cityAr,
    required this.insuranceAccepted,
    required this.languagesSpoken,
    required this.rating,
    required this.consultationFeeJOD,
    required this.phone,
    required this.avatarInitials,
  });
}
