// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveAndOpenPolicyPdfPlatform({
  required List<int> bytes,
  required String fileName,
}) async {
  final blob = html.Blob(
    <dynamic>[Uint8List.fromList(bytes)],
    'application/pdf',
  );

  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  // Give the browser a moment to start the download before releasing
  // the object URL.
  await Future<void>.delayed(const Duration(milliseconds: 100));
  html.Url.revokeObjectUrl(url);
}
