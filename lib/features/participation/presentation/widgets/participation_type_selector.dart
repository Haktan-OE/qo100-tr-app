import 'package:flutter/material.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';

class ParticipationTypeSelector extends StatelessWidget {
  const ParticipationTypeSelector({
    required this.selectedType,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final ParticipationType selectedType;
  final bool enabled;
  final ValueChanged<ParticipationType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ParticipationType>(
        key: const Key('participation-type-selector'),
        showSelectedIcon: true,
        segments: const [
          ButtonSegment(
            value: ParticipationType.direct,
            label: Text('Direkt'),
            icon: Icon(Icons.mic_rounded),
          ),
          ButtonSegment(
            value: ParticipationType.swl,
            label: Text('SWL'),
            icon: Icon(Icons.headphones_rounded),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: enabled
            ? (selection) => onSelected(selection.first)
            : null,
      ),
    );
  }
}
