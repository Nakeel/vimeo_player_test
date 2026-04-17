import 'package:equatable/equatable.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';

sealed class PlayerState extends Equatable {
  const PlayerState();
}

final class PlayerInitial extends PlayerState {
  const PlayerInitial();
  @override
  List<Object?> get props => [];
}

final class PlayerLoading extends PlayerState {
  final PlayerConfigEntity config;
  const PlayerLoading(this.config);
  @override
  List<Object?> get props => [config];
}

final class PlayerReady extends PlayerState {
  final PlayerConfigEntity config;
  final bool isPlaying;
  final bool isFullscreen;
  final Duration position;

  const PlayerReady({
    required this.config,
    this.isPlaying = false,
    this.isFullscreen = false,
    this.position = Duration.zero,
  });

  PlayerReady copyWith({
    PlayerConfigEntity? config,
    bool? isPlaying,
    bool? isFullscreen,
    Duration? position,
  }) =>
      PlayerReady(
        config: config ?? this.config,
        isPlaying: isPlaying ?? this.isPlaying,
        isFullscreen: isFullscreen ?? this.isFullscreen,
        position: position ?? this.position,
      );

  @override
  List<Object?> get props => [config, isPlaying, isFullscreen, position];
}

final class PlayerEnded extends PlayerState {
  final PlayerConfigEntity config;
  const PlayerEnded(this.config);
  @override
  List<Object?> get props => [config];
}

final class PlayerError extends PlayerState {
  final String message;
  const PlayerError(this.message);
  @override
  List<Object?> get props => [message];
}
