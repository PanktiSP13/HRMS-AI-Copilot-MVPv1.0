/// Models returned by the backend's PostgreSQL-backed AI conversation APIs.
class AiConversationModel {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AiConversationModel({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory AiConversationModel.fromJson(Map<String, dynamic> json) {
    return AiConversationModel(
      id: json['id'].toString(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'New Chat',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class AiConversationMessageModel {
  final int? id;
  final String role;
  final String content;
  final DateTime? createdAt;

  const AiConversationMessageModel({
    this.id,
    required this.role,
    required this.content,
    this.createdAt,
  });

  bool get isUser => role.toLowerCase() == 'user';

  factory AiConversationMessageModel.fromJson(Map<String, dynamic> json) {
    return AiConversationMessageModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      role: (json['role'] as String? ?? 'assistant').toLowerCase(),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class AiConversationDetailModel extends AiConversationModel {
  final List<AiConversationMessageModel> messages;

  const AiConversationDetailModel({
    required super.id,
    required super.title,
    super.createdAt,
    super.updatedAt,
    required this.messages,
  });

  factory AiConversationDetailModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return AiConversationDetailModel(
      id: json['id'].toString(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'New Chat',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(AiConversationMessageModel.fromJson)
          .toList(),
    );
  }
}
