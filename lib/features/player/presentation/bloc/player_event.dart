import 'package:equatable/equatable.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();
}

final class PlayerInitialised extends PlayerEvent {
  final PlayerConfigEntity config;
  const PlayerInitialised(this.config);
  @override
  List<Object?> get props => [config];
}

final class PlayerReadyReceived extends PlayerEvent {
  const PlayerReadyReceived();
  @override
  List<Object?> get props => [];
}

final class PlayerStarted extends PlayerEvent {
  const PlayerStarted();
  @override
  List<Object?> get props => [];
}

final class PlayerPaused extends PlayerEvent {
  const PlayerPaused();
  @override
  List<Object?> get props => [];
}

final class PlayerFinished extends PlayerEvent {
  const PlayerFinished();
  @override
  List<Object?> get props => [];
}

final class PlayerSeeked extends PlayerEvent {
  const PlayerSeeked();
  @override
  List<Object?> get props => [];
}

final class PlayerFullscreenEntered extends PlayerEvent {
  const PlayerFullscreenEntered();
  @override
  List<Object?> get props => [];
}

final class PlayerFullscreenExited extends PlayerEvent {
  const PlayerFullscreenExited();
  @override
  List<Object?> get props => [];
}

final class PlayerErrorOccurred extends PlayerEvent {
  final String message;
  const PlayerErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

final class PlayerPositionUpdated extends PlayerEvent {
  final Duration position;
  const PlayerPositionUpdated(this.position);
  @override
  List<Object?> get props => [position];
}
