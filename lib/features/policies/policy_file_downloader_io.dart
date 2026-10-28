import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndOpenPolicyPdfPlatform({
  required List<int> bytes,
  required String fileName,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(
    bytes,
    flush: true,
  );

  final result = await OpenFilex.open(file.path);

  if (result.type != ResultType.done) {
    throw Exception(
      result.message.isNotEmpty
          ? result.message
          : 'Unable to open the downloaded PDF.',
    );
  }
}
