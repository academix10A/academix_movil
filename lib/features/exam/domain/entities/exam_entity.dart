class OptionEntity {
  final int idOpcion;
  final String respuesta;

  OptionEntity({
    required this.idOpcion,
    required this.respuesta,
  });

  factory OptionEntity.fromJson(Map<String, dynamic> json) {
    return OptionEntity(
      idOpcion: json['id_opcion'] ?? 0,
      respuesta: json['respuesta'] ?? '',
    );
  }
}

class QuestionEntity {
  final int idPregunta;
  final String contenido;
  final List<OptionEntity> opciones;

  QuestionEntity({
    required this.idPregunta,
    required this.contenido,
    required this.opciones,
  });

  factory QuestionEntity.fromJson(Map<String, dynamic> json) {
    return QuestionEntity(
      idPregunta: json['id_pregunta'] ?? 0,
      contenido: json['contenido'] ?? '',
      opciones: (json['opciones'] as List<dynamic>?)
          ?.map((e) => OptionEntity.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ExamEntity {
  final int idExamen;
  final String titulo;
  final String? descripcion;
  final int duracionMinutos;
  final int cantidadPreguntas;
  final double calificacionMinima;
  final DateTime fechaCreacion;
  final DateTime? fechaLimite;
  final bool estaActivo;
  final int idUsuarioCreador;
  final String? nombreCreador;
  final List<QuestionEntity>? preguntas; // New for completo

  ExamEntity({
    required this.idExamen,
    required this.titulo,
    this.descripcion,
    required this.duracionMinutos,
    required this.cantidadPreguntas,
    required this.calificacionMinima,
    required this.fechaCreacion,
    this.fechaLimite,
    required this.estaActivo,
    required this.idUsuarioCreador,
    this.nombreCreador,
    this.preguntas,
  });

  factory ExamEntity.fromJson(Map<String, dynamic> json) {
    return ExamEntity(
      idExamen: json['id_examen'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      duracionMinutos: json['duracion_minutos'] ?? 30,
      cantidadPreguntas: json['cantidad_preguntas'] ?? 0,
      calificacionMinima: (json['calificacion_minima'] ?? 70).toDouble(),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      fechaLimite: json['fecha_limite'] != null
          ? DateTime.parse(json['fecha_limite'])
          : null,
      estaActivo: json['esta_activo'] ?? true,
      idUsuarioCreador: json['id_usuario_creador'] ?? 0,
      nombreCreador: json['nombre_creador'],
      preguntas: null, // Not in basic /examen/
    );
  }

  factory ExamEntity.fromCompletoJson(Map<String, dynamic> json) {
    return ExamEntity(
      idExamen: json['id_examen'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracionMinutos: 30, // Default, not in completo
      cantidadPreguntas: json['cantidad_preguntas'] ?? 0,
      calificacionMinima: 7.0, // Default 70%
      fechaCreacion: DateTime.now(),
      fechaLimite: null,
      estaActivo: true,
      idUsuarioCreador: 0,
      nombreCreador: '',
      preguntas: (json['preguntas'] as List<dynamic>?)
          ?.map((p) => QuestionEntity.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  // Mapper para compatibilidad con la UI existente
  String get difficulty {
    if (cantidadPreguntas <= 5) return 'Fácil';
    if (cantidadPreguntas <= 10) return 'Medio';
    return 'Difícil';
  }

  bool get hasTimeLimit => fechaLimite != null;

  String get timeLeft {
    if (fechaLimite == null) return 'Sin límite';
    final now = DateTime.now();
    final difference = fechaLimite!.difference(now);
    if (difference.isNegative) return 'Expirado';
    if (difference.inDays > 0) return '${difference.inDays} días';
    if (difference.inHours > 0) return '${difference.inHours} horas';
    return '${difference.inMinutes} minutos';
  }
}

class CompletedExamEntity {
  final int idIntento;
  final int idExamen;
  final int idUsuario;
  final double calificacion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int respuestasCorrectas;
  final int cantidadPreguntas;
  final bool aprobo;
  final String? tituloExamen;
  final double? porcentaje; // New for submit response

  CompletedExamEntity({
    required this.idIntento,
    required this.idExamen,
    required this.idUsuario,
    required this.calificacion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.respuestasCorrectas,
    required this.cantidadPreguntas,
    required this.aprobo,
    this.tituloExamen,
    this.porcentaje,
  });

  factory CompletedExamEntity.fromJson(Map<String, dynamic> json) {
    return CompletedExamEntity(
      idIntento: json['id_intento'] ?? 0,
      idExamen: json['id_examen'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'])
          : DateTime.now(),
      respuestasCorrectas: json['respuestas_correctas'] ?? 0,
      cantidadPreguntas: json['cantidad_preguntas'] ?? 0,
      aprobo: json['aprobo'] ?? false,
      tituloExamen: json['titulo_examen'],
      porcentaje: (json['porcentaje'] ?? 0).toDouble(),
    );
  }

  factory CompletedExamEntity.fromSubmitJson(Map<String, dynamic> json) {
    final scorePorcentaje = json['porcentaje'] ?? ((json['calificacion'] ?? 0) * 10);
    return CompletedExamEntity(
      idIntento: json['id_intento'] ?? 0,
      idExamen: json['id_examen'] ?? 0,
      idUsuario: 0, // Filled post-submit
      calificacion: scorePorcentaje,
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now(),
      respuestasCorrectas: json['correctas'] ?? 0,
      cantidadPreguntas: json['total'] ?? 0,
      aprobo: scorePorcentaje >= 70,
      tituloExamen: json['titulo_examen'],
      porcentaje: scorePorcentaje,
    );
  }

  // Mapper para compatibilidad con la UI existente
  String get grade => '${calificacion.toStringAsFixed(0)}%';

  String get dateCompleted {
    final now = DateTime.now();
    final difference = now.difference(fechaFin);

    if (difference.inDays > 30) {
      return 'Hace más de un mes';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hoy';
    }
  }

  String get examTitle => tituloExamen ?? 'Examen #${idExamen}';

  int get correctAnswers => respuestasCorrectas;
  int get incorrectAnswers => cantidadPreguntas - respuestasCorrectas;
}

