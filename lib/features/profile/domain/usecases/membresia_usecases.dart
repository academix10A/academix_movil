import '../entities/membresia_entity.dart';
import '../repositories/profile_repository.dart';

class GetMembresiasUseCase {
  final ProfileRepository repository;

  GetMembresiasUseCase(this.repository);

  Future<List<Membresia>> call() {
    return repository.getMembresias();
  }
}

class ActivarMembresiaUseCase {
  final ProfileRepository repository;

  ActivarMembresiaUseCase(this.repository);

  Future<void> call(int idMembresia) {
    return repository.activarMembresia(idMembresia);
  }
}

class CreatePaypalOrderUseCase {
  final ProfileRepository repository;

  CreatePaypalOrderUseCase(this.repository);

  Future<Map<String, dynamic>> call(int idMembresia) {
    return repository.createPaypalOrder(idMembresia);
  }
}

class CapturePaypalOrderUseCase {
  final ProfileRepository repository;

  CapturePaypalOrderUseCase(this.repository);

  Future<void> call(String orderId, int idMembresia) {
    return repository.capturePaypalOrder(orderId, idMembresia);
  }
}