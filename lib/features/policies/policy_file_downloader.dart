import 'policy_file_downloader_io.dart' if (dart.library.html) 'policy_file_downloader_web.dart';

Future<void> saveAndOpenPolicyPdf({
  required List<int> bytes,
  required String fileName,
}) {
  return saveAndOpenPolicyPdfPlatform(
    bytes: bytes,
    fileName: fileName,
  );
}
