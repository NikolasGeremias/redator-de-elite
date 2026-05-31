import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/provedores_globais.dart';
import '../../widgets/carregando.dart';
import '../../widgets/mensagem_erro.dart';
import 'pagina_home_aluno.dart';
import 'pagina_home_professor.dart';

class PaginaHome extends ConsumerWidget {
  const PaginaHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilAtualProvider);
    return perfilAsync.when(
      loading: () => const Carregando(),
      error: (e, _) =>
          MensagemErro(mensagem: 'Falha ao carregar perfil: $e'),
      data: (perfil) {
        if (perfil == null) {
          return const Carregando(mensagem: 'Carregando perfil...');
        }
        if (perfil.ehProfessor) {
          return PaginaHomeProfessor(perfil: perfil);
        }
        return PaginaHomeAluno(perfil: perfil);
      },
    );
  }
}
