class CoverageModel {
  final String insurerId;
  final String serviceKey;
  final String status; // "covered", "not_covered", "referral_required"

  const CoverageModel({
    required this.insurerId,
    required this.serviceKey,
    required this.status,
  });
}
