import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../models/perfil_usuario.dart';
import '../../models/redacao.dart';
import '../../models/status_redacao.dart';
import '../../models/tipo_prova.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/campo_texto.dart';
import '../../widgets/carregando.dart';
import '../../widgets/imagem_inteligente.dart';
import '../../widgets/mensagem_erro.dart';

class PaginaFormRedacao extends ConsumerStatefulWidget {
  final Redacao? redacao;

  const PaginaFormRedacao({super.key, this.redacao});

  @override
  ConsumerState<PaginaFormRedacao> createState() => _PaginaFormRedacaoState();
}

class _PaginaFormRedacaoState extends ConsumerState<PaginaFormRedacao> {
  final _chaveForm = GlobalKey<FormState>();
  final _controladorTitulo = TextEditingController();
  final _controladorTema = TextEditingController();
  TipoProva _tipoProva = TipoProva.enem;
  String? _imagemPath;
  bool _salvando = false;

  bool get _modoEdicao => widget.redacao != null;

  @override
  void initState() {
    super.initState();
    final r = widget.redacao;
    if (r != null) {
      _controladorTitulo.text = r.titulo;
      _controladorTema.text = r.tema;
      _tipoProva = r.tipoProva;
      _imagemPath = r.imagemUrl;
    }
  }

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorTema.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    final seletor = ref.read(servicoSeletorImagemProvider);
    final origem = await showModalBottomSheet<ImageSource>(
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
            ],
          ),
        );
      },
    );
    if (origem == null) return;
    final path = origem == ImageSource.camera
        ? await seletor.tirarFoto()
        : await seletor.escolherDaGaleria();
    if (path != null) setState(() => _imagemPath = path);
  }

  bool _validarParaEnvio() {
    final formOk = _chaveForm.currentState!.validate();
    final imagemOk = _imagemPath != null && _imagemPath!.isNotEmpty;
    if (!formOk && !imagemOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos e adicione a foto da redação.',
          ),
        ),
      );
      return false;
    }
    if (!formOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
        ),
      );
      return false;
    }
    if (!imagemOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione a foto da redação.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _salvarRascunho(PerfilUsuario perfil) async {
    setState(() => _salvando = true);
    try {
      final repo = ref.read(repositorioRedacaoProvider);
      if (_modoEdicao) {
        await repo.atualizar(
          widget.redacao!.copiarCom(
            titulo: _controladorTitulo.text.trim(),
            tema: _controladorTema.text.trim(),
            tipoProva: _tipoProva,
            imagemUrl: _imagemPath ?? '',
            status: StatusRedacao.rascunho,
          ),
        );
      } else {
        await repo.criarRascunho(
          usuarioId: perfil.id,
          titulo: _controladorTitulo.text.trim(),
          tema: _controladorTema.text.trim(),
          tipoProva: _tipoProva,
          imagemUrl: _imagemPath ?? '',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rascunho salvo.')),
      );
      context.pop();
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _enviar(PerfilUsuario perfil) async {
    if (!perfil.temCreditos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você não tem créditos disponíveis. Aguarde a renovação.',
          ),
          backgroundColor: AppColors.aviso,
        ),
      );
      return;
    }
    if (!_validarParaEnvio()) return;
    setState(() => _salvando = true);
    try {
      final repoRedacao = ref.read(repositorioRedacaoProvider);
      final repoUsuario = ref.read(repositorioUsuarioProvider);
      Redacao redacaoAtual;
      if (_modoEdicao) {
        redacaoAtual = await repoRedacao.atualizar(
          widget.redacao!.copiarCom(
            titulo: _controladorTitulo.text.trim(),
            tema: _controladorTema.text.trim(),
            tipoProva: _tipoProva,
            imagemUrl: _imagemPath!,
          ),
        );
      } else {
        redacaoAtual = await repoRedacao.criarRascunho(
          usuarioId: perfil.id,
          titulo: _controladorTitulo.text.trim(),
          tema: _controladorTema.text.trim(),
          tipoProva: _tipoProva,
          imagemUrl: _imagemPath!,
        );
      }
      await repoRedacao.enviar(redacaoAtual);
      await repoUsuario.decrementarCreditos(perfil.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redação enviada com sucesso!'),
          backgroundColor: AppColors.sucesso,
        ),
      );
      context.pop();
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilAtualProvider);
    return perfilAsync.when(
      loading: () => const Scaffold(body: Carregando()),
      error: (e, _) => Scaffold(
        body: MensagemErro(mensagem: 'Falha ao carregar perfil: $e'),
      ),
      data: (perfil) {
        if (perfil == null) {
          return const Scaffold(body: Carregando());
        }
        return _ConteudoForm(
          modoEdicao: _modoEdicao,
          chaveForm: _chaveForm,
          controladorTitulo: _controladorTitulo,
          controladorTema: _controladorTema,
          tipoProva: _tipoProva,
          onTipoProvaMudou: (t) => setState(() => _tipoProva = t),
          imagemPath: _imagemPath,
          onSelecionarImagem: _selecionarImagem,
          onRemoverImagem: () => setState(() => _imagemPath = null),
          salvando: _salvando,
          perfil: perfil,
          onSalvarRascunho: () => _salvarRascunho(perfil),
          onEnviar: () => _enviar(perfil),
        );
      },
    );
  }
}

