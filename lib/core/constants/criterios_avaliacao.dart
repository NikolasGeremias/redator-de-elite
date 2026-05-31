import '../../models/tipo_prova.dart';

class CriteriosAvaliacao {
  CriteriosAvaliacao._();

  static const List<String> enem = [
    'Domínio da norma padrão da língua portuguesa',
    'Compreensão da proposta de redação',
    'Seleção e organização dos argumentos',
    'Conhecimento dos mecanismos linguísticos',
    'Elaboração da proposta de intervenção',
  ];

  static const List<String> acafe = [
    'Adequação ao tema, gênero e tipologia textual',
    'Coerência e coesão textual',
    'Argumentação e desenvolvimento das ideias',
    'Domínio da norma padrão da língua portuguesa',
  ];

  static List<String> para(TipoProva tipo) =>
      tipo == TipoProva.enem ? enem : acafe;

  static int quantidade(TipoProva tipo) =>
      tipo == TipoProva.enem ? 5 : 4;

  static double notaMaximaPorItem(TipoProva tipo) =>
      tipo == TipoProva.enem ? 200.0 : 2.5;

  static double notaMaximaTotal(TipoProva tipo) =>
      tipo == TipoProva.enem ? 1000.0 : 10.0;

  static String rotuloItem(TipoProva tipo) =>
      tipo == TipoProva.enem ? 'Competência' : 'Critério';

  static String formatarNotaItem(double nota, TipoProva tipo) {
    if (tipo == TipoProva.enem) return nota.toStringAsFixed(0);
    return nota.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String formatarNotaTotal(double nota, TipoProva tipo) {
    if (tipo == TipoProva.enem) return nota.toStringAsFixed(0);
    return nota.toStringAsFixed(1).replaceAll('.', ',');
  }
}
