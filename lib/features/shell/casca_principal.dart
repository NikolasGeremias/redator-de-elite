import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/nomes_rotas.dart';
import '../../services/provedores_globais.dart';
import '../../widgets/avatar_perfil.dart';
import '../../widgets/barra_navegacao.dart';
import '../../widgets/carregando.dart';
import '../auth/register/dados_iniciais_cadastro.dart';
import 'menu_lateral.dart';

class CascaPrincipal extends ConsumerStatefulWidget {
  final StatefulNavigationShell navegacao;

  const CascaPrincipal({super.key, required this.navegacao});

  @override
  ConsumerState<CascaPrincipal> createState() => _CascaPrincipalState();
}

class _CascaPrincipalState extends ConsumerState<CascaPrincipal> {
  bool _navegandoParaCadastro = false;

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilAtualProvider);

    return perfilAsync.when(
      loading: () => const Scaffold(body: Carregando()),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro ao carregar perfil: $e')),
      ),
      data: (perfil) {
        if (perfil == null) {
          if (!_navegandoParaCadastro) {
            _navegandoParaCadastro = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final user = ref.read(servicoAuthProvider).usuarioAtual;
              if (user == null) {
                _navegandoParaCadastro = false;
                return;
              }
              context.go(
                NomesRotas.cadastro,
                extra: DadosIniciaisCadastro(
                  nomeCompleto: user.displayName ?? '',
                  email: user.email ?? '',
                  fotoUrl: user.photoURL,
                  completandoAuth: true,
                ),
              );
            });
          }
          return const Scaffold(
            body: Carregando(mensagem: 'Configurando seu perfil...'),
          );
        }
        _navegandoParaCadastro = false;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Redator de Elite'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AvatarPerfil(
                  nomeCompleto: perfil.nomeCompleto,
                  fotoPath: perfil.fotoUrl,
                  raio: 18,
                ),
              ),
            ],
          ),
          drawer: MenuLateral(perfil: perfil),
          body: widget.navegacao,
          bottomNavigationBar: BarraNavegacao(
            indiceAtual: widget.navegacao.currentIndex,
            aoTocar: (indice) => widget.navegacao.goBranch(
              indice,
              initialLocation: indice == widget.navegacao.currentIndex,
            ),
            itens: const [
              ItemBarraNavegacao(
                icone: Icons.home_outlined,
                iconeSelecionado: Icons.home,
                rotulo: 'Home',
              ),
              ItemBarraNavegacao(
                icone: Icons.article_outlined,
                iconeSelecionado: Icons.article,
                rotulo: 'Redações',
              ),
            ],
          ),
        );
      },
    );
  }
}
