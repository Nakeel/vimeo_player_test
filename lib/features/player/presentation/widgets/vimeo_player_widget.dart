import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_bloc.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_event.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_state.dart';
import 'package:udux_concerts_test/features/player/presentation/widgets/player_error_view.dart';

class VimeoPlayerWidget extends StatelessWidget {
  final PlayerConfigEntity config;

  const VimeoPlayerWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) => switch (state) {
        PlayerError(:final message) => PlayerErrorView(
            message: message,
            onRetry: () => bloc.add(PlayerInitialised(config)),
          ),
        PlayerEnded(:final config) => PlayerEndedView(
            label: config.label,
            onReplay: () => bloc.add(PlayerInitialised(config)),
          ),
        _ => VimeoVideoPlayer(
            videoId: config.videoId,
            privacyHash: config.privacyHash,
            isAutoPlay: true,
            showControls: true,
            showTitle: false,
            showByline: false,
            enableDNT: true,
            backgroundColor: Colors.black,
            onReady: () => bloc.add(const PlayerReadyReceived()),
            onPlay: () => bloc.add(const PlayerStarted()),
            onPause: () => bloc.add(const PlayerPaused()),
            onFinish: () => bloc.add(const PlayerFinished()),
            onSeek: () => bloc.add(const PlayerSeeked()),
            onEnterFullscreen: (controller) =>
                bloc.add(const PlayerFullscreenEntered()),
            onExitFullscreen: (controller) =>
                bloc.add(const PlayerFullscreenExited()),
            onInAppWebViewReceivedError: (controller, request, error) =>
                bloc.add(PlayerErrorOccurred(error.description)),
            currentPositionInSeconds: (position) => bloc.add(
              PlayerPositionUpdated(Duration(seconds: position.toInt())),
            ),
          ),
      },
    );
  }
}
