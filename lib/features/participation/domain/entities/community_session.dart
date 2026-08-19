class CommunitySession {
  const CommunitySession({
    required this.id,
    required this.title,
    required this.startAt,
    required this.frequencyMHz,
    required this.isActive,
    this.scenarioNote,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final double frequencyMHz;
  final String? scenarioNote;
  final bool isActive;
}
