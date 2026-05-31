import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants/app_constants.dart';
import '../firebase_options.dart';
import '../models/correcao.dart';
import '../models/perfil_usuario.dart';
import '../models/redacao.dart';
import '../models/status_redacao.dart';
import '../models/tipo_prova.dart';
import '../models/tipo_usuario.dart';

class SementeDados {
  SementeDados._();

  static const String emailProfessor = 'professor@redacaoelite.com';
  static const String emailAluno = 'aluno@redacaoelite.com';
  static const String senhaPadrao = 'Senha@123';

  static const String nomeProfessor = 'Nikolas Geremias de Souza';
  static const String nomeAluno = 'João da Silva';

  static const List<String> _imagensRedacao = [
    'https://picsum.photos/seed/redacao1/600/800',
    'https://picsum.photos/seed/redacao2/600/800',
    'https://picsum.photos/seed/redacao3/600/800',
  ];

  static const List<String> _imagensCorrecao = [
    'https://picsum.photos/seed/correcao1/600/800',
    'https://picsum.photos/seed/correcao2/600/800',
    'https://picsum.photos/seed/correcao3/600/800',
  ];

  static const List<String> _temas = [
    'Educação financeira nas escolas brasileiras',
    'Impactos das fake news na sociedade contemporânea',
    'Sustentabilidade urbana e mobilidade verde',
    'Saúde mental dos jovens no Brasil',
    'Inclusão digital em comunidades periféricas',
    'Combate à violência contra a mulher',
    'Lixo plástico nos oceanos',
    'Trabalho remoto pós-pandemia',
    'Ensino a distância e suas limitações',
    'Patrimônio histórico cultural brasileiro',
  ];

  static const List<String> _titulos = [
    'A urgência da educação financeira no Brasil',
    'Combate às fake news como responsabilidade coletiva',
    'Caminhos para cidades sustentáveis',
    'Saúde mental: o desafio invisível da juventude',
    'Inclusão digital como direito básico',
    'Quebrando o ciclo da violência doméstica',
    'O oceano de plástico que herdamos',
    'Os novos contornos do trabalho contemporâneo',
    'EaD: avanços e desafios no contexto brasileiro',
    'Memória nacional: preservar é resistir',
  ];

  static const List<String> _comentarios = [
    'Bom desenvolvimento do tema. Atenção à coesão dos parágrafos.',
    'Argumentação consistente. Falta aprofundar a proposta de intervenção.',
    'Excelente uso da norma culta. Continue assim!',
    'A introdução pode ser mais impactante. Bom conteúdo geral.',
    'Cuidado com a repetição de palavras. Vocabulário pode ser ampliado.',
    'Tese clara e bem defendida. Trabalhe a conclusão.',
    'Estrutura textual adequada. Reveja a concordância em alguns trechos.',
  ];

  static Future<ResultadoSemente> executar() async {
    final log = StringBuffer();
    try {
      log.writeln('Criando professor...');
      final uidProfessor = await _criarOuObterUsuario(
        emailProfessor,
        senhaPadrao,
        'seed_prof',
      );
      await _gravarPerfil(
        uid: uidProfessor,
        nome: nomeProfessor,
        email: emailProfessor,
        tipo: TipoUsuario.professor,
        dataNascimento: DateTime(1996, 5, 20),
      );
      log.writeln('Professor pronto: $emailProfessor');

      log.writeln('Criando aluno...');
      final uidAluno = await _criarOuObterUsuario(
        emailAluno,
        senhaPadrao,
        'seed_aluno',
      );
      await _gravarPerfil(
        uid: uidAluno,
        nome: nomeAluno,
        email: emailAluno,
        tipo: TipoUsuario.aluno,
        dataNascimento: DateTime(2005, 3, 22),
        creditosForcados: 0,
      );
      log.writeln('Aluno pronto: $emailAluno (créditos zerados)');

      log.writeln('Verificando redações existentes...');
      final criadas = await _criarRedacoesSeNaoExistirem(
        uidAluno: uidAluno,
        uidProfessor: uidProfessor,
      );
      if (criadas == 0) {
        log.writeln('Redações já existem, pulando criação.');
      } else {
        log.writeln('Redações criadas: $criadas');
      }

      return ResultadoSemente(
        sucesso: true,
        log: log.toString(),
        emailProfessor: emailProfessor,
        emailAluno: emailAluno,
        senha: senhaPadrao,
      );
    } catch (erro) {
      log.writeln('ERRO: $erro');
      return ResultadoSemente(
        sucesso: false,
        log: log.toString(),
        emailProfessor: emailProfessor,
        emailAluno: emailAluno,
        senha: senhaPadrao,
      );
    }
  }

