import 'package:cloud_firestore/cloud_firestore.dart';

import 'status_redacao.dart';
import 'tipo_prova.dart';

class Redacao {
  final String id;
  final String usuarioId;
  final String titulo;
  final String tema;
  final TipoProva tipoProva;
  final String imagemUrl;
  final StatusRedacao status;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? enviadoEm;
  final String? correcaoId;

  const Redacao({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.tema,
    required this.tipoProva,
    required this.imagemUrl,
    required this.status,
    required this.criadoEm,
    required this.atualizadoEm,
    this.enviadoEm,
    this.correcaoId,
  });

  factory Redacao.deDocumento(DocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data()!;
    return Redacao(
      id: doc.id,
      usuarioId: dados['userId'] ?? '',
      titulo: dados['title'] ?? '',
      tema: dados['theme'] ?? '',
      tipoProva: TipoProva.porValor(dados['examType']),
      imagemUrl: dados['imageUrl'] ?? '',
      status: StatusRedacao.porValor(dados['status']),
      criadoEm:
          (dados['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm:
          (dados['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enviadoEm: (dados['submittedAt'] as Timestamp?)?.toDate(),
      correcaoId: dados['correctionId'],
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'userId': usuarioId,
      'title': titulo,
      'theme': tema,
      'examType': tipoProva.valor,
      'imageUrl': imagemUrl,
      'status': status.valor,
      'createdAt': Timestamp.fromDate(criadoEm),
      'updatedAt': Timestamp.fromDate(atualizadoEm),
      'submittedAt':
          enviadoEm == null ? null : Timestamp.fromDate(enviadoEm!),
      'correctionId': correcaoId,
    };
  }

  Redacao copiarCom({
    String? titulo,
    String? tema,
    TipoProva? tipoProva,
    String? imagemUrl,
    StatusRedacao? status,
    DateTime? atualizadoEm,
    DateTime? enviadoEm,
    String? correcaoId,
  }) {
    return Redacao(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo ?? this.titulo,
      tema: tema ?? this.tema,
      tipoProva: tipoProva ?? this.tipoProva,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      status: status ?? this.status,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      enviadoEm: enviadoEm ?? this.enviadoEm,
      correcaoId: correcaoId ?? this.correcaoId,
    );
  }
}
