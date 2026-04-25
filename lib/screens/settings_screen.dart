import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/caregiver_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = context.watch<LanguageProvider>();
    final caregiver = context.watch<CaregiverProvider>();

    if (_nameController.text.isEmpty && caregiver.name.isNotEmpty) {
      _nameController.text = caregiver.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Language section
          _SectionHeader(title: l10n.language),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _LanguageOption(
                  label: l10n.english,
                  subtitle: 'English',
                  selected: !lang.isArabic,
                  onTap: () => lang.setLocale(const Locale('en')),
                ),
                const Divider(height: 1, indent: 16),
                _LanguageOption(
                  label: l10n.arabic,
                  subtitle: 'العربية',
                  selected: lang.isArabic,
                  onTap: () => lang.setLocale(const Locale('ar')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Caregiver mode section
          _SectionHeader(title: l10n.caregiverMode),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.caregiverMode,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l10n.caregiverModeDesc,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  value: caregiver.enabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    caregiver.setEnabled(val);
                    if (!val) setState(() {});
                  },
                ),
                if (caregiver.enabled) ...[
                  const Divider(height: 1, indent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.whoAreYouManaging,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: l10n.caregiverName,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: AppColors.primary),
                              onPressed: () {
                                caregiver.setName(_nameController.text.trim());
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (val) {
                            caregiver.setName(val.trim());
                          },
                        ),
                        if (caregiver.name.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_outline,
                                    color: AppColors.secondary, size: 18),
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
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // About section
          _SectionHeader(title: l10n.about),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Salamtak سلامتك',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${l10n.appVersion} 1.0.0',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  l10n.aboutText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Made with ❤️ for Jordan',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : const Icon(Icons.radio_button_unchecked, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
