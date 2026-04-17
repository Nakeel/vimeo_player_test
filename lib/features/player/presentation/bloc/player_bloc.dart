import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udux_concerts_test/core/utils/app_logger.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_event.dart';
import 'package:udux_concerts_test/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerInitial()) {
    on<PlayerInitialised>(_onInitialised);
    on<PlayerReadyReceived>(_onReady);
    on<PlayerStarted>(_onStarted);
    on<PlayerPaused>(_onPaused);
    on<PlayerFinished>(_onFinished);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerFullscreenEntered>(_onFullscreenEntered);
    on<PlayerFullscreenExited>(_onFullscreenExited);
    on<PlayerErrorOccurred>(_onError);
    on<PlayerPositionUpdated>(_onPositionUpdated);
  }

  void _onInitialised(PlayerInitialised event, Emitter<PlayerState> emit) {
    AppLogger.i('PlayerBloc: initialised — ${event.config.label}');
    emit(PlayerLoading(event.config));
  }

  void _onReady(PlayerReadyReceived event, Emitter<PlayerState> emit) {
    final current = state;
    if (current is! PlayerLoading) return;
    AppLogger.i('PlayerBloc: ready');
    emit(PlayerReady(config: current.config));
  }

  void _onStarted(PlayerStarted event, Emitter<PlayerState> emit) {
    final current = state;
    if (current is! PlayerReady) return;
    AppLogger.d('PlayerBloc: started');
    emit(current.copyWith(isPlaying: true));
  }

  void _onPaused(PlayerPaused event, Emitter<PlayerState> emit) {
    final current = state;
    if (current is! PlayerReady) return;
    AppLogger.d('PlayerBloc: paused');
    emit(current.copyWith(isPlaying: false));
  }

  void _onFinished(PlayerFinished event, Emitter<PlayerState> emit) {
    AppLogger.i('PlayerBloc: finished');
    final current = state;
    if (current is PlayerReady) {
      emit(PlayerEnded(current.config));
    } else if (current is PlayerLoading) {
      emit(PlayerEnded(current.config));
    }
  }

  void _onSeeked(PlayerSeeked event, Emitter<PlayerState> emit) {
    AppLogger.d('PlayerBloc: seeked');
  }

  void _onFullscreenEntered(
    PlayerFullscreenEntered event,
    Emitter<PlayerState> emit,
  ) {
    final current = state;
    if (current is! PlayerReady) return;
    AppLogger.d('PlayerBloc: fullscreen entered');
    emit(current.copyWith(isFullscreen: true));
  }

  void _onFullscreenExited(
    PlayerFullscreenExited event,
    Emitter<PlayerState> emit,
  ) {
    final current = state;
    if (current is! PlayerReady) return;
    AppLogger.d('PlayerBloc: fullscreen exited');
    emit(current.copyWith(isFullscreen: false));
  }

  void _onError(PlayerErrorOccurred event, Emitter<PlayerState> emit) {
    AppLogger.e('PlayerBloc: error — ${event.message}');
    emit(PlayerError(event.message));
  }

  void _onPositionUpdated(
    PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) {
    final current = state;
    if (current is! PlayerReady) return;
    emit(current.copyWith(position: event.position));
  }
}