class _ConteudoForm extends StatelessWidget {
  final bool modoEdicao;
  final GlobalKey<FormState> chaveForm;
  final TextEditingController controladorTitulo;
  final TextEditingController controladorTema;
  final TipoProva tipoProva;
  final ValueChanged<TipoProva> onTipoProvaMudou;
  final String? imagemPath;
  final VoidCallback onSelecionarImagem;
  final VoidCallback onRemoverImagem;
  final bool salvando;
  final PerfilUsuario perfil;
  final VoidCallback onSalvarRascunho;
  final VoidCallback onEnviar;

  const _ConteudoForm({
    required this.modoEdicao,
    required this.chaveForm,
    required this.controladorTitulo,
    required this.controladorTema,
    required this.tipoProva,
    required this.onTipoProvaMudou,
    required this.imagemPath,
    required this.onSelecionarImagem,
    required this.onRemoverImagem,
    required this.salvando,
    required this.perfil,
    required this.onSalvarRascunho,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final temImagem = imagemPath != null && imagemPath!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(modoEdicao ? 'Editar Redação' : 'Nova Redação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: chaveForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  controlador: controladorTitulo,
                  rotulo: 'Título',
                  icone: Icons.title,
                  acaoTeclado: TextInputAction.next,
                  validador: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o título.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: controladorTema,
                  rotulo: 'Tema',
                  icone: Icons.topic_outlined,
                  acaoTeclado: TextInputAction.next,
                  linhasMaximas: 3,
                  validador: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o tema.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () async {
                    final escolha = await showModalBottomSheet<TipoProva>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.bordaForte,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Tipo de prova',
                                      style: AppTextStyles.tituloPequeno,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...TipoProva.values.map(
                                  (t) => ListTile(
                                    leading: const Icon(
                                      Icons.school_outlined,
                                    ),
                                    title: Text(t.rotulo),
                                    trailing: tipoProva == t
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: AppColors.verde,
                                          )
                                        : null,
                                    onTap: () =>
                                        Navigator.of(context).pop(t),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    if (escolha != null) onTipoProvaMudou(escolha);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de prova',
                      prefixIcon: Icon(Icons.school_outlined),
                      suffixIcon: Icon(Icons.expand_more),
                    ),
                    child: Text(
                      tipoProva.rotulo,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textoForte,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Foto da redação', style: AppTextStyles.subtituloDestaque),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: GestureDetector(
                    onTap: onSelecionarImagem,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.bordaForte,
                          width: 2,
                        ),
                      ),
                      child: temImagem
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: ImagemInteligente(
                                caminho: imagemPath,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 48,
                                  color: AppColors.textoApagado,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Toque para adicionar uma foto',
                                  style: AppTextStyles.corpoMedio,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: onSelecionarImagem,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(temImagem ? 'Trocar foto' : 'Adicionar foto'),
                    ),
                    if (temImagem) ...[
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: onRemoverImagem,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remover'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.erro,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: salvando ? null : onEnviar,
                  icon: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.branco,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Enviar redação'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: salvando ? null : onSalvarRascunho,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar como rascunho'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: salvando ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                if (!perfil.temCreditos) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.aviso.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.aviso.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.aviso),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Você está sem créditos. O envio está bloqueado, mas você pode salvar como rascunho.',
                            style: AppTextStyles.corpoMedio,
                          ),
                        ),
                      ],
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
