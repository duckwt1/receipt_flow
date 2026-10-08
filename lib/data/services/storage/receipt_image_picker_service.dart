import 'package:image_picker/image_picker.dart';

import '../../../domain/repositories/receipt_image_picker_repository.dart';

class ReceiptImagePickerService implements ReceiptImagePickerRepository {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}
