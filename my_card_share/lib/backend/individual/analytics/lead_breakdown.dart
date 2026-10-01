import '../previews/user_leads.dart';

class LeadBreakdownData {
  final int totalLeads;
  final int newLeads;
  final int contactedLeads;
  final int qualifiedLeads;
  final double conversionRate;

  const LeadBreakdownData({
    required this.totalLeads,
    required this.newLeads,
    required this.contactedLeads,
    required this.qualifiedLeads,
    required this.conversionRate,
  });
}

class LeadBreakdownService {
  LeadBreakdownService._internal();
  static final LeadBreakdownService instance = LeadBreakdownService._internal();

  LeadBreakdownData getLeadBreakdown() {
    final leads = UserLeadsService.instance.leads;
    final total = leads.length;
    final newCount = leads.where((l) => l.status == 'New').length;
    final contactedCount = leads.where((l) => l.status == 'Contacted').length;
    final qualifiedCount = leads.where((l) => l.status == 'Qualified').length;
    final conv = total > 0 ? ((qualifiedCount + contactedCount) / total) * 100 : 0.0;

    return LeadBreakdownData(
      totalLeads: total,
      newLeads: newCount,
      contactedLeads: contactedCount,
      qualifiedLeads: qualifiedCount,
      conversionRate: conv,
    );
  }
}
