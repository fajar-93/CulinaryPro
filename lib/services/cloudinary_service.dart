import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class CloudinaryService {
  static const String _cloudName = 'dkta7ujvt';
  static const String _uploadPreset = 'recipe_upload';

  /// Upload image to Cloudinary
  Future<String> uploadImage(File image) async {
    return _uploadFile(
      file: image,
      resourceType: 'image',
      folder: 'culinarypro/images',
    );
  }

  /// Upload video to Cloudinary
  Future<String> uploadVideo(File video) async {
    return _uploadFile(
      file: video,
      resourceType: 'video',
      folder: 'culinarypro/videos',
    );
  }

  Future<String> _uploadFile({
    required File file,
    required String resourceType,
    required String folder,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] = folder;

    final mimeTypeData = lookupMimeType(file.path)?.split('/');
    final fileExtension = p.extension(file.path);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: filename,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      ),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      throw Exception(data['error']['message'] ?? 'Upload gagal');
    }
  }
}
