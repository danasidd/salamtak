import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../data/mock_providers.dart';
import '../data/mock_insurers.dart';
import '../models/provider_model.dart';
import '../widgets/provider_card.dart';
import 'provider_profile_screen.dart';

class ProviderSearchScreen extends StatefulWidget {
  final String? initialSpecialty;
  const ProviderSearchScreen({super.key, this.initialSpecialty});

  @override
  State<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
}

class _ProviderSearchScreenState extends State<ProviderSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedCity;
  String? _selectedInsurance;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = widget.initialSpecialty;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProviderModel> _filtered(bool isArabic) {
    final query = _searchController.text.toLowerCase();
    return mockProviders.where((p) {
      final nameMatch = p.nameEn.toLowerCase().contains(query) ||
          p.nameAr.contains(query) ||
          p.specialtyEn.toLowerCase().contains(query) ||
          p.specialtyAr.contains(query) ||
          p.cityEn.toLowerCase().contains(query) ||
          p.cityAr.contains(query);

      bool specialtyMatch = true;
      if (_selectedSpecialty != null && _selectedSpecialty!.isNotEmpty) {
        specialtyMatch = isArabic
            ? p.specialtyAr == _selectedSpecialty
            : p.specialtyEn == _selectedSpecialty;
      }

      bool cityMatch = true;
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        cityMatch =
            isArabic ? p.cityAr == _selectedCity : p.cityEn == _selectedCity;
      }

      bool insuranceMatch = true;
      if (_selectedInsurance != null && _selectedInsurance!.isNotEmpty) {
        insuranceMatch = p.insuranceAccepted.contains(_selectedInsurance);
      }

      bool languageMatch = true;
      if (_selectedLanguage != null && _selectedLanguage!.isNotEmpty) {
        languageMatch = p.languagesSpoken.contains(_selectedLanguage);
      }

      return nameMatch && specialtyMatch && cityMatch && insuranceMatch && languageMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final filtered = _filtered(isArabic);
    final specialties = getSpecialties(isArabic);
    final cities = getCities(isArabic);
    final languages = getLanguages();

    final selectedInsuranceName = _selectedInsurance != null
        ? (isArabic
            ? mockInsurers
                .firstWhere((i) => i.id == _selectedInsurance,
                    orElse: () => mockInsurers.first)
                .nameAr
            : mockInsurers
                .firstWhere((i) => i.id == _selectedInsurance,
                    orElse: () => mockInsurers.first)
                .nameEn)
        : null;

    final selectedLanguageLabel = _selectedLanguage != null
        ? (isArabic
            ? translateLanguageToAr(_selectedLanguage!)
            : _selectedLanguage!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.providerSearch,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: _selectedSpecialty ?? l10n.specialty,
                  selected: _selectedSpecialty != null,
                  onTap: () => _showFilterSheet(
                    context,
                    title: l10n.specialty,
                    allLabel: l10n.allSpecialties,
                    options: specialties,
                    selected: _selectedSpecialty,
                    onSelect: (v) => setState(() => _selectedSpecialty = v),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _selectedCity ?? l10n.city,
                  selected: _selectedCity != null,
                  onTap: () => _showFilterSheet(
                    context,
                    title: l10n.city,
                    allLabel: l10n.allCities,
                    options: cities,
                    selected: _selectedCity,
                    onSelect: (v) => setState(() => _selectedCity = v),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: selectedInsuranceName ?? l10n.insurance,
                  selected: _selectedInsurance != null,
                  onTap: () => _showInsuranceSheet(context, l10n, isArabic),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: selectedLanguageLabel ?? l10n.filterLanguage,
                  selected: _selectedLanguage != null,
                  onTap: () => _showLanguageSheet(context, l10n, isArabic, languages),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(l10n.noProvidersFound,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(l10n.tryAdjustingFilters,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProviderProfileScreen(provider: filtered[i]),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: ProviderCard(provider: filtered[i], expanded: true),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context, {
    required String title,
    required String allLabel,
    required List<String> options,
    String? selected,
    required void Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(allLabel),
              leading: Icon(
                selected == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              onTap: () {
                onSelect(null);
                Navigator.pop(context);
              },
            ),
            ...options.map(
              (o) => ListTile(
                title: Text(o),
                leading: Icon(
                  selected == o ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                onTap: () {
                  onSelect(o);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showInsuranceSheet(BuildContext context, AppLocalizations l10n, bool isArabic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.insurance,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(l10n.allInsurance),
              leading: Icon(
                _selectedInsurance == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              onTap: () {
                setState(() => _selectedInsurance = null);
                Navigator.pop(context);
              },
            ),
            ...mockInsurers.map(
              (ins) => ListTile(
                title: Text(isArabic ? ins.nameAr : ins.nameEn),
                leading: Icon(
                  _selectedInsurance == ins.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _selectedInsurance = ins.id);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isArabic,
    List<String> languages,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.filterLanguage,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(l10n.allLanguages),
              leading: Icon(
                _selectedLanguage == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              onTap: () {
                setState(() => _selectedLanguage = null);
                Navigator.pop(context);
              },
            ),
            ...languages.map(
              (lang) => ListTile(
                title: Text(isArabic ? translateLanguageToAr(lang) : lang),
                leading: Icon(
                  _selectedLanguage == lang ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
