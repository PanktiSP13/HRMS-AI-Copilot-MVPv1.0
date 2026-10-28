
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_response_model.g.dart';

@JsonSerializable()
class AiChatResponseModel {
  final String message;

  @JsonKey(name: 'conversation_id')
  final String? conversationId;

  @JsonKey(name: 'input_tokens')
  final int? inputTokens;

  @JsonKey(name: 'output_tokens')
  final int? outputTokens;

  @JsonKey(name: 'total_tokens')
  final int? totalTokens;

  const AiChatResponseModel({
    required this.message,
    this.conversationId,
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
  });

  factory AiChatResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AiChatResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatResponseModelToJson(this);
}
