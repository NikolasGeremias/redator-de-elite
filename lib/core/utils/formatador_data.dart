import 'package:intl/intl.dart';

class FormatadorData {
  FormatadorData._();

  static final DateFormat _ddMMyyyy = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _ddMMyyyyHHmm = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final DateFormat _ddMMM = DateFormat('dd MMM', 'pt_BR');

  static String data(DateTime data) => _ddMMyyyy.format(data);
  static String dataHora(DateTime data) => _ddMMyyyyHHmm.format(data);
  static String dataCurta(DateTime data) => _ddMMM.format(data);
}
