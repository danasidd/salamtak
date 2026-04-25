import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../providers/language_provider.dart';
import '../widgets/triage_result_card.dart';
import 'provider_search_screen.dart';

enum TriageStep { bodyArea, symptoms, duration, severity, result }

enum BodyArea { head, chest, abdomen, limbs, skin, other }

enum SymptomDuration { today, twotoThreeDays, weekPlus }

enum Severity { mild, moderate, severe }

enum TriageOutcome { homeCare, seeGp, urgentCare }

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  TriageStep _step = TriageStep.bodyArea;
  BodyArea? _bodyArea;
  final Set<String> _selectedSymptoms = {};
  SymptomDuration? _duration;
  Severity? _severity;

  static const Map<BodyArea, List<String>> _symptomsMap = {
    BodyArea.head: [
      'Headache', 'Dizziness', 'Blurred vision', 'Ear pain', 'Nausea', 'Confusion',
    ],
    BodyArea.chest: [
      'Chest pain', 'Shortness of breath', 'Heart palpitations', 'Cough', 'Tightness',
    ],
    BodyArea.abdomen: [
      'Stomach pain', 'Nausea', 'Vomiting', 'Diarrhea', 'Constipation', 'Bloating',
    ],
    BodyArea.limbs: [
      'Joint pain', 'Muscle ache', 'Swelling', 'Numbness', 'Weakness', 'Cramps',
    ],
    BodyArea.skin: [
      'Rash', 'Itching', 'Redness', 'Dry skin', 'Blisters', 'Peeling',
    ],
    BodyArea.other: [
      'Fever', 'Fatigue', 'Loss of appetite', 'Weight loss', 'Night sweats', 'Chills',
    ],
  };

  static const Map<BodyArea, List<String>> _symptomsMapAr = {
    BodyArea.head: [
      'صداع', 'دوخة', 'رؤية ضبابية', 'ألم في الأذن', 'غثيان', 'تشوش',
    ],
    BodyArea.chest: [
      'ألم في الصدر', 'ضيق في التنفس', 'خفقان القلب', 'سعال', 'ضغط في الصدر',
    ],
    BodyArea.abdomen: [
      'ألم في المعدة', 'غثيان', 'قيء', 'إسهال', 'إمساك', 'انتفاخ',
    ],
    BodyArea.limbs: [
      'ألم في المفاصل', 'ألم عضلي', 'تورم', 'تنميل', 'ضعف', 'تشنجات',
    ],
    BodyArea.skin: [
      'طفح جلدي', 'حكة', 'احمرار', 'جفاف الجلد', 'بثور', 'تقشر',
    ],
    BodyArea.other: [
      'حمى', 'إرهاق', 'فقدان الشهية', 'فقدان الوزن', 'تعرق ليلي', 'قشعريرة',
    ],
  };

  TriageOutcome _computeOutcome() {
    if (_severity == Severity.severe) return TriageOutcome.urgentCare;
    if (_bodyArea == BodyArea.chest && _severity != Severity.mild) {
      return TriageOutcome.urgentCare;
    }
    if (_duration == SymptomDuration.weekPlus && _severity == Severity.moderate) {
      return TriageOutcome.seeGp;
    }
    if (_severity == Severity.moderate) return TriageOutcome.seeGp;
    if (_duration == SymptomDuration.twotoThreeDays) return TriageOutcome.seeGp;
    return TriageOutcome.homeCare;
  }

  String _recommendedSpecialty(bool isArabic) {
    switch (_bodyArea) {
      case BodyArea.head:
        return isArabic ? 'طب الأعصاب' : 'Neurology';
      case BodyArea.chest:
        return isArabic ? 'أمراض القلب' : 'Cardiology';
      case BodyArea.abdomen:
        return isArabic ? 'طب الجهاز الهضمي' : 'Gastroenterology';
      case BodyArea.limbs:
        return isArabic ? 'جراحة العظام' : 'Orthopedics';
      case BodyArea.skin:
        return isArabic ? 'أمراض الجلد' : 'Dermatology';
      default:
        return isArabic ? 'طب عام' : 'General Practice';
    }
  }

  void _goNext() {
    setState(() {
      switch (_step) {
        case TriageStep.bodyArea:
          if (_bodyArea != null) _step = TriageStep.symptoms;
          break;
        case TriageStep.symptoms:
          if (_selectedSymptoms.isNotEmpty) _step = TriageStep.duration;
          break;
        case TriageStep.duration:
          if (_duration != null) _step = TriageStep.severity;
          break;
        case TriageStep.severity:
          if (_severity != null) _step = TriageStep.result;
          break;
        case TriageStep.result:
          break;
      }
    });
  }

  void _goBack() {
    setState(() {
      switch (_step) {
        case TriageStep.symptoms:
          _step = TriageStep.bodyArea;
          break;
        case TriageStep.duration:
          _step = TriageStep.symptoms;
          break;
        case TriageStep.severity:
          _step = TriageStep.duration;
          break;
        case TriageStep.result:
          _step = TriageStep.severity;
          break;
        default:
          break;
      }
    });
  }

  void _startOver() {
    setState(() {
      _step = TriageStep.bodyArea;
      _bodyArea = null;
      _selectedSymptoms.clear();
      _duration = null;
      _severity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.symptomTriage,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: _step != TriageStep.bodyArea
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_step != TriageStep.result) _buildProgress(),
          Expanded(
            child: _buildStepContent(l10n, isArabic),
          ),
          if (_step != TriageStep.result)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _goNext : null,
                  child: Text(
                    _step == TriageStep.severity ? l10n.seeResult : l10n.next,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_step) {
      case TriageStep.bodyArea:
        return _bodyArea != null;
      case TriageStep.symptoms:
        return _selectedSymptoms.isNotEmpty;
      case TriageStep.duration:
        return _duration != null;
      case TriageStep.severity:
        return _severity != null;
      default:
        return false;
    }
  }

  Widget _buildProgress() {
    final steps = 4;
    final current = _step.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < steps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n, bool isArabic) {
    switch (_step) {
      case TriageStep.bodyArea:
        return _buildBodyAreaStep(l10n, isArabic);
      case TriageStep.symptoms:
        return _buildSymptomsStep(l10n, isArabic);
      case TriageStep.duration:
        return _buildDurationStep(l10n, isArabic);
      case TriageStep.severity:
        return _buildSeverityStep(l10n, isArabic);
      case TriageStep.result:
        return _buildResult(l10n, isArabic);
    }
  }

  Widget _buildBodyAreaStep(AppLocalizations l10n, bool isArabic) {
    final areas = [
      (BodyArea.head, l10n.bodyAreaHead, Icons.face_outlined),
      (BodyArea.chest, l10n.bodyAreaChest, Icons.favorite_border),
      (BodyArea.abdomen, l10n.bodyAreaAbdomen, Icons.circle_outlined),
      (BodyArea.limbs, l10n.bodyAreaLimbs, Icons.accessibility_new),
      (BodyArea.skin, l10n.bodyAreaSkin, Icons.pan_tool_outlined),
      (BodyArea.other, l10n.bodyAreaOther, Icons.more_horiz),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.selectBodyArea,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: areas.map((a) {
            final selected = _bodyArea == a.$1;
            return GestureDetector(
              onTap: () => setState(() {
                _bodyArea = a.$1;
                _selectedSymptoms.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.$3,
                        size: 32,
                        color: selected ? Colors.white : AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      a.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep(AppLocalizations l10n, bool isArabic) {
    final symptoms = isArabic
        ? _symptomsMapAr[_bodyArea!]!
        : _symptomsMap[_bodyArea!]!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.selectSymptoms,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: symptoms.map((s) {
            final selected = _selectedSymptoms.contains(s);
            return FilterChip(
              label: Text(s),
              selected: selected,
              onSelected: (val) => setState(() {
                if (val) {
                  _selectedSymptoms.add(s);
                } else {
                  _selectedSymptoms.remove(s);
                }
              }),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationStep(AppLocalizations l10n, bool isArabic) {
    final options = [
      (SymptomDuration.today, l10n.durationToday, Icons.today),
      (SymptomDuration.twotoThreeDays, l10n.duration2_3Days, Icons.date_range),
      (SymptomDuration.weekPlus, l10n.durationWeekPlus, Icons.calendar_month),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.selectDuration,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        ...options.map((o) {
          final selected = _duration == o.$1;
          return GestureDetector(
            onTap: () => setState(() => _duration = o.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(o.$3,
                      color: selected ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(width: 16),
                  Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeverityStep(AppLocalizations l10n, bool isArabic) {
    final options = [
      (Severity.mild, l10n.severityMild, AppColors.green, Icons.sentiment_satisfied),
      (Severity.moderate, l10n.severityModerate, AppColors.amber, Icons.sentiment_neutral),
      (Severity.severe, l10n.severitySevere, AppColors.red, Icons.sentiment_very_dissatisfied),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.selectSeverity,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        ...options.map((o) {
          final selected = _severity == o.$1;
          return GestureDetector(
            onTap: () => setState(() => _severity = o.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selected ? o.$3.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? o.$3 : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(o.$4, color: o.$3, size: 32),
                  const SizedBox(width: 16),
                  Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected ? o.$3 : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, color: o.$3),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResult(AppLocalizations l10n, bool isArabic) {
    final outcome = _computeOutcome();
    final specialty = _recommendedSpecialty(isArabic);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.triageResult,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        TriageResultCard(outcome: outcome, l10n: l10n),
        const SizedBox(height: 20),
        Container(
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
              Text(l10n.recommendedSpecialty,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 12)),
              const SizedBox(height: 8),
              Text(specialty,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProviderSearchScreen(
                        initialSpecialty:
                            isArabic ? null : specialty,
                      ),
                    ),
                  ),
                  child: Text(l10n.findSpecialistBtn(specialty)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _startOver,
          child: Text(l10n.startOver),
        ),
      ],
    );
  }
}
