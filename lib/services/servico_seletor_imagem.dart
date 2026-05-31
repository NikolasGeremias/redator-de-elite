import 'package:image_picker/image_picker.dart';

class ServicoSeletorImagem {
  final ImagePicker _picker;

  ServicoSeletorImagem({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  Future<String?> tirarFoto() async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return foto?.path;
  }

  Future<String?> escolherDaGaleria() async {
    final foto = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return foto?.path;
  }
}
