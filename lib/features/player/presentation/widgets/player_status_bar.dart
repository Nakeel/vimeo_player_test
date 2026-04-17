import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udux_concerts_test/core/theme/app_theme.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_bloc.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_state.dart';

class PlayerStatusBar extends StatelessWidget {
  const PlayerStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final (indicator, eventLabel, subLabel, vodPosition) = switch (state) {
          PlayerInitial() => (
            _Dot(color: Colors.grey.shade600),
            '—',
            'Idle',
            null,
          ),
          PlayerLoading(:final config) => (
            const SizedBox.square(
              dimension: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            config.label,
            'Loading…',
            null,
          ),
          PlayerReady(
            :final config,
            :final isPlaying,
            :final isFullscreen,
            :final position
          ) =>
            (
              _Dot(
                color: config.isLive
                    ? AppTheme.liveBadgeColor
                    : isPlaying
                        ? Colors.green
                        : Colors.grey,
              ),
              config.label,
              isFullscreen ? 'Fullscreen' : isPlaying ? 'Playing' : 'Ready',
              config.isLive ? null : position,
            ),
          PlayerEnded(:final config) => (
            _Dot(color: Colors.grey.shade600),
            config.label,
            'Ended',
            null,
          ),
          PlayerError(:final message) => (
            _Dot(color: Colors.red),
            'Error',
            message,
            null,
          ),
        };

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF111111),
          child: Row(
            children: [
              indicator,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eventLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (vodPosition != null)
                Text(
                  _formatDuration(vodPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
