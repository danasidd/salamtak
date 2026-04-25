import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_theme.dart';
import '../screens/triage_screen.dart';

class TriageResultCard extends StatelessWidget {
  final TriageOutcome outcome;
  final AppLocalizations l10n;

  const TriageResultCard({
    super.key,
    required this.outcome,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    late Color color;
    late Color bgColor;
    late IconData icon;
    late String title;
    late String advice;

    switch (outcome) {
      case TriageOutcome.homeCare:
        color = AppColors.green;
        bgColor = AppColors.green.withOpacity(0.1);
        icon = Icons.home_outlined;
        title = l10n.homeCare;
        advice = l10n.homeCareAdvice;
        break;
      case TriageOutcome.seeGp:
        color = AppColors.amber;
        bgColor = AppColors.amber.withOpacity(0.1);
        icon = Icons.person_outlined;
        title = l10n.seeGp;
        advice = l10n.gpAdvice;
        break;
      case TriageOutcome.urgentCare:
        color = AppColors.red;
        bgColor = AppColors.red.withOpacity(0.1);
        icon = Icons.emergency_outlined;
        title = l10n.urgentCare;
        advice = l10n.urgentAdvice;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            advice,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
