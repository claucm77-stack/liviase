class DashboardMetricsModel {
  final int totalUsers;
  final int totalContents;
  final int totalMicrobusinesses;
  final int activeContents;
  final int inactiveContents;
  final int activeMicrobusinesses;
  final int inactiveMicrobusinesses;

  const DashboardMetricsModel({
    required this.totalUsers,
    required this.totalContents,
    required this.totalMicrobusinesses,
    required this.activeContents,
    required this.inactiveContents,
    required this.activeMicrobusinesses,
    required this.inactiveMicrobusinesses,
  });

  const DashboardMetricsModel.empty()
      : totalUsers = 0,
        totalContents = 0,
        totalMicrobusinesses = 0,
        activeContents = 0,
        inactiveContents = 0,
        activeMicrobusinesses = 0,
        inactiveMicrobusinesses = 0;
}
