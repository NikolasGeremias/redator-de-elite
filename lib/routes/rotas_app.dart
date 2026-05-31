import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/pagina_info_conta.dart';
import '../features/auth/login/pagina_login.dart';
import '../features/auth/register/dados_iniciais_cadastro.dart';
import '../features/auth/register/pagina_cadastro.dart';
import '../features/correction/pagina_form_correcao.dart';
import '../features/essays/pagina_detalhes_redacao.dart';
import '../features/essays/pagina_form_redacao.dart';
import '../features/essays/pagina_lista_redacoes.dart';
import '../features/home/pagina_home.dart';
import '../features/shell/casca_principal.dart';
import '../services/provedores_globais.dart';
import 'nomes_rotas.dart';
import 'notificador_auth.dart';

final navegadorRaizKey = GlobalKey<NavigatorState>(debugLabel: 'raiz');
final navegadorAbasKey = GlobalKey<NavigatorState>(debugLabel: 'abas');

final roteadorProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(servicoAuthProvider);
  final notificador = NotificadorAuth(auth.mudancasEstado);
  ref.onDispose(notificador.dispose);

  return GoRouter(
    navigatorKey: navegadorRaizKey,
    initialLocation: NomesRotas.home,
    refreshListenable: notificador,
    redirect: (context, state) {
      final logado = auth.usuarioAtual != null;
      final emTelaAuth = state.matchedLocation == NomesRotas.login ||
          state.matchedLocation == NomesRotas.cadastro;
      if (!logado && !emTelaAuth) return NomesRotas.login;
      if (logado && state.matchedLocation == NomesRotas.login) {
        return NomesRotas.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: NomesRotas.login,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) => const PaginaLogin(),
      ),
      GoRoute(
        path: NomesRotas.cadastro,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) {
          final dados = state.extra as DadosIniciaisCadastro?;
          return PaginaCadastro(dadosIniciais: dados);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacao) =>
            CascaPrincipal(navegacao: navegacao),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NomesRotas.home,
                builder: (context, state) => const PaginaHome(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NomesRotas.redacoes,
                builder: (context, state) => const PaginaListaRedacoes(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: NomesRotas.novaRedacao,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) => const PaginaFormRedacao(),
      ),
      GoRoute(
        path: NomesRotas.detalhesRedacao,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PaginaDetalhesRedacao(redacaoId: id);
        },
      ),
      GoRoute(
        path: NomesRotas.editarRedacao,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final id = state.pathParameters['id']!;
              final redacaoAsync = ref.watch(redacaoPorIdProvider(id));
              return redacaoAsync.when(
                loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Scaffold(
                  body: Center(child: Text('Erro: $e')),
                ),
                data: (r) {
                  if (r == null) {
                    return const Scaffold(
                      body: Center(child: Text('Redação não encontrada.')),
                    );
                  }
                  return PaginaFormRedacao(redacao: r);
                },
              );
            },
          );
        },
      ),
      GoRoute(
        path: NomesRotas.corrigirRedacao,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PaginaFormCorrecao(redacaoId: id);
        },
      ),
      GoRoute(
        path: NomesRotas.conta,
        parentNavigatorKey: navegadorRaizKey,
        builder: (context, state) => const PaginaInfoConta(),
      ),
    ],
  );
});
