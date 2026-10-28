import 'package:dio/dio.dart';
import 'package:hrms_ai_copilot/core/network/api_client.dart';
import 'package:hrms_ai_copilot/core/network/api_constants.dart';
import 'package:hrms_ai_copilot/models/ai_chat_response_model.dart';
import 'package:hrms_ai_copilot/models/ai_conversation_model.dart';

/// All AI chat data is stored by FastAPI in PostgreSQL, not on the device.
class AiChatRepository {
  final ApiClient _apiClient;

  const AiChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<AiConversationModel>> getConversations() async {
    final response = await _apiClient.get(ApiRoutes.aiConversations);
    final data = response.data as List<dynamic>? ?? const [];
    return data.whereType<Map<String, dynamic>>().map(AiConversationModel.fromJson).toList();
  }

  Future<AiConversationDetailModel> getConversation(String id) async {
    final response = await _apiClient.get(ApiRoutes.aiConversation(id));
    return AiConversationDetailModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AiChatResponseModel> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    final body = <String, dynamic>{
      'message': message,
    };

    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }

    final response = await _apiClient.post(
      ApiRoutes.aiChat,
      data: body,
      options: Options(
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    return AiChatResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> resetConversation(String id) async {
    await _apiClient.delete(ApiRoutes.aiConversationMessages(id));
  }

  Future<void> deleteConversation(String id) async {
    await _apiClient.delete(ApiRoutes.aiConversation(id));
  }
}
