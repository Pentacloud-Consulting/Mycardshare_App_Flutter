import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';

final cardServiceProvider = Provider<CardService>((ref) => CardService());

final activeCardProvider = StateProvider<CardModel?>((ref) => null);
