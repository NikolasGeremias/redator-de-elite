import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/carregador_imagem.dart';
import '../models/redacao.dart';
import '../models/status_redacao.dart';
import '../models/tipo_prova.dart';
import '../services/servico_storage.dart';

class RepositorioRedacao {
  final FirebaseFirestore _firestore;
  final ServicoStorage _servicoStorage;

  RepositorioRedacao({
    required ServicoStorage servicoStorage,
    FirebaseFirestore? firestore,
  })  : _servicoStorage = servicoStorage,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection(AppConstants.colecaoRedacoes);

  Stream<List<Redacao>> observarPorUsuario(String usuarioId) {
    return _colecao
        .where('userId', isEqualTo: usuarioId)
        .snapshots()
        .map((qs) {
      final lista = qs.docs.map(Redacao.deDocumento).toList();
      lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return lista;
    });
  }

  Stream<List<Redacao>> observarTodas() {
    return _colecao
        .where(
          'status',
          whereIn: [
            StatusRedacao.enviada.valor,
            StatusRedacao.corrigida.valor,
          ],
        )
        .snapshots()
        .map((qs) {
      final lista = qs.docs.map(Redacao.deDocumento).toList();
      lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return lista;
    });
  }

  Stream<Redacao?> observarPorId(String id) {
    return _colecao.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Redacao.deDocumento(doc);
    });
  }

  Future<String> _resolverImagem({
    required String caminho,
    required String usuarioId,
    required String redacaoId,
  }) async {
    if (caminho.isEmpty) return '';
    if (CarregadorImagem.ehUrlRemota(caminho)) return caminho;
    return _servicoStorage.uploadFotoRedacao(
      usuarioId: usuarioId,
      redacaoId: redacaoId,
      caminhoLocal: caminho,
    );
  }

  Future<Redacao> criarRascunho({
    required String usuarioId,
    required String titulo,
    required String tema,
    required TipoProva tipoProva,
    required String imagemUrl,
  }) async {
    final agora = DateTime.now();
    final ref = _colecao.doc();
    final imagemFinal = await _resolverImagem(
      caminho: imagemUrl,
      usuarioId: usuarioId,
      redacaoId: ref.id,
    );
    final redacao = Redacao(
      id: ref.id,
      usuarioId: usuarioId,
      titulo: titulo.trim(),
      tema: tema.trim(),
      tipoProva: tipoProva,
      imagemUrl: imagemFinal,
      status: StatusRedacao.rascunho,
      criadoEm: agora,
      atualizadoEm: agora,
    );
    await ref.set(redacao.paraMapa());
    return redacao;
  }

  Future<Redacao> atualizar(Redacao redacao) async {
    final imagemFinal = await _resolverImagem(
      caminho: redacao.imagemUrl,
      usuarioId: redacao.usuarioId,
      redacaoId: redacao.id,
    );
    final atualizada = redacao.copiarCom(
      imagemUrl: imagemFinal,
      atualizadoEm: DateTime.now(),
    );
    await _colecao.doc(redacao.id).update(atualizada.paraMapa());
    return atualizada;
  }

  Future<Redacao> enviar(Redacao redacao) async {
    final agora = DateTime.now();
    final imagemFinal = await _resolverImagem(
      caminho: redacao.imagemUrl,
      usuarioId: redacao.usuarioId,
      redacaoId: redacao.id,
    );
    final atualizada = redacao.copiarCom(
      imagemUrl: imagemFinal,
      status: StatusRedacao.enviada,
      enviadoEm: agora,
      atualizadoEm: agora,
    );
    await _colecao.doc(redacao.id).update(atualizada.paraMapa());
    return atualizada;
  }

  Future<void> marcarComoCorrigida(
    String redacaoId,
    String correcaoId,
  ) async {
    await _colecao.doc(redacaoId).update({
      'status': StatusRedacao.corrigida.valor,
      'correctionId': correcaoId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> excluir(String redacaoId) async {
    await _colecao.doc(redacaoId).delete();
  }
}
