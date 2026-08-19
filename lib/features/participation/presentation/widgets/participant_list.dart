import 'package:flutter/material.dart';
import 'package:qo100_tr/core/formatters/app_date_formatter.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';

class ParticipantList extends StatelessWidget {
  const ParticipantList({required this.checkIns, super.key});

  final List<CheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < checkIns.length; index++) ...[
            _ParticipantRow(checkIn: checkIns[index]),
            if (index != checkIns.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.checkIn});

  final CheckIn checkIn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDirect = checkIn.participationType == ParticipationType.direct;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.primary,
        child: Icon(isDirect ? Icons.mic_rounded : Icons.headphones_rounded),
      ),
      title: Text(checkIn.callsign),
      subtitle: Text(AppDateFormatter.timeUtc(checkIn.timestamp)),
      trailing: Text(
        isDirect ? 'Direkt' : 'SWL',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colors.primary),
      ),
    );
  }
}
