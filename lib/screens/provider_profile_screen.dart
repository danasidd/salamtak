import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../data/mock_insurers.dart';
import '../models/provider_model.dart';

class ProviderProfileScreen extends StatelessWidget {
  final ProviderModel provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LanguageProvider>().isArabic;

    final name = isArabic ? provider.nameAr : provider.nameEn;
    final specialty = isArabic ? provider.specialtyAr : provider.specialtyEn;
    final clinicName = isArabic ? provider.clinicNameAr : provider.clinicNameEn;
    final city = isArabic ? provider.cityAr : provider.cityEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar and header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      provider.avatarInitials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    specialty,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Rating & Fee row
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.secondary,
                  label: l10n.rating,
                  value: provider.rating.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.primary,
                  label: l10n.consultationFee,
                  value: l10n.jodAmount(provider.consultationFeeJOD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clinic info
          _DetailSection(
            title: l10n.clinic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(Icons.local_hospital_outlined, clinicName),
                const SizedBox(height: 8),
                _DetailRow(Icons.location_on_outlined, city),
                const SizedBox(height: 8),
                _DetailRow(Icons.phone_outlined, provider.phone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Languages spoken
          _DetailSection(
            title: l10n.languagesSpoken,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.languagesSpoken.map((lang) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    isArabic ? _translateLanguage(lang) : lang,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Insurance plans
          _DetailSection(
            title: l10n.insurancePlans,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.insuranceAccepted.map((id) {
                try {
                  final insurer =
                      mockInsurers.firstWhere((i) => i.id == id);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isArabic ? insurer.nameAr : insurer.nameEn,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          // Action buttons
          ElevatedButton.icon(
            onPressed: () => _showBookingDialog(context, l10n),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(l10n.bookAppointment),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showCallDialog(context, l10n, provider.phone),
            icon: const Icon(Icons.phone_outlined),
            label: Text(l10n.callClinic),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _translateLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'arabic':
        return 'العربية';
      case 'english':
        return 'الإنجليزية';
      case 'french':
        return 'الفرنسية';
      case 'german':
        return 'الألمانية';
      default:
        return lang;
    }
  }

  void _showBookingDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.appointmentBooked),
          ],
        ),
        content: Text(l10n.appointmentBookedMsg),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(
      BuildContext context, AppLocalizations l10n, String phone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.callClinic),
          ],
        ),
        content: Text(phone,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
