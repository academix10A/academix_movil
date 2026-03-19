import '../entities/subtema_entity.dart';

class GetSubtemasUseCase {
  Future<List<SubtemaEntity>> call(String temaId) async {
    // Mock data matching temas_viewmodel style
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SubtemaEntity(
        id: '1',
        temaId: temaId,
        title: 'Álgebra Lineal',
        description: 'Matrices, vectores y sistemas',
        resourceCount: 12,
        examCount: 5,
      ),
      SubtemaEntity(
        id: '2',
        temaId: temaId,
        title: 'Geometría Analítica',
        description: 'Ecuaciones de rectas y circunferencias',
        resourceCount: 8,
        examCount: 3,
      ),
    ];
  }
}
