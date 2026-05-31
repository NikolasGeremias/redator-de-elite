import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/perfil_usuario.dart';
import '../models/tipo_usuario.dart';

class RepositorioUsuario {
  final FirebaseFirestore _firestore;

  RepositorioUsuario({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection(AppConstants.colecaoUsuarios);

  Stream<PerfilUsuario?> observarPerfil(String uid) {
    return _colecao.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PerfilUsuario.deDocumento(doc);
    });
  }

  Future<PerfilUsuario?> buscarPerfil(String uid) async {
    final doc = await _colecao.doc(uid).get();
    if (!doc.exists) return null;
    return PerfilUsuario.deDocumento(doc);
  }

  Future<void> atualizarPerfil(PerfilUsuario perfil) async {
    await _colecao.doc(perfil.id).update(
      perfil.copiarCom(atualizadoEm: DateTime.now()).paraMapa(),
    );
  }

  Future<void> decrementarCreditos(String uid) async {
    final agora = DateTime.now();
    await _colecao.doc(uid).update({
      'credits': FieldValue.increment(-1),
      'updatedAt': Timestamp.fromDate(agora),
    });
  }

  DateTime _ultimaDataRenovacao(DateTime agora) {
    if (agora.day >= AppConstants.diaRenovacaoCreditos) {
      return DateTime(agora.year, agora.month, AppConstants.diaRenovacaoCreditos);
    }
    final mesAnterior = agora.month == 1 ? 12 : agora.month - 1;
    final anoAnterior = agora.month == 1 ? agora.year - 1 : agora.year;
    return DateTime(anoAnterior, mesAnterior, AppConstants.diaRenovacaoCreditos);
  }

  Future<PerfilUsuario> renovarCreditosSeNecessario(
    PerfilUsuario perfil,
  ) async {
    if (perfil.tipo != TipoUsuario.aluno) return perfil;
    final agora = DateTime.now();
    final ultimaJanela = _ultimaDataRenovacao(agora);
    final ultimaRenovacao = perfil.ultimaRenovacaoCreditos;
    final precisaRenovar = ultimaRenovacao == null ||
        ultimaRenovacao.isBefore(ultimaJanela);
    if (!precisaRenovar) return perfil;
    final atualizado = perfil.copiarCom(
      creditos: AppConstants.creditosIniciais,
      ultimaRenovacaoCreditos: agora,
      atualizadoEm: agora,
    );
    await _colecao.doc(perfil.id).update({
      'credits': AppConstants.creditosIniciais,
      'lastCreditRenewal': Timestamp.fromDate(agora),
      'updatedAt': Timestamp.fromDate(agora),
    });
    return atualizado;
  }
}
