import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/carregador_imagem.dart';
import '../models/perfil_usuario.dart';
import '../models/tipo_usuario.dart';
import '../services/servico_auth.dart';
import '../services/servico_storage.dart';

typedef ResultadoLoginGoogle = ({
  User? usuario,
  bool perfilExistente,
  String? sugestaoNome,
  String? sugestaoEmail,
  String? sugestaoFoto,
});

class RepositorioAuth {
  final ServicoAuth _servicoAuth;
  final ServicoStorage _servicoStorage;
  final FirebaseFirestore _firestore;

  RepositorioAuth({
    required ServicoAuth servicoAuth,
    required ServicoStorage servicoStorage,
    FirebaseFirestore? firestore,
  })  : _servicoAuth = servicoAuth,
        _servicoStorage = servicoStorage,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _provedorGoogle = 'google.com';

  Stream<User?> get mudancasEstado => _servicoAuth.mudancasEstado;
  User? get usuarioAtual => _servicoAuth.usuarioAtual;

  bool get googleVinculado {
    final user = _servicoAuth.usuarioAtual;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == _provedorGoogle);
  }

  bool get temSenhaVinculada {
    final user = _servicoAuth.usuarioAtual;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  Future<void> entrarComEmailSenha(String email, String senha) async {
    await _servicoAuth.entrarComEmailSenha(email, senha);
  }

  Future<String?> _resolverFotoPerfil(String uid, String? caminho) async {
    if (caminho == null || caminho.isEmpty) return null;
    if (CarregadorImagem.ehUrlRemota(caminho)) return caminho;
    return _servicoStorage.uploadFotoPerfil(
      usuarioId: uid,
      caminhoLocal: caminho,
    );
  }

  Future<PerfilUsuario> cadastrar({
    required String nomeCompleto,
    required DateTime dataNascimento,
    required String email,
    required String senha,
    String? fotoUrl,
    TipoUsuario tipo = TipoUsuario.aluno,
  }) async {
    final cred = await _servicoAuth.criarConta(email, senha);
    final uid = cred.user!.uid;
    final fotoFinal = await _resolverFotoPerfil(uid, fotoUrl);
    final perfil = _construirPerfilNovo(
      uid: uid,
      nomeCompleto: nomeCompleto,
      dataNascimento: dataNascimento,
      email: email,
      fotoUrl: fotoFinal,
      tipo: tipo,
    );
    await _firestore
        .collection(AppConstants.colecaoUsuarios)
        .doc(uid)
        .set(perfil.paraMapa());
    return perfil;
  }

  Future<PerfilUsuario> criarPerfilUsuarioAutenticado({
    required String nomeCompleto,
    required DateTime dataNascimento,
    String? fotoUrl,
    TipoUsuario tipo = TipoUsuario.aluno,
  }) async {
    final user = _servicoAuth.usuarioAtual;
    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    final fotoFinal = await _resolverFotoPerfil(user.uid, fotoUrl);
    final perfil = _construirPerfilNovo(
      uid: user.uid,
      nomeCompleto: nomeCompleto,
      dataNascimento: dataNascimento,
      email: user.email ?? '',
      fotoUrl: fotoFinal,
      tipo: tipo,
    );
    await _firestore
        .collection(AppConstants.colecaoUsuarios)
        .doc(user.uid)
        .set(perfil.paraMapa());
    return perfil;
  }

  PerfilUsuario _construirPerfilNovo({
    required String uid,
    required String nomeCompleto,
    required DateTime dataNascimento,
    required String email,
    String? fotoUrl,
    required TipoUsuario tipo,
  }) {
    final agora = DateTime.now();
    return PerfilUsuario(
      id: uid,
      nomeCompleto: nomeCompleto.trim(),
      dataNascimento: dataNascimento,
      email: email.trim(),
      fotoUrl: fotoUrl,
      tipo: tipo,
      creditos: tipo == TipoUsuario.aluno
          ? AppConstants.creditosIniciais
          : 0,
      criadoEm: agora,
      atualizadoEm: agora,
      ultimaRenovacaoCreditos:
          tipo == TipoUsuario.aluno ? agora : null,
    );
  }

  Future<ResultadoLoginGoogle> entrarComGoogle() async {
    final cred = await _servicoAuth.entrarComGoogle();
    if (cred?.user == null) {
      return const (
        usuario: null,
        perfilExistente: false,
        sugestaoNome: null,
        sugestaoEmail: null,
        sugestaoFoto: null,
      );
    }
    final user = cred!.user!;
    final ref = _firestore
        .collection(AppConstants.colecaoUsuarios)
        .doc(user.uid);
    final snap = await ref.get();
    return (
      usuario: user,
      perfilExistente: snap.exists,
      sugestaoNome: user.displayName,
      sugestaoEmail: user.email,
      sugestaoFoto: user.photoURL,
    );
  }

  Future<void> vincularContaGoogle() async {
    final user = _servicoAuth.usuarioAtual;
    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    final googleUser = await _servicoAuth.googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'cancelled-by-user',
        message: 'Vinculação cancelada.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credencial = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.linkWithCredential(credencial);
    await user.reload();
  }

  Future<void> desvincularContaGoogle() async {
    final user = _servicoAuth.usuarioAtual;
    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    if (!temSenhaVinculada) {
      throw FirebaseAuthException(
        code: 'no-such-provider',
        message:
            'Defina uma senha antes de desvincular o Google, senão você perde o acesso.',
      );
    }
    await user.unlink(_provedorGoogle);
    await _servicoAuth.googleSignIn.signOut();
    await user.reload();
  }

  Future<void> sair() async {
    await _servicoAuth.sair();
  }

  Future<void> enviarRedefinicaoSenha(String email) async {
    await _servicoAuth.enviarRedefinicaoSenha(email);
  }
}
