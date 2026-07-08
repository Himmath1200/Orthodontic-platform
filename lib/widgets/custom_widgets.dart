import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Primary Button ───────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppGradients.primaryGradient,
          color: isLoading ? AppColors.gray300 : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Secondary Button ─────────────────────────────────────────────────────

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final IconData? icon;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(text),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Card ──────────────────────────────────────────────────────────

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return Material(
      color: backgroundColor ?? Theme.of(context).cardColor,
      borderRadius: radius,
      elevation: elevation ?? 0,
      shadowColor: AppColors.primary.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withOpacity(0.06),
        highlightColor: AppColors.primary.withOpacity(0.03),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? valueColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.backgroundColor,
    this.valueColor,
    this.icon,
    this.onTap,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDecorations.cardShadow,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: (valueColor ?? AppColors.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon,
                        color: valueColor ?? AppColors.primary, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Risk Badge ───────────────────────────────────────────────────────────

class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final double score;

  const RiskBadge({Key? key, required this.riskLevel, required this.score})
      : super(key: key);

  Color _color() {
    if (score >= 75) return AppColors.riskLow;
    if (score >= 50) return AppColors.riskModerate;
    if (score >= 25) return AppColors.riskHigh;
    return AppColors.riskCritical;
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            riskLevel,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Predictability Indicator ─────────────────────────────────────────────

class PredictabilityIndicator extends StatelessWidget {
  final double score;
  final String label;

  const PredictabilityIndicator(
      {Key? key, required this.score, required this.label})
      : super(key: key);

  Color _color() {
    if (score >= 75) return AppColors.predictabilityHigh;
    if (score >= 50) return AppColors.predictabilityModerate;
    if (score >= 25) return AppColors.predictabilityRisk;
    return AppColors.predictabilityHR;
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: score / 100,
                color: c,
                backgroundColor: c.withOpacity(0.15),
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Tooth Visualization ─────────────────────────────────────────────────

class ToothVisualization extends StatelessWidget {
  final int toothNumber;
  final String status;
  final double score;
  final VoidCallback? onTap;

  const ToothVisualization({
    Key? key,
    required this.toothNumber,
    required this.status,
    required this.score,
    this.onTap,
  }) : super(key: key);

  Color _statusColor() {
    switch (status) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.secondary;
      case 'Moderate':
        return AppColors.warning;
      case 'HighRisk':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor();
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withOpacity(0.12),
              border: Border.all(color: c, width: 2),
              boxShadow: [
                BoxShadow(color: c.withOpacity(0.25), blurRadius: 8),
              ],
            ),
            child: Center(
              child: Text(
                toothNumber.toString(),
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Message ────────────────────────────────────────────────────────

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorMessage({Key? key, required this.message, this.onDismiss})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded,
                  color: AppColors.error, size: 18),
            ),
        ],
      ),
    );
  }
}

// ─── Success Message ──────────────────────────────────────────────────────

class SuccessMessage extends StatelessWidget {
  final String message;

  const SuccessMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Banner ─────────────────────────────────────────────────────────

class InfoBanner extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const InfoBanner({Key? key, required this.message, this.icon, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        border: Border.all(color: c.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info_outline_rounded, color: c, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Shimmer Loading Card ─────────────────────────────────────────────────

class ShimmerCard extends StatefulWidget {
  final double height;
  const ShimmerCard({Key? key, this.height = 80}) : super(key: key);

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: [
              AppColors.gray100,
              AppColors.gray50,
              AppColors.gray200,
              AppColors.gray50,
              AppColors.gray100,
            ],
          ),
        ),
      ),
    );
  }
}
