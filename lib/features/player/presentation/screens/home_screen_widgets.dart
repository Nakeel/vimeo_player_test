import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:udux_concerts_test/core/router/app_router.dart';
import 'package:udux_concerts_test/core/theme/app_theme.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';

class ScenarioCard extends StatelessWidget {
  final PlayerConfigEntity config;

  const ScenarioCard({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.player, extra: config),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _IconContainer(config: config),
              const SizedBox(width: 14),
              Expanded(child: _LabelColumn(config: config)),
              const SizedBox(width: 8),
              Icon(
                Icons.play_circle_outline,
                color: Colors.white.withValues(alpha: 0.5),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  final PlayerConfigEntity config;

  const _IconContainer({required this.config});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (config) {
      PlayerConfigEntity(isLive: true) => (
        Icons.sensors,
        AppTheme.liveBadgeColor,
      ),
      PlayerConfigEntity(isPrivate: true) => (
        Icons.lock_outline,
        const Color(0xFF7B2FBE),
      ),
      _ => (Icons.ondemand_video, const Color(0xFF7B2FBE)),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _LabelColumn extends StatelessWidget {
  final PlayerConfigEntity config;

  const _LabelColumn({required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          config.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _Pill(
              label: config.isLive ? 'LIVE' : 'VOD',
              color: config.isLive
                  ? AppTheme.liveBadgeColor
                  : const Color(0xFF00897B),
            ),
            if (config.isPrivate)
              const _Pill(label: 'PRIVATE', color: Color(0xFF7B2FBE)),
            Text(
              config.videoId,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
