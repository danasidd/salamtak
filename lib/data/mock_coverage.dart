import '../models/coverage_model.dart';

const List<CoverageModel> mockCoverage = [
  // MedNet
  CoverageModel(insurerId: 'mednet', serviceKey: 'mri', status: 'covered'),
  CoverageModel(insurerId: 'mednet', serviceKey: 'dental', status: 'not_covered'),
  CoverageModel(insurerId: 'mednet', serviceKey: 'specialist', status: 'referral_required'),
  CoverageModel(insurerId: 'mednet', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'mednet', serviceKey: 'physiotherapy', status: 'referral_required'),
  // Al Nisr
  CoverageModel(insurerId: 'alnisr', serviceKey: 'mri', status: 'referral_required'),
  CoverageModel(insurerId: 'alnisr', serviceKey: 'dental', status: 'covered'),
  CoverageModel(insurerId: 'alnisr', serviceKey: 'specialist', status: 'covered'),
  CoverageModel(insurerId: 'alnisr', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'alnisr', serviceKey: 'physiotherapy', status: 'not_covered'),
  // Jordan Insurance
  CoverageModel(insurerId: 'jordan_insurance', serviceKey: 'mri', status: 'not_covered'),
  CoverageModel(insurerId: 'jordan_insurance', serviceKey: 'specialist', status: 'referral_required'),
  CoverageModel(insurerId: 'jordan_insurance', serviceKey: 'dental', status: 'not_covered'),
  CoverageModel(insurerId: 'jordan_insurance', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'jordan_insurance', serviceKey: 'physiotherapy', status: 'referral_required'),
  // Arabian Shield
  CoverageModel(insurerId: 'arabian_shield', serviceKey: 'mri', status: 'covered'),
  CoverageModel(insurerId: 'arabian_shield', serviceKey: 'dental', status: 'covered'),
  CoverageModel(insurerId: 'arabian_shield', serviceKey: 'specialist', status: 'covered'),
  CoverageModel(insurerId: 'arabian_shield', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'arabian_shield', serviceKey: 'physiotherapy', status: 'referral_required'),
  // Arab Orient
  CoverageModel(insurerId: 'arab_orient', serviceKey: 'mri', status: 'referral_required'),
  CoverageModel(insurerId: 'arab_orient', serviceKey: 'dental', status: 'not_covered'),
  CoverageModel(insurerId: 'arab_orient', serviceKey: 'specialist', status: 'referral_required'),
  CoverageModel(insurerId: 'arab_orient', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'arab_orient', serviceKey: 'physiotherapy', status: 'covered'),
  // Bupa
  CoverageModel(insurerId: 'bupa', serviceKey: 'mri', status: 'covered'),
  CoverageModel(insurerId: 'bupa', serviceKey: 'specialist', status: 'covered'),
  CoverageModel(insurerId: 'bupa', serviceKey: 'dental', status: 'covered'),
  CoverageModel(insurerId: 'bupa', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'bupa', serviceKey: 'physiotherapy', status: 'covered'),
  // MetLife
  CoverageModel(insurerId: 'metlife', serviceKey: 'mri', status: 'covered'),
  CoverageModel(insurerId: 'metlife', serviceKey: 'dental', status: 'referral_required'),
  CoverageModel(insurerId: 'metlife', serviceKey: 'specialist', status: 'covered'),
  CoverageModel(insurerId: 'metlife', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'metlife', serviceKey: 'physiotherapy', status: 'not_covered'),
  // Al Rajhi
  CoverageModel(insurerId: 'alrajhi', serviceKey: 'mri', status: 'not_covered'),
  CoverageModel(insurerId: 'alrajhi', serviceKey: 'dental', status: 'not_covered'),
  CoverageModel(insurerId: 'alrajhi', serviceKey: 'specialist', status: 'referral_required'),
  CoverageModel(insurerId: 'alrajhi', serviceKey: 'xray', status: 'covered'),
  CoverageModel(insurerId: 'alrajhi', serviceKey: 'physiotherapy', status: 'not_covered'),
];

String? lookupCoverage(String insurerId, String serviceQuery) {
  final query = serviceQuery.toLowerCase().trim();
  String? serviceKey;
  if (query.contains('mri') || query.contains('رنين') || query.contains('تصوير')) {
    serviceKey = 'mri';
  } else if (query.contains('dent') || query.contains('أسنان') || query.contains('dental')) {
    serviceKey = 'dental';
  } else if (query.contains('special') || query.contains('أخصائي') || query.contains('specialist')) {
    serviceKey = 'specialist';
  } else if (query.contains('xray') || query.contains('x-ray') || query.contains('أشعة') || query.contains('ray')) {
    serviceKey = 'xray';
  } else if (query.contains('physio') || query.contains('علاج طبيعي') || query.contains('therapy')) {
    serviceKey = 'physiotherapy';
  }
  if (serviceKey == null) return null;
  try {
    final result = mockCoverage.firstWhere(
      (c) => c.insurerId == insurerId && c.serviceKey == serviceKey,
    );
    return result.status;
  } catch (_) {
    return null;
  }
}

const List<String> serviceExamples = [
  'MRI', 'Dental', 'Specialist', 'X-Ray', 'Physiotherapy',
];
