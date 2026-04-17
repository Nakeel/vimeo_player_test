import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udux_concerts_test/core/theme/app_theme.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_bloc.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_event.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_state.dart';
import 'package:udux_concerts_test/features/player/presentation/widgets/player_status_bar.dart';
import 'package:udux_concerts_test/features/player/presentation/widgets/vimeo_player_widget.dart';

class PlayerScreen extends StatefulWidget {
  final PlayerConfigEntity config;

  const PlayerScreen({super.key, required this.config});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc()..add(PlayerInitialised(widget.config)),
      child: _PlayerScreenBody(config: widget.config),
    );
  }
}

class _PlayerScreenBody extends StatelessWidget {
  final PlayerConfigEntity config;

  const _PlayerScreenBody({required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final isFullscreen = state is PlayerReady && state.isFullscreen;

        return Scaffold(
          appBar: isFullscreen
              ? null
              : AppBar(
                  title: Text(config.label),
                  actions: config.isLive ? [_LiveBadge()] : null,
                ),
          body: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: VimeoPlayerWidget(config: config),
              ),
              if (!isFullscreen) ...[
                const PlayerStatusBar(),
                _DebugInfoCard(config: config),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.liveBadgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DebugInfoCard extends StatelessWidget {
  final PlayerConfigEntity config;

  const _DebugInfoCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEBUG INFO',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Video ID', value: config.videoId),
          _InfoRow(label: 'Mode', value: config.isLive ? 'LIVE' : 'VOD'),
          _InfoRow(label: 'Private', value: config.isPrivate.toString()),
          if (config.isPrivate)
            _InfoRow(label: 'Hash', value: config.privacyHash!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
