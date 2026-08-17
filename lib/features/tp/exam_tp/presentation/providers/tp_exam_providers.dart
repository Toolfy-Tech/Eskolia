import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tp_exam_repository.dart';
import '../../models/tp_exam_model.dart';

final tpExamRepositoryProvider = Provider<TpExamRepository>((ref) {
  return TpExamRepository.instance;
});

final tpExamEnabledStreamProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(tpExamRepositoryProvider);
  return repo.watchTpExamEnabled();
});

final tpExamListProvider = FutureProvider.autoDispose<List<TpExamScenario>>((ref) async {
  final repo = ref.watch(tpExamRepositoryProvider);
  return repo.loadAllScenarios();
});

final tpExamScenarioProvider = FutureProvider.autoDispose.family<TpExamScenario?, String>((ref, id) async {
  final repo = ref.watch(tpExamRepositoryProvider);
  return repo.loadScenarioById(id);
});
