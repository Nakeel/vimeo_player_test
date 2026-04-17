import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:udux_concerts_test/core/router/app_router.dart';
import 'package:udux_concerts_test/features/player/domain/entities/player_config_entity.dart';

class CustomVideoEntry extends StatefulWidget {
  const CustomVideoEntry({super.key});

  @override
  State<CustomVideoEntry> createState() => _CustomVideoEntryState();
}

class _CustomVideoEntryState extends State<CustomVideoEntry> {
  PlayerMode _mode = PlayerMode.vod;
  bool _isPrivate = false;
  final _idController = TextEditingController();
  final _hashController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _hashController.dispose();
    super.dispose();
  }

  void _launch() {
    final videoId = _idController.text.trim();
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a video ID')),
      );
      return;
    }

    final config = PlayerConfigEntity(
      videoId: videoId,
      mode: _mode,
      label: _mode == PlayerMode.live ? 'Custom — Live' : 'Custom — VOD',
      privacyHash: _isPrivate ? _hashController.text.trim().nullIfEmpty : null,
    );

    context.push(AppRoutes.player, extra: config);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModeToggle(
          selected: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _idController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Video ID',
            hintText: '76979871',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _isPrivate,
              onChanged: (v) => setState(() => _isPrivate = v ?? false),
            ),
            const Expanded(
              child: Text(
                'Private / unlisted video (add privacy hash)',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        if (_isPrivate) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _hashController,
            decoration: const InputDecoration(
              labelText: 'Privacy hash',
              hintText: 'abc123def456',
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _launch, child: const Text('Launch player')),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final PlayerMode selected;
  final ValueChanged<PlayerMode> onChanged;

  const _ModeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PillChip(
          label: 'VOD',
          isSelected: selected == PlayerMode.vod,
          onTap: () => onChanged(PlayerMode.vod),
        ),
        const SizedBox(width: 8),
        _PillChip(
          label: 'Live',
          isSelected: selected == PlayerMode.live,
          onTap: () => onChanged(PlayerMode.live),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7B2FBE);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : primary.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
