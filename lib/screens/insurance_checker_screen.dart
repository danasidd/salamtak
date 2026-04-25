import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../data/mock_insurers.dart';
import '../data/mock_coverage.dart';
import '../models/insurer_model.dart';

class InsuranceCheckerScreen extends StatefulWidget {
  const InsuranceCheckerScreen({super.key});

  @override
  State<InsuranceCheckerScreen> createState() => _InsuranceCheckerScreenState();
}

class _InsuranceCheckerScreenState extends State<InsuranceCheckerScreen> {
  InsurerModel? _selectedInsurer;
  final _serviceController = TextEditingController();
  String? _coverageStatus;
  bool _checked = false;

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  void _checkCoverage() {
    if (_selectedInsurer == null || _serviceController.text.trim().isEmpty) return;
    final status = lookupCoverage(
      _selectedInsurer!.id,
      _serviceController.text.trim(),
    );
    setState(() {
      _coverageStatus = status;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insuranceChecker,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Insurer dropdown
          _SectionLabel(label: l10n.selectInsurer),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<InsurerModel>(
                value: _selectedInsurer,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                hint: Text(
                  l10n.selectInsurer,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                items: mockInsurers.map((ins) {
                  return DropdownMenuItem(
                    value: ins,
                    child: Text(isArabic ? ins.nameAr : ins.nameEn),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _selectedInsurer = val;
                  _checked = false;
                  _coverageStatus = null;
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Service input
          _SectionLabel(label: l10n.selectService),
          const SizedBox(height: 8),
          TextField(
            controller: _serviceController,
            onChanged: (_) => setState(() {
              _checked = false;
              _coverageStatus = null;
            }),
            decoration: InputDecoration(
              hintText: l10n.selectService,
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
          // Quick service examples
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: serviceExamples.map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () {
                  _serviceController.text = s;
                  setState(() {
                    _checked = false;
                    _coverageStatus = null;
                  });
                },
                backgroundColor: AppColors.background,
                side: BorderSide(color: Colors.grey.shade300),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedInsurer != null &&
                      _serviceController.text.trim().isNotEmpty
                  ? _checkCoverage
                  : null,
              child: Text(l10n.checkCoverage),
            ),
          ),
          if (_checked) ...[
            const SizedBox(height: 28),
            Text(
              l10n.insuranceResult,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _CoverageResultCard(
              status: _coverageStatus,
              insurer: _selectedInsurer,
              service: _serviceController.text,
              l10n: l10n,
              isArabic: isArabic,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CoverageResultCard extends StatelessWidget {
  final String? status;
  final InsurerModel? insurer;
  final String service;
  final AppLocalizations l10n;
  final bool isArabic;

  const _CoverageResultCard({
    required this.status,
    required this.insurer,
    required this.service,
    required this.l10n,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'لا تتوفر معلومات عن هذه الخدمة مع هذا التأمين'
                  : 'No information available for this service with this insurer',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    late Color color;
    late Color bgColor;
    late IconData icon;
    late String label;

    switch (status) {
      case 'covered':
        color = AppColors.green;
        bgColor = AppColors.green.withOpacity(0.1);
        icon = Icons.check_circle_rounded;
        label = l10n.covered;
        break;
      case 'not_covered':
        color = AppColors.red;
        bgColor = AppColors.red.withOpacity(0.1);
        icon = Icons.cancel_rounded;
        label = l10n.notCovered;
        break;
      default: // referral_required
        color = AppColors.amber;
        bgColor = AppColors.amber.withOpacity(0.1);
        icon = Icons.warning_rounded;
        label = l10n.referralRequired;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: isArabic ? 'التأمين' : 'Insurer',
            value: isArabic ? insurer!.nameAr : insurer!.nameEn,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: isArabic ? 'الخدمة' : 'Service',
            value: service,
          ),
          if (status == 'referral_required') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isArabic
                    ? 'تحتاج إلى إحالة من طبيب عام قبل زيارة الأخصائي'
                    : 'You need a referral from a GP before seeing a specialist',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
