import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../models/perfil_usuario.dart';
import '../../routes/nomes_rotas.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/avatar_perfil.dart';
import '../../widgets/logo_app.dart';

class MenuLateral extends ConsumerWidget {
  final PerfilUsuario perfil;

  const MenuLateral({super.key, required this.perfil});

  Future<void> _confirmarSair(BuildContext context, WidgetRef ref) async {
    final authRepo = ref.read(repositorioAuthProvider);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.erro),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
    if (confirmar != true) return;
    await authRepo.sair();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.pretoSuave,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoApp(tamanho: 140),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.nomeApp,
                      style: AppTextStyles.tituloMedio.copyWith(
                        color: AppColors.bege,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  AvatarPerfil(
                    nomeCompleto: perfil.nomeCompleto,
                    fotoPath: perfil.fotoUrl,
                    raio: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perfil.nomeCompleto,
                          style: AppTextStyles.subtituloDestaque,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          perfil.tipo.rotulo,
                          style: AppTextStyles.legenda.copyWith(
                            color: AppColors.bege,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _ItemMenu(
              icone: Icons.home_outlined,
              titulo: 'Home',
              aoTocar: () {
                Navigator.of(context).pop();
                context.go(NomesRotas.home);
              },
            ),
            _ItemMenu(
              icone: Icons.person_outline,
              titulo: 'Informações da conta',
              aoTocar: () {
                Navigator.of(context).pop();
                context.push(NomesRotas.conta);
              },
            ),
            const Spacer(),
            const Divider(),
            _ItemMenu(
              icone: Icons.logout,
              titulo: 'Sair',
              corDestaque: AppColors.erro,
              aoTocar: () => _confirmarSair(context, ref),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback aoTocar;
  final Color? corDestaque;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.aoTocar,
    this.corDestaque,
  });

  @override
  Widget build(BuildContext context) {
    final cor = corDestaque ?? AppColors.textoForte;
    return ListTile(
      leading: Icon(icone, color: cor),
      title: Text(
        titulo,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: aoTocar,
    );
  }
}
