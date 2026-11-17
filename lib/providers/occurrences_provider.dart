import 'package:flutter/foundation.dart';
import '../core/load_status.dart';
import '../models/occurrence.dart';
import '../services/occurrence_repository.dart';
import '../services/synthetic_data_service.dart';

class OccurrencesProvider extends ChangeNotifier {
  final OccurrenceRepository _repo = OccurrenceRepository.create();

  LoadStatus status = LoadStatus.loading;
  String? errorMessage;
  List<Occurrence> items = [];

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      var data = await _repo.getAll();
      if (data.isEmpty) {
        // Primeira abertura: popula com ocorrências de exemplo.
        for (final o in SyntheticDataService().sampleOccurrences()) {
          await _repo.insert(o);
        }
        data = await _repo.getAll();
      }
      items = data;
      status = LoadStatus.ready;
    } catch (_) {
      errorMessage = 'Não foi possível ler as ocorrências salvas.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> add(Occurrence occurrence) async {
    await _repo.insert(occurrence);
    await load();
  }
}