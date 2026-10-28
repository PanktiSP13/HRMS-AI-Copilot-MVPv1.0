// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatResponseModel _$AiChatResponseModelFromJson(Map<String, dynamic> json) =>
    AiChatResponseModel(
      message: json['message'] as String,
      conversationId: json['conversation_id'] as String?,
      inputTokens: (json['input_tokens'] as num?)?.toInt(),
      outputTokens: (json['output_tokens'] as num?)?.toInt(),
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AiChatResponseModelToJson(
        AiChatResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'conversation_id': instance.conversationId,
      'input_tokens': instance.inputTokens,
      'output_tokens': instance.outputTokens,
      'total_tokens': instance.totalTokens,
    };
