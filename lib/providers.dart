import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/supabase_service.dart';

final caretakerProvider = StreamProvider.autoDispose<List<Map>>((ref) {
  return Svc.caretakers();
});
