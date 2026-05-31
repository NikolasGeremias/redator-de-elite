import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/tradutor_erros_auth.dart';
import '../../../dev/semente_dados.dart';
import '../../../routes/nomes_rotas.dart';
import '../../../services/provedores_globais.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/botao_google.dart';
import '../../../widgets/campo_senha.dart';
import '../../../widgets/campo_texto.dart';
import '../../../widgets/logo_app.dart';
import '../register/dados_iniciais_cadastro.dart';

class PaginaLogin extends ConsumerStatefulWidget {
  const PaginaLogin({super.key});

  @override
  ConsumerState<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends ConsumerState<PaginaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  bool _entrando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_chaveForm.currentState!.validate()) return;
    setState(() => _entrando = true);
    try {
      await ref.read(repositorioAuthProvider).entrarComEmailSenha(
            _controladorEmail.text,
            _controladorSenha.text,
          );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TradutorErrosAuth.traduzir(erro))),
      );
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<void> _entrarComGoogle() async {
    setState(() => _entrando = true);
    try {
      final resultado = await ref.read(repositorioAuthProvider).entrarComGoogle();
      if (resultado.usuario == null) {
        if (mounted) setState(() => _entrando = false);
        return;
      }
      if (resultado.perfilExistente) {
        return;
      }
      if (!mounted) return;
      context.go(
        NomesRotas.cadastro,
        extra: DadosIniciaisCadastro(
          nomeCompleto: resultado.sugestaoNome ?? '',
          email: resultado.sugestaoEmail ?? '',
          fotoUrl: resultado.sugestaoFoto,
          completandoAuth: true,
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() => _entrando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TradutorErrosAuth.traduzir(erro))),
      );
    }
  }

  Future<void> _executarSeed() async {
    setState(() => _entrando = true);
    try {
      final resultado = await SementeDados.executar();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              resultado.sucesso ? 'Mock criado' : 'Erro ao criar mock',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Professor: ${resultado.emailProfessor}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text(
                    'Aluno: ${resultado.emailAluno}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text(
                    'Senha (ambos): ${resultado.senha}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resultado.log,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<void> _redefinirSenha() async {
    final email = _controladorEmail.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o e-mail para redefinir a senha.'),
        ),
      );
      return;
    }
    try {
      await ref
          .read(repositorioAuthProvider)
          .enviarRedefinicaoSenha(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um link de redefinição pro seu e-mail.'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TradutorErrosAuth.traduzir(erro))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _chaveForm,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const LogoApp(tamanho: 160),
                const SizedBox(height: 16),
                Text(
                  'Redação Elite',
                  style: AppTextStyles.tituloGrande.copyWith(
                    color: AppColors.bege,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para continuar',
                  style: AppTextStyles.corpoMedio,
                ),
                const SizedBox(height: 32),
                CampoTexto(
                  controlador: _controladorEmail,
                  rotulo: 'E-mail',
                  icone: Icons.email_outlined,
                  tipoTeclado: TextInputType.emailAddress,
                  acaoTeclado: TextInputAction.next,
                  validador: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o e-mail.';
                    }
                    if (!RegExp(r'^[\w\.-]+@[\w-]+\.[\w\.-]+$')
                        .hasMatch(v.trim())) {
                      return 'E-mail inválido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoSenha(
                  controlador: _controladorSenha,
                  rotulo: 'Senha',
                  acaoTeclado: TextInputAction.done,
                  aoSubmeter: (_) => _entrar(),
                  validador: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha.';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _entrando ? null : _redefinirSenha,
                    child: const Text('Esqueceu a senha?'),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _entrando ? null : _entrar,
                  child: _entrando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.branco,
                          ),
                        )
                      : const Text('Entrar'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou', style: AppTextStyles.legenda),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                BotaoGoogle(
                  aoPressionar: _entrarComGoogle,
                  carregando: _entrando,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem conta? ',
                      style: AppTextStyles.corpo,
                    ),
                    TextButton(
                      onPressed: _entrando
                          ? null
                          : () => context.push(NomesRotas.cadastro),
                      child: const Text('Cadastre-se'),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _entrando ? null : _executarSeed,
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Dev: criar dados mock'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textoApagado,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
