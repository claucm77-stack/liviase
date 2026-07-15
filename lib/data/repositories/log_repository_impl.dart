import '../../data/models/log_model.dart';
import '../../domain/repositories/log_repository.dart';
import '../../services/firestore_service.dart';

class LogRepositoryImpl implements LogRepository {
  LogRepositoryImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<void> addLog({
    required String usuarioId,
    required String accion,
    required String modulo,
    String origen = 'mobile',
    String detalle = '',
  }) {
    return _firestoreService.addLog(
      usuarioId: usuarioId,
      accion: accion,
      modulo: modulo,
      origen: origen,
      detalle: detalle,
    );
  }

  @override
  Stream<List<LogModel>> watchLogs({
    String? modulo,
    int limit = 100,
  }) {
    return _firestoreService.watchLogs(
      modulo: modulo,
      limit: limit,
    );
  }
}
