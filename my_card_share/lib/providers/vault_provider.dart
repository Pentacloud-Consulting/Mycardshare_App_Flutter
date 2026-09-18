import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vault_model.dart';
import '../services/vault_service.dart';

final vaultServiceProvider = Provider<VaultService>((ref) => VaultService());

final vaultProvider = StateProvider<VaultModel?>((ref) => null);
