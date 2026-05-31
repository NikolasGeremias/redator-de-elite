import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/carregador_imagem.dart';
import '../models/correcao.dart';
import '../models/tipo_prova.dart';
import '../services/servico_storage.dart';

class RepositorioCorrecao {
  final FirebaseFirestore _firestore;
  final ServicoStorage _servicoStorage;

  RepositorioCorrecao({
    required ServicoStorage servicoStorage,
    FirebaseFirestore? firestore,
  })  : _servicoStorage = servicoStorage,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection(AppConstants.colecaoCorrecoes);

  Stream<Correcao?> observarPorRedacao(String redacaoId) {
    return _colecao
        .where('essayId', isEqualTo: redacaoId)
        .limit(1)
        .snapshots()
        .map((qs) {
      if (qs.docs.isEmpty) return null;
      return Correcao.deDocumento(qs.docs.first);
    });
  }

  Stream<List<Correcao>> observarPorProfessor(String professorId) {
    return _colecao
        .where('teacherId', isEqualTo: professorId)
        .snapshots()
        .map((qs) {
      final lista = qs.docs.map(Correcao.deDocumento).toList();
      lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return lista;
    });
  }

  Future<String?> _resolverImagem({
    required String? caminho,
    required String correcaoId,
  }) async {
    if (caminho == null || caminho.isEmpty) return null;
    if (CarregadorImagem.ehUrlRemota(caminho)) return caminho;
    return _servicoStorage.uploadFotoCorrecao(
      correcaoId: correcaoId,
      caminhoLocal: caminho,
    );
  }

  Future<Correcao> criar({
    required String redacaoId,
    required String professorId,
    required TipoProva tipoProva,
    required double c1,
    required double c2,
    required double c3,
    required double c4,
    required double c5,
    required String comentario,
    String? imagemUrl,
  }) async {
    final agora = DateTime.now();
    final ref = _colecao.doc();
    final imagemFinal = await _resolverImagem(
      caminho: imagemUrl,
      correcaoId: ref.id,
    );
    final correcao = Correcao(
      id: ref.id,
      redacaoId: redacaoId,
      professorId: professorId,
      tipoProva: tipoProva,
      competencia1: c1,
      competencia2: c2,
      competencia3: c3,
      competencia4: c4,
      competencia5: c5,
      notaFinal: Correcao.calcularNotaFinal(
        tipoProva: tipoProva,
        c1: c1,
        c2: c2,
        c3: c3,
        c4: c4,
        c5: c5,
      ),
      comentario: comentario.trim(),
      imagemCorrecaoUrl: imagemFinal,
      criadoEm: agora,
      atualizadoEm: agora,
    );
    await ref.set(correcao.paraMapa());
    return correcao;
  }

  Future<Correcao> atualizar(Correcao correcao) async {
    final imagemFinal = await _resolverImagem(
      caminho: correcao.imagemCorrecaoUrl,
      correcaoId: correcao.id,
    );
    final atualizada = correcao
        .copiarCom(
          imagemCorrecaoUrl: imagemFinal,
          atualizadoEm: DateTime.now(),
        );
    await _colecao.doc(correcao.id).update(atualizada.paraMapa());
    return atualizada;
  }
}
