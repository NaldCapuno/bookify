enum ReportPeriod {
  daily("Daily"),
  weekly("Weekly"),
  monthly("Monthly"),
  quarterly("Quarterly"),
  yearly("Yearly");

  final String label;
  const ReportPeriod(this.label);
}

class DateRange {
  final DateTime start;
  final DateTime end;
  DateRange(this.start, this.end);
}

class AccountingDateHelper {
  static DateRange getRangeForPeriod(ReportPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.daily:
        // From 12:00 AM to 11:59 PM today
        return DateRange(
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

      case ReportPeriod.weekly:
        // Assuming a Monday - Sunday week.
        // now.weekday returns 1 for Monday, 7 for Sunday.
        // We subtract (weekday - 1) days to get back to Monday.
        final int daysToSubtract = now.weekday - 1;
        final DateTime startOfWeek = now.subtract(
          Duration(days: daysToSubtract),
        );

        return DateRange(
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day + 6,
            23,
            59,
            59,
          ),
        );

      case ReportPeriod.monthly:
        // From the 1st of this month to the last day of this month
        return DateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );

      case ReportPeriod.quarterly:
        // Find the start month of the current quarter (1, 4, 7, or 10)
        int startMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return DateRange(
          DateTime(now.year, startMonth, 1),
          DateTime(now.year, startMonth + 3, 0, 23, 59, 59),
        );

      case ReportPeriod.yearly:
        // From Jan 1st to Dec 31st
        return DateRange(
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }
}
