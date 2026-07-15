import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_roles.dart';
import '../../domain/entities/microbusiness.dart';
import '../../domain/repositories/microbusiness_repository.dart';
import '../../services/firestore_service.dart';
import '../models/microbusiness_model.dart';

class MicrobusinessRepositoryImpl implements MicrobusinessRepository {
  MicrobusinessRepositoryImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<void> createMicrobusiness({
    required Microbusiness business,
    required String currentUserId,
    required String currentUserRole,
  }) async {
    _validateCreatePermission(
      currentUserId: currentUserId,
      currentUserRole: currentUserRole,
      business: business,
    );

    final model = MicrobusinessModel.fromEntity(business);
    await _firestoreService.setMicrobusiness(id: model.id, data: model.toMap());
  }

  @override
  Future<void> updateMicrobusiness({
    required Microbusiness business,
    required String currentUserId,
    required String currentUserRole,
  }) async {
    final existing = await getMicrobusinessById(business.id);
    if (existing == null) {
      throw Exception('Micronegocio no encontrado.');
    }

    _validateUpdatePermission(
      currentUserId: currentUserId,
      currentUserRole: currentUserRole,
      existingBusiness: existing,
    );

    final model = MicrobusinessModel.fromEntity(business);
    await _firestoreService.setMicrobusiness(id: model.id, data: model.toMap());
  }

  @override
  Future<void> deleteMicrobusiness({
    required String businessId,
    required String currentUserId,
    required String currentUserRole,
  }) async {
    final existing = await getMicrobusinessById(businessId);
    if (existing == null) {
      throw Exception('Micronegocio no encontrado.');
    }

    _validateDeletePermission(
      currentUserId: currentUserId,
      currentUserRole: currentUserRole,
      existingBusiness: existing,
    );

    await _firestoreService.deleteMicrobusiness(businessId);
  }

  @override
  Future<Microbusiness?> getMicrobusinessById(String businessId) async {
    final map = await _firestoreService.getMicrobusinessById(businessId);
    if (map == null) return null;
    return MicrobusinessModel.fromMap(businessId, map);
  }

  @override
  Stream<List<Microbusiness>> watchMicrobusinesses({
    required String currentUserRole,
    String? categoria,
    String? searchText,
  }) {
    final onlyActive = !AppRoles.isDocenteAdmin(currentUserRole) &&
        !AppRoles.isAdminTi(currentUserRole);
    final source = _firestoreService.watchMicrobusinesses(
      onlyActive: onlyActive,
    );

    return Stream.multi((controller) {
      final sub = source.listen(
        (docs) {
          final all = docs
              .map((doc) => MicrobusinessModel.fromMap(doc.id, doc.data()))
              .toList();

          final filtered = _applyFilters(
            all,
            categoria: categoria,
            searchText: searchText,
          );
          controller.add(filtered);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (error is FirebaseException && error.code == 'permission-denied') {
            controller.add(<Microbusiness>[]);
            return;
          }
          controller.addError(error, stackTrace);
        },
      );

      controller.onCancel = () async {
        await sub.cancel();
      };
    });
  }

  @override
  Future<void> toggleFavorite({
    required String businessId,
    required String userId,
  }) async {
    final business = await getMicrobusinessById(businessId);
    if (business == null) throw Exception('Micronegocio no encontrado.');

    if (business.favoritos.contains(userId)) {
      await _firestoreService.removeUserFromMicrobusinessArrayField(
        businessId: businessId,
        field: 'favoritos',
        userId: userId,
      );
    } else {
      await _firestoreService.addUserToMicrobusinessArrayField(
        businessId: businessId,
        field: 'favoritos',
        userId: userId,
      );
    }
  }

  @override
  Future<void> rateBusiness({
    required String businessId,
    required double rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('La calificación debe estar entre 1 y 5.');
    }

    final business = await getMicrobusinessById(businessId);
    if (business == null) throw Exception('Micronegocio no encontrado.');

    final total = business.totalCalificaciones ?? 0;
    final currentAverage = business.ratingPromedio ?? 0;
    final newTotal = total + 1;
    final newAverage = ((currentAverage * total) + rating) / newTotal;

    await _firestoreService.updateMicrobusinessFields(
      businessId: businessId,
      data: {
        'ratingPromedio': double.parse(newAverage.toStringAsFixed(2)),
        'totalCalificaciones': newTotal,
      },
    );
  }

  @override
  Future<List<Microbusiness>> fetchNearby({
    required String currentUserRole,
    required double userLat,
    required double userLng,
    double maxDistanceKm = 10,
    String? categoria,
    String? searchText,
  }) async {
    final docs = await _firestoreService
        .watchMicrobusinesses(
          onlyActive: !AppRoles.isDocenteAdmin(currentUserRole) &&
              !AppRoles.isAdminTi(currentUserRole),
        )
        .first;

    final all = docs
        .map((doc) => MicrobusinessModel.fromMap(doc.id, doc.data()))
        .toList();

    final searched = _applyFilters(
      all,
      categoria: categoria,
      searchText: searchText,
    );

    final nearby = searched.where((business) {
      final d = _distanceKm(
        userLat,
        userLng,
        business.latitud,
        business.longitud,
      );
      return d <= maxDistanceKm;
    }).toList();

    nearby.sort((a, b) {
      final da = _distanceKm(userLat, userLng, a.latitud, a.longitud);
      final db = _distanceKm(userLat, userLng, b.latitud, b.longitud);
      return da.compareTo(db);
    });

    return nearby;
  }

  List<Microbusiness> _applyFilters(
    List<Microbusiness> all, {
    String? categoria,
    String? searchText,
  }) {
    final selectedCategory = (categoria ?? '').trim().toLowerCase();
    final q = (searchText ?? '').trim().toLowerCase();
    return all.where((business) {
      final matchesCategory = selectedCategory.isEmpty ||
          business.categoria.trim().toLowerCase() == selectedCategory;
      final matchesSearch =
          q.isEmpty || business.nombre.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _validateCreatePermission({
    required String currentUserId,
    required String currentUserRole,
    required Microbusiness business,
  }) {
    if (AppRoles.isDocenteAdmin(currentUserRole) ||
        AppRoles.isAdminTi(currentUserRole)) {
      return;
    }

    if ((AppRoles.isMicroempresario(currentUserRole) ||
            AppRoles.isDocente(currentUserRole)) &&
        business.propietarioId == currentUserId) {
      return;
    }

    throw Exception('No tienes permisos para crear este micronegocio.');
  }

  void _validateUpdatePermission({
    required String currentUserId,
    required String currentUserRole,
    required Microbusiness existingBusiness,
  }) {
    if (AppRoles.isDocenteAdmin(currentUserRole) ||
        AppRoles.isAdminTi(currentUserRole)) {
      return;
    }

    if ((AppRoles.isMicroempresario(currentUserRole) ||
            AppRoles.isDocente(currentUserRole)) &&
        existingBusiness.propietarioId == currentUserId) {
      return;
    }

    throw Exception('No tienes permisos para editar este micronegocio.');
  }

  void _validateDeletePermission({
    required String currentUserId,
    required String currentUserRole,
    required Microbusiness existingBusiness,
  }) {
    if (AppRoles.isDocenteAdmin(currentUserRole) ||
        AppRoles.isAdminTi(currentUserRole)) {
      return;
    }

    if (AppRoles.isMicroempresario(currentUserRole) &&
        existingBusiness.propietarioId == currentUserId) {
      return;
    }

    throw Exception('No tienes permisos para eliminar este micronegocio.');
  }

  double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  double _toRadians(double value) => value * pi / 180;
}
