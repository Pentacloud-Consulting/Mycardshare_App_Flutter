class DailyChartDataPoint {
  final String date;
  final int views;
  final int leads;

  const DailyChartDataPoint({
    required this.date,
    required this.views,
    required this.leads,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'views': views,
        'leads': leads,
      };
}

class AnalyticsChartService {
  AnalyticsChartService._internal();
  static final AnalyticsChartService instance = AnalyticsChartService._internal();

  /// Generates daily chart data points for Views & Leads chart
  List<DailyChartDataPoint> getDailyChartData({
    required int totalViews,
    required int totalLeads,
  }) {
    final now = DateTime.now();
    final List<DailyChartDataPoint> points = [];

    // 7 sample days for daily breakdown chart
    final List<double> viewDistribution = [0.08, 0.10, 0.12, 0.15, 0.14, 0.22, 0.19];
    final List<double> leadDistribution = [0.05, 0.08, 0.10, 0.14, 0.12, 0.25, 0.26];

    for (int i = 6; i >= 0; i--) {
      final dt = now.subtract(Duration(days: i));
      final dateLabel = "${_monthAbbr(dt.month)} ${dt.day}";
      final idx = 6 - i;

      final dayViews = (totalViews * viewDistribution[idx]).round();
      final dayLeads = (totalLeads * leadDistribution[idx]).round();

      points.add(DailyChartDataPoint(
        date: dateLabel,
        views: dayViews > 0 ? dayViews : (totalViews > 0 ? 1 : 0),
        leads: dayLeads > 0 ? dayLeads : (totalLeads > 0 ? 1 : 0),
      ));
    }

    return points;
  }

  /// Dynamic calculation of chart max value for Y-axis scaling
  double calculateMaxYValue(List<DailyChartDataPoint> points) {
    int maxVal = 0;
    for (final pt in points) {
      if (pt.views > maxVal) maxVal = pt.views;
      if (pt.leads > maxVal) maxVal = pt.leads;
    }
    if (maxVal <= 0) return 100.0;
    if (maxVal <= 50) return 50.0;
    if (maxVal <= 100) return 100.0;
    if (maxVal <= 200) return 200.0;
    if (maxVal <= 400) return 400.0;
    return (maxVal * 1.25).ceilToDouble();
  }

  String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}


