import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../../core/errors/tradutor_erros_auth.dart';
import '../../../core/utils/carregador_imagem.dart';
import '../../../core/utils/formatador_data.dart';
import '../../../core/utils/validador_senha.dart';
import '../../../routes/nomes_rotas.dart';
import '../../../services/provedores_globais.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/campo_senha.dart';
import '../../../widgets/campo_texto.dart';
import '../../../widgets/indicador_forca_senha.dart';
import 'dados_iniciais_cadastro.dart';

class PaginaCadastro extends ConsumerStatefulWidget {
  final DadosIniciaisCadastro? dadosIniciais;

  const PaginaCadastro({super.key, this.dadosIniciais});

  @override
  ConsumerState<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends ConsumerState<PaginaCadastro> {
  final _chaveForm = GlobalKey<FormState>();
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _controladorConfirmar = TextEditingController();
  DateTime? _dataNascimento;
  String? _fotoPath;
  bool _salvando = false;
  String _senhaAtual = '';

  bool get _completandoAuth =>
      widget.dadosIniciais?.completandoAuth ?? false;

  @override
  void initState() {
    super.initState();
    final dados = widget.dadosIniciais;
    if (dados != null) {
      _controladorNome.text = dados.nomeCompleto;
      _controladorEmail.text = dados.email;
    }
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    _controladorConfirmar.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate:
          _dataNascimento ?? DateTime(hoje.year - 18, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );
    if (selecionada != null) {
      setState(() => _dataNascimento = selecionada);
    }
  }

  Future<void> _selecionarFoto() async {
    final seletor = ref.read(servicoSeletorImagemProvider);
    final escolha = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              if (_fotoPath != null)
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: AppColors.erro),
                  title: const Text(
                    'Remover foto',
                    style: TextStyle(color: AppColors.erro),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _fotoPath = null);
                  },
                ),
            ],
          ),
        );
      },
    );
    if (escolha == null) return;
    final path = escolha == ImageSource.camera
        ? await seletor.tirarFoto()
        : await seletor.escolherDaGaleria();
    if (path != null) setState(() => _fotoPath = path);
  }

  Future<void> _cancelarCompletando() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar cadastro'),
          content: const Text(
            'Cancelando agora, você sairá da conta. Tem certeza?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.erro),
              child: const Text('Sim, sair'),
            ),
          ],
        );
      },
    );
    if (confirmar != true) return;
    await ref.read(repositorioAuthProvider).sair();
  }

  Future<void> _cadastrar() async {
    if (!_chaveForm.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a data de nascimento.'),
        ),
      );
      return;
    }
    if (!_completandoAuth) {
      if (!ValidadorSenha.ehValida(_controladorSenha.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A senha não atende os requisitos.'),
          ),
        );
        return;
      }
      if (_controladorSenha.text != _controladorConfirmar.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não conferem.')),
        );
        return;
      }
    }
    setState(() => _salvando = true);
    final repo = ref.read(repositorioAuthProvider);
    try {
      if (_completandoAuth) {
        await repo.criarPerfilUsuarioAutenticado(
          nomeCompleto: _controladorNome.text,
          dataNascimento: _dataNascimento!,
          fotoUrl: _fotoPath,
        );
      } else {
        await repo.cadastrar(
          nomeCompleto: _controladorNome.text,
          dataNascimento: _dataNascimento!,
          email: _controladorEmail.text,
          senha: _controladorSenha.text,
          fotoUrl: _fotoPath,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: AppColors.sucesso,
        ),
      );
      context.go(NomesRotas.home);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TradutorErrosAuth.traduzir(erro))),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _avatarSelecionavel() {
    final inicial = _controladorNome.text.trim().isNotEmpty
        ? _controladorNome.text.trim()[0].toUpperCase()
        : '?';
    final imagem = CarregadorImagem.imagemPara(_fotoPath);
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.bege,
            backgroundImage: imagem,
            child: imagem == null
                ? Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.preto,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: AppColors.verde,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _selecionarFoto,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.branco,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_completandoAuth ? 'Complete seu cadastro' : 'Criar Conta'),
        leading: _completandoAuth
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelarCompletando,
                tooltip: 'Cancelar',
              )
            : null,
        automaticallyImplyLeading: !_completandoAuth,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _chaveForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_completandoAuth)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.verde.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.verde.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.verde),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Autenticado com Google. Complete seus dados para finalizar.',
                            style: TextStyle(color: AppColors.textoForte),
                          ),
                        ),
                      ],
                    ),
                  ),
                _avatarSelecionavel(),
                const SizedBox(height: 24),
                CampoTexto(
                  controlador: _controladorNome,
                  rotulo: 'Nome completo',
                  icone: Icons.person_outline,
                  acaoTeclado: TextInputAction.next,
                  validador: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o nome completo.';
                    }
                    if (!v.trim().contains(' ')) {
                      return 'Informe nome e sobrenome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selecionarData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dataNascimento == null
                          ? 'Selecionar data'
                          : FormatadorData.data(_dataNascimento!),
                      style: TextStyle(
                        color: _dataNascimento == null
                            ? AppColors.textoApagado
                            : AppColors.textoForte,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _controladorEmail,
                  rotulo: 'E-mail',
                  icone: Icons.email_outlined,
                  tipoTeclado: TextInputType.emailAddress,
                  acaoTeclado: TextInputAction.next,
                  habilitado: !_completandoAuth,
                  validador: (v) {
                    if (_completandoAuth) return null;
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
                if (!_completandoAuth) ...[
                  const SizedBox(height: 16),
                  CampoSenha(
                    controlador: _controladorSenha,
                    rotulo: 'Senha',
                    acaoTeclado: TextInputAction.next,
                    aoMudar: (v) => setState(() => _senhaAtual = v),
                    validador: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha.';
                      if (!ValidadorSenha.ehValida(v)) {
                        return 'A senha não atende os requisitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  IndicadorForcaSenha(senha: _senhaAtual),
                  const SizedBox(height: 16),
                  CampoSenha(
                    controlador: _controladorConfirmar,
                    rotulo: 'Confirmar senha',
                    acaoTeclado: TextInputAction.done,
                    aoSubmeter: (_) => _cadastrar(),
                    validador: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirme a senha.';
                      }
                      if (v != _controladorSenha.text) {
                        return 'As senhas não conferem.';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _salvando ? null : _cadastrar,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.branco,
                          ),
                        )
                      : Text(_completandoAuth ? 'Finalizar cadastro' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
