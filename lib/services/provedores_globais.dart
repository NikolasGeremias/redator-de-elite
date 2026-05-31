import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/perfil_usuario.dart';
import '../models/redacao.dart';
import '../models/correcao.dart';
import '../repositories/repositorio_auth.dart';
import '../repositories/repositorio_correcao.dart';
import '../repositories/repositorio_redacao.dart';
import '../repositories/repositorio_usuario.dart';
import 'servico_auth.dart';
import 'servico_seletor_imagem.dart';
import 'servico_storage.dart';

final servicoAuthProvider = Provider<ServicoAuth>((ref) => ServicoAuth());

final servicoSeletorImagemProvider =
    Provider<ServicoSeletorImagem>((ref) => ServicoSeletorImagem());

final servicoStorageProvider =
    Provider<ServicoStorage>((ref) => ServicoStorage());

final repositorioAuthProvider = Provider<RepositorioAuth>((ref) {
  return RepositorioAuth(
    servicoAuth: ref.watch(servicoAuthProvider),
    servicoStorage: ref.watch(servicoStorageProvider),
  );
});

final repositorioUsuarioProvider =
    Provider<RepositorioUsuario>((ref) => RepositorioUsuario());

final repositorioRedacaoProvider = Provider<RepositorioRedacao>((ref) {
  return RepositorioRedacao(
    servicoStorage: ref.watch(servicoStorageProvider),
  );
});

final repositorioCorrecaoProvider = Provider<RepositorioCorrecao>((ref) {
  return RepositorioCorrecao(
    servicoStorage: ref.watch(servicoStorageProvider),
  );
});

final estadoAuthProvider = StreamProvider<User?>((ref) {
  return ref.watch(repositorioAuthProvider).mudancasEstado;
});

final usuarioFirebaseProvider = StreamProvider<User?>((ref) {
  return ref.watch(servicoAuthProvider).auth.userChanges();
});

final perfilAtualProvider = StreamProvider<PerfilUsuario?>((ref) {
  final auth = ref.watch(estadoAuthProvider).value;
  if (auth == null) return Stream.value(null);
  return ref.watch(repositorioUsuarioProvider).observarPerfil(auth.uid);
});

final redacoesDoUsuarioProvider =
    StreamProvider.family<List<Redacao>, String>((ref, usuarioId) {
  return ref
      .watch(repositorioRedacaoProvider)
      .observarPorUsuario(usuarioId);
});

final todasRedacoesProvider = StreamProvider<List<Redacao>>((ref) {
  return ref.watch(repositorioRedacaoProvider).observarTodas();
});

final redacaoPorIdProvider =
    StreamProvider.family<Redacao?, String>((ref, id) {
  return ref.watch(repositorioRedacaoProvider).observarPorId(id);
});

final correcaoPorRedacaoProvider =
    StreamProvider.family<Correcao?, String>((ref, redacaoId) {
  return ref
      .watch(repositorioCorrecaoProvider)
      .observarPorRedacao(redacaoId);
});

final correcoesDoProfessorProvider =
    StreamProvider.family<List<Correcao>, String>((ref, professorId) {
  return ref
      .watch(repositorioCorrecaoProvider)
      .observarPorProfessor(professorId);
});
