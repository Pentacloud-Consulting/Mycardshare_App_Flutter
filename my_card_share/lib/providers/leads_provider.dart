import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead_model.dart';
import '../services/leads_service.dart';

final leadsServiceProvider = Provider<LeadsService>((ref) => LeadsService());

final leadsListProvider = StateProvider<List<LeadModel>>((ref) => []);
