import 'package:dio/dio.dart';
import 'package:hrms_ai_copilot/common/utils.dart';
import 'package:hrms_ai_copilot/features/policies/policy_file_downloader.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/policy.dart';

class PolicyRepository {
  final ApiClient _apiClient;

  PolicyRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<List<Policy>> getPolicies() async {
    final response = await _apiClient.get(ApiRoutes.policies);

    return Utils().toList(response.data).map(Policy.fromJson).toList();
  }

  Future<Policy> getPolicy(int id) async {
    final response = await _apiClient.get(ApiRoutes.policy(id));

    return Policy.fromJson(Utils().toMap(response.data));
  }

  Future<Policy> createPolicy(PolicyCreateRequest request) async {
    final response = await _apiClient.post(
      ApiRoutes.policies,
      data: request.toJson(),
    );

    return Policy.fromJson(Utils().toMap(response.data));
  }

  Future<void> deletePolicy(int id) async {
    await _apiClient.delete(ApiRoutes.policy(id));
  }

  Future<Policy> updatePolicy(
    int id,
    PolicyUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiRoutes.policy(id),
      data: request.toJson(),
    );

    return Policy.fromJson(Utils().toMap(response.data));
  }

  /// Uploads the selected PDF.
  ///
  /// Uses bytes instead of a filesystem path so the same flow works on:
  /// - Android/iOS
  /// - Flutter Web
  Future<Policy> uploadPolicyPdf({
    required String name,
    required String category,
    required String version,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'category': category,
      'version': version,
      ApiMultipartKeys.file: MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });

    final response = await _apiClient.upload(
      ApiRoutes.policyUpload,
      data: formData,
    );

    return Policy.fromJson(Utils().toMap(response.data));
  }

  /// Downloads the original PDF.
  ///
  /// Android/iOS: saves it locally and opens the PDF viewer.
  /// Web: triggers a browser download.
  Future<void> downloadPolicyPdf({
    required int policyId,
    required String fileName,
  }) async {
    final response = await _apiClient.download(
      ApiRoutes.policyDownload(policyId),
    );

    final bytes = response.data as List<int>;
    final safeName = _safeFileName(fileName);
    final finalName = safeName.toLowerCase().endsWith('.pdf') ? safeName : '$safeName.pdf';

    await saveAndOpenPolicyPdf(
      bytes: bytes,
      fileName: finalName,
    );
  }

  String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }
}
