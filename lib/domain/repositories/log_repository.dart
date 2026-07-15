import '../../data/models/log_model.dart';

abstract class LogRepository {
  Stream<List<LogModel>> watchLogs({
    String? modulo,
    int limit = 100,
  });

  Future<void> addLog({
    required String usuarioId,
    required String accion,
    required String modulo,
    String origen = 'mobile',
    String detalle = '',
  });
}
