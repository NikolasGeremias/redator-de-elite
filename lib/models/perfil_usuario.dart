import 'package:cloud_firestore/cloud_firestore.dart';

import 'tipo_usuario.dart';

class PerfilUsuario {
  final String id;
  final String nomeCompleto;
  final DateTime dataNascimento;
  final String email;
  final String? fotoUrl;
  final TipoUsuario tipo;
  final int creditos;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? ultimaRenovacaoCreditos;

  const PerfilUsuario({
    required this.id,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.email,
    this.fotoUrl,
    required this.tipo,
    required this.creditos,
    required this.criadoEm,
    required this.atualizadoEm,
    this.ultimaRenovacaoCreditos,
  });

  factory PerfilUsuario.deDocumento(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final dados = doc.data()!;
    return PerfilUsuario(
      id: doc.id,
      nomeCompleto: dados['fullName'] ?? '',
      dataNascimento:
          (dados['birthDate'] as Timestamp?)?.toDate() ?? DateTime(2000, 1, 1),
      email: dados['email'] ?? '',
      fotoUrl: dados['photoUrl'],
      tipo: TipoUsuario.porValor(dados['type']),
      creditos: (dados['credits'] as num?)?.toInt() ?? 0,
      criadoEm:
          (dados['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm:
          (dados['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimaRenovacaoCreditos:
          (dados['lastCreditRenewal'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'fullName': nomeCompleto,
      'birthDate': Timestamp.fromDate(dataNascimento),
      'email': email,
      'photoUrl': fotoUrl,
      'type': tipo.valor,
      'credits': creditos,
      'createdAt': Timestamp.fromDate(criadoEm),
      'updatedAt': Timestamp.fromDate(atualizadoEm),
      'lastCreditRenewal': ultimaRenovacaoCreditos == null
          ? null
          : Timestamp.fromDate(ultimaRenovacaoCreditos!),
    };
  }

  PerfilUsuario copiarCom({
    String? nomeCompleto,
    DateTime? dataNascimento,
    String? email,
    String? fotoUrl,
    TipoUsuario? tipo,
    int? creditos,
    DateTime? atualizadoEm,
    DateTime? ultimaRenovacaoCreditos,
    bool limparFoto = false,
  }) {
    return PerfilUsuario(
      id: id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      email: email ?? this.email,
      fotoUrl: limparFoto ? null : (fotoUrl ?? this.fotoUrl),
      tipo: tipo ?? this.tipo,
      creditos: creditos ?? this.creditos,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      ultimaRenovacaoCreditos:
          ultimaRenovacaoCreditos ?? this.ultimaRenovacaoCreditos,
    );
  }

  bool get ehAluno => tipo == TipoUsuario.aluno;
  bool get ehProfessor => tipo == TipoUsuario.professor;
  bool get temCreditos => creditos > 0;
}
