import 'package:flutter/material.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';
import 'package:udux_concerts_test/features/player/presentation/screens/custom_video_entry.dart';
import 'package:udux_concerts_test/features/player/presentation/screens/home_screen_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _scenarios = [
    PlayerConfigEntity(
      videoId: '76979871',
      mode: PlayerMode.vod,
      label: 'VOD — Public',
    ),
    PlayerConfigEntity(
      videoId: '148751763',
      mode: PlayerMode.vod,
      label: 'VOD — Public (Regression)',
    ),
    PlayerConfigEntity(
      videoId: 'replace_with_real_video_id',
      mode: PlayerMode.vod,
      label: 'VOD — Private',
      privacyHash: 'replace_with_real_hash',
    ),
    PlayerConfigEntity(
      videoId: 'replace_with_live_event_id',
      mode: PlayerMode.live,
      label: 'Live Stream',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vimeo Player — Test Harness')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(label: 'TEST SCENARIOS'),
          const SizedBox(height: 12),
          ..._scenarios.map(
            (config) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ScenarioCard(config: config),
            ),
          ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'CUSTOM VIDEO ID'),
          const SizedBox(height: 12),
          const CustomVideoEntry(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }
}
