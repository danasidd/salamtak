import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/caregiver_provider.dart';
import '../data/mock_providers.dart';
import '../widgets/language_toggle.dart';
import '../widgets/provider_card.dart';
import 'provider_search_screen.dart';
import 'triage_screen.dart';
import 'insurance_checker_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final caregiver = context.watch<CaregiverProvider>();

    final featuredProviders = mockProviders.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'سلامتك' : 'Salamtak',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Greeting
          Text(
            _greeting(l10n),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          // Caregiver banner
          if (caregiver.enabled && caregiver.name.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.4), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.managingFor}: ${caregiver.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B4F00),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Search bar
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProviderSearchScreen()),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    l10n.searchHint,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Quick access title
          Text(
            l10n.quickAccess,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Quick access grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _QuickCard(
                icon: Icons.person_search_rounded,
                label: l10n.findDoctor,
                color: AppColors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderSearchScreen()),
                ),
              ),
              _QuickCard(
                icon: Icons.medical_information_outlined,
                label: l10n.symptomTriage,
                color: const Color(0xFF0D7377),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TriageScreen()),
                ),
              ),
              _QuickCard(
                icon: Icons.shield_outlined,
                label: l10n.insuranceChecker,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const InsuranceCheckerScreen()),
                ),
              ),
              _QuickCard(
                icon: Icons.people_outline,
                label: l10n.caregiverMode,
                color: AppColors.secondary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Featured providers title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.featuredProviders,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderSearchScreen()),
                ),
                child: Text(
                  isArabic ? 'عرض الكل' : 'View All',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featuredProviders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 200,
                  child: ProviderCard(provider: featuredProviders[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