  static Future<String> _criarOuObterUsuario(
    String email,
    String senha,
    String apelidoApp,
  ) async {
    final nomeApp = '${apelidoApp}_${DateTime.now().millisecondsSinceEpoch}';
    final app = await Firebase.initializeApp(
      name: nomeApp,
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: app);
      String uid;
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
        uid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
        final cred = await auth.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
        uid = cred.user!.uid;
      }
      await auth.signOut();
      return uid;
    } finally {
      await app.delete();
    }
  }

  static Future<void> _gravarPerfil({
    required String uid,
    required String nome,
    required String email,
    required TipoUsuario tipo,
    required DateTime dataNascimento,
    int? creditosForcados,
  }) async {
    final agora = DateTime.now();
    final creditos = creditosForcados ??
        (tipo == TipoUsuario.aluno ? AppConstants.creditosIniciais : 0);
    final perfil = PerfilUsuario(
      id: uid,
      nomeCompleto: nome,
      dataNascimento: dataNascimento,
      email: email,
      tipo: tipo,
      creditos: creditos,
      criadoEm: agora,
      atualizadoEm: agora,
      ultimaRenovacaoCreditos:
          tipo == TipoUsuario.aluno ? agora : null,
    );
    await FirebaseFirestore.instance
        .collection(AppConstants.colecaoUsuarios)
        .doc(uid)
        .set(perfil.paraMapa());
  }

  static Future<int> _criarRedacoesSeNaoExistirem({
    required String uidAluno,
    required String uidProfessor,
  }) async {
    final colecaoRedacoes = FirebaseFirestore.instance
        .collection(AppConstants.colecaoRedacoes);
    final colecaoCorrecoes = FirebaseFirestore.instance
        .collection(AppConstants.colecaoCorrecoes);

    final existentes = await colecaoRedacoes
        .where('userId', isEqualTo: uidAluno)
        .limit(1)
        .get();
    if (existentes.docs.isNotEmpty) return 0;

    final agora = DateTime.now();
    var criadas = 0;

    for (var i = 0; i < 40; i++) {
      final tipoProva = i.isEven ? TipoProva.enem : TipoProva.acafe;
      final tema = _temas[i % _temas.length];
      final titulo = _titulos[i % _titulos.length];
      final imagemRedacao = _imagensRedacao[i % _imagensRedacao.length];

      final StatusRedacao status;
      final int diasAtrasCriacao;

      if (i < 8) {
        status = StatusRedacao.rascunho;
        diasAtrasCriacao = (i + 1) * 2;
      } else if (i < 20) {
        status = StatusRedacao.enviada;
        diasAtrasCriacao = 5 + (i - 8) * 2;
      } else {
        status = StatusRedacao.corrigida;
        diasAtrasCriacao = 15 + (i - 20) * 4;
      }

      final criadoEm =
          agora.subtract(Duration(days: diasAtrasCriacao));
      final atualizadoEm = criadoEm.add(const Duration(hours: 2));
      DateTime? enviadoEm;
      String? correcaoId;

      if (status != StatusRedacao.rascunho) {
        enviadoEm = atualizadoEm;
      }

      final redacaoRef = colecaoRedacoes.doc();

      if (status == StatusRedacao.corrigida) {
        final indiceCorrigida = i - 20;
        int diasAtrasCorrecao;
        if (indiceCorrigida < 7) {
          diasAtrasCorrecao = indiceCorrigida + 1;
        } else if (indiceCorrigida < 14) {
          diasAtrasCorrecao = 8 + (indiceCorrigida - 7);
        } else {
          diasAtrasCorrecao = 15 + (indiceCorrigida - 14) * 2;
        }
        if (diasAtrasCorrecao >= diasAtrasCriacao) {
          diasAtrasCorrecao = diasAtrasCriacao - 1;
        }
        final correcaoCriadoEm =
            agora.subtract(Duration(days: diasAtrasCorrecao));

        final progressao = (i - 20) / 19.0;
        late double c1, c2, c3, c4, c5;
        if (tipoProva == TipoProva.enem) {
          final base = 80 + progressao * 100;
          c1 = _arredondarEnem(base + 20 * (i % 5));
          c2 = _arredondarEnem(base + 20 * ((i + 1) % 5));
          c3 = _arredondarEnem(base + 20 * ((i + 2) % 5));
          c4 = _arredondarEnem(base + 20 * ((i + 3) % 5));
          c5 = _arredondarEnem(base + 20 * ((i + 4) % 5));
        } else {
          final base = 1.0 + progressao * 1.0;
          c1 = _arredondarAcafe(base + 0.1 * (i % 5));
          c2 = _arredondarAcafe(base + 0.1 * ((i + 1) % 5));
          c3 = _arredondarAcafe(base + 0.1 * ((i + 2) % 5));
          c4 = _arredondarAcafe(base + 0.1 * ((i + 3) % 5));
          c5 = 0.0;
        }

        final correcaoRef = colecaoCorrecoes.doc();
        final correcao = Correcao(
          id: correcaoRef.id,
          redacaoId: redacaoRef.id,
          professorId: uidProfessor,
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
          comentario: _comentarios[i % _comentarios.length],
          imagemCorrecaoUrl:
              _imagensCorrecao[i % _imagensCorrecao.length],
          criadoEm: correcaoCriadoEm,
          atualizadoEm: correcaoCriadoEm,
        );

        await correcaoRef.set(correcao.paraMapa());
        correcaoId = correcaoRef.id;
      }

      final redacao = Redacao(
        id: redacaoRef.id,
        usuarioId: uidAluno,
        titulo: titulo,
        tema: tema,
        tipoProva: tipoProva,
        imagemUrl: imagemRedacao,
        status: status,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        enviadoEm: enviadoEm,
        correcaoId: correcaoId,
      );

      await redacaoRef.set(redacao.paraMapa());
      criadas++;
    }

    return criadas;
  }

  static double _arredondarEnem(double valor) {
    final clamped = valor.clamp(0.0, 200.0);
    return (clamped / 40).round() * 40.0;
  }

  static double _arredondarAcafe(double valor) {
    final clamped = valor.clamp(0.0, 2.5);
    return (clamped * 10).round() / 10.0;
  }
}

class ResultadoSemente {
  final bool sucesso;
  final String log;
  final String emailProfessor;
  final String emailAluno;
  final String senha;

  ResultadoSemente({
    required this.sucesso,
    required this.log,
    required this.emailProfessor,
    required this.emailAluno,
    required this.senha,
  });
}
