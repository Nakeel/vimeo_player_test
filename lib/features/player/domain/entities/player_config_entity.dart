import 'package:equatable/equatable.dart';

enum PlayerMode { vod, live }

class PlayerConfigEntity extends Equatable {
  final String videoId;
  final PlayerMode mode;
  final String? privacyHash;
  final String label;

  const PlayerConfigEntity({
    required this.videoId,
    required this.mode,
    required this.label,
    this.privacyHash,
  });

  bool get isLive => mode == PlayerMode.live;
  bool get isPrivate => privacyHash != null && privacyHash!.isNotEmpty;

  @override
  List<Object?> get props => [videoId, mode, privacyHash, label];
}
