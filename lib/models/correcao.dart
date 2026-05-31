import 'package:cloud_firestore/cloud_firestore.dart';

import 'tipo_prova.dart';

class Correcao {
  final String id;
  final String redacaoId;
  final String professorId;
  final TipoProva tipoProva;
  final double competencia1;
  final double competencia2;
  final double competencia3;
  final double competencia4;
  final double competencia5;
  final double notaFinal;
  final String comentario;
  final String? imagemCorrecaoUrl;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Correcao({
    required this.id,
    required this.redacaoId,
    required this.professorId,
    required this.tipoProva,
    required this.competencia1,
    required this.competencia2,
    required this.competencia3,
    required this.competencia4,
    required this.competencia5,
    required this.notaFinal,
    required this.comentario,
    this.imagemCorrecaoUrl,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  static double calcularNotaFinal({
    required TipoProva tipoProva,
    required double c1,
    required double c2,
    required double c3,
    required double c4,
    required double c5,
  }) {
    if (tipoProva == TipoProva.acafe) {
      return c1 + c2 + c3 + c4;
    }
    return c1 + c2 + c3 + c4 + c5;
  }

  factory Correcao.deDocumento(DocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data()!;
    return Correcao(
      id: doc.id,
      redacaoId: dados['essayId'] ?? '',
      professorId: dados['teacherId'] ?? '',
      tipoProva: TipoProva.porValor(dados['examType']),
      competencia1: (dados['competency1'] as num?)?.toDouble() ?? 0.0,
      competencia2: (dados['competency2'] as num?)?.toDouble() ?? 0.0,
      competencia3: (dados['competency3'] as num?)?.toDouble() ?? 0.0,
      competencia4: (dados['competency4'] as num?)?.toDouble() ?? 0.0,
      competencia5: (dados['competency5'] as num?)?.toDouble() ?? 0.0,
      notaFinal: (dados['finalScore'] as num?)?.toDouble() ?? 0.0,
      comentario: dados['comment'] ?? '',
      imagemCorrecaoUrl: dados['correctionImageUrl'],
      criadoEm:
          (dados['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm:
          (dados['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'essayId': redacaoId,
      'teacherId': professorId,
      'examType': tipoProva.valor,
      'competency1': competencia1,
      'competency2': competencia2,
      'competency3': competencia3,
      'competency4': competencia4,
      'competency5': competencia5,
      'finalScore': notaFinal,
      'comment': comentario,
      'correctionImageUrl': imagemCorrecaoUrl,
      'createdAt': Timestamp.fromDate(criadoEm),
      'updatedAt': Timestamp.fromDate(atualizadoEm),
    };
  }

  Correcao copiarCom({
    double? competencia1,
    double? competencia2,
    double? competencia3,
    double? competencia4,
    double? competencia5,
    String? comentario,
    String? imagemCorrecaoUrl,
    DateTime? atualizadoEm,
  }) {
    final c1 = competencia1 ?? this.competencia1;
    final c2 = competencia2 ?? this.competencia2;
    final c3 = competencia3 ?? this.competencia3;
    final c4 = competencia4 ?? this.competencia4;
    final c5 = competencia5 ?? this.competencia5;
    return Correcao(
      id: id,
      redacaoId: redacaoId,
      professorId: professorId,
      tipoProva: tipoProva,
      competencia1: c1,
      competencia2: c2,
      competencia3: c3,
      competencia4: c4,
      competencia5: c5,
      notaFinal: calcularNotaFinal(
        tipoProva: tipoProva,
        c1: c1,
        c2: c2,
        c3: c3,
        c4: c4,
        c5: c5,
      ),
      comentario: comentario ?? this.comentario,
      imagemCorrecaoUrl: imagemCorrecaoUrl ?? this.imagemCorrecaoUrl,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
