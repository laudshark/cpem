import 'package:flutter/material.dart';

enum PageHeaderVariant {
  plain,
  spotlight,
}

class PageHeaderHighlight {
  const PageHeaderHighlight({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    this.headerVariant = PageHeaderVariant.spotlight,
    this.eyebrow,
    this.headerIcon,
    this.accentColor,
    this.highlights = const [],
    this.statusLabel,
    this.statusColor,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final PageHeaderVariant headerVariant;
  final String? eyebrow;
  final IconData? headerIcon;
  final Color? accentColor;
  final List<PageHeaderHighlight> highlights;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE7F4EF),
            Color(0xFFF5F1E8),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: headerVariant == PageHeaderVariant.spotlight
                  ? _SpotlightHeader(
                      title: title,
                      subtitle: subtitle,
                      actions: actions,
                      eyebrow: eyebrow,
                      headerIcon: headerIcon,
                      accentColor:
                          accentColor ?? Theme.of(context).colorScheme.primary,
                      highlights: highlights,
                      statusLabel: statusLabel,
                      statusColor: statusColor,
                    )
                  : _PlainHeader(
                      title: title,
                      subtitle: subtitle,
                      actions: actions,
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    );
  }
}

class _PlainHeader extends StatelessWidget {
  const _PlainHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions,
          ),
      ],
    );
  }
}

class _SpotlightHeader extends StatelessWidget {
  const _SpotlightHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.accentColor,
    required this.highlights,
    this.eyebrow,
    this.headerIcon,
    this.statusLabel,
    this.statusColor,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final String? eyebrow;
  final IconData? headerIcon;
  final Color accentColor;
  final List<PageHeaderHighlight> highlights;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final deepColor = Color.lerp(accentColor, const Color(0xFF112437), 0.72)!;
    final edgeColor = Color.lerp(accentColor, const Color(0xFF07131F), 0.48)!;
    final badgeColor = statusColor ?? const Color(0xFFBBF7D0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            deepColor,
            edgeColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -38,
            right: -12,
            child: _HeaderGlow(
              size: 150,
              color: accentColor.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: -72,
            left: -34,
            child: _HeaderGlow(
              size: 180,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 960;
                final actionPanelWidth =
                    constraints.maxWidth > 1240 ? 320.0 : 280.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _HeaderContent(
                              title: title,
                              subtitle: subtitle,
                              eyebrow: eyebrow,
                              statusLabel: statusLabel,
                              badgeColor: badgeColor,
                              headerIcon: headerIcon,
                            ),
                          ),
                          if (actions.isNotEmpty) ...[
                            const SizedBox(width: 20),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 232,
                                maxWidth: actionPanelWidth,
                              ),
                              child: _HeaderActionPanel(
                                actions: actions,
                                expand: false,
                              ),
                            ),
                          ],
                        ],
                      )
                    else ...[
                      _HeaderContent(
                        title: title,
                        subtitle: subtitle,
                        eyebrow: eyebrow,
                        statusLabel: statusLabel,
                        badgeColor: badgeColor,
                        headerIcon: headerIcon,
                      ),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _HeaderActionPanel(
                          actions: actions,
                          expand: true,
                        ),
                      ],
                    ],
                    if (highlights.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _HeaderHighlightGrid(highlights: highlights),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    this.eyebrow,
    this.statusLabel,
    this.headerIcon,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final String? statusLabel;
  final Color badgeColor;
  final IconData? headerIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (eyebrow != null)
              _HeaderBadge(
                label: eyebrow!,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                textColor: Colors.white,
              ),
            if (statusLabel != null)
              _HeaderBadge(
                label: statusLabel!,
                backgroundColor: badgeColor.withValues(alpha: 0.18),
                textColor: badgeColor,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (headerIcon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  headerIcon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActionPanel extends StatelessWidget {
  const _HeaderActionPanel({
    required this.actions,
    required this.expand,
  });

  final List<Widget> actions;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          OverflowBar(
            spacing: 10,
            overflowSpacing: 10,
            alignment: expand ? MainAxisAlignment.start : MainAxisAlignment.end,
            overflowAlignment:
                expand ? OverflowBarAlignment.start : OverflowBarAlignment.end,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _HeaderHighlightGrid extends StatelessWidget {
  const _HeaderHighlightGrid({
    required this.highlights,
  });

  final List<PageHeaderHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final columns =
            _columnsForWidth(constraints.maxWidth, highlights.length);
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final highlight in highlights)
              SizedBox(
                width: itemWidth,
                child: _HeaderHighlightCard(highlight: highlight),
              ),
          ],
        );
      },
    );
  }

  int _columnsForWidth(double width, int count) {
    if (width >= 1080 && count >= 3) {
      return 3;
    }

    if (width >= 680 && count >= 2) {
      return 2;
    }

    return 1;
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
            ),
      ),
    );
  }
}

class _HeaderHighlightCard extends StatelessWidget {
  const _HeaderHighlightCard({required this.highlight});

  final PageHeaderHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highlight.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            highlight.value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
