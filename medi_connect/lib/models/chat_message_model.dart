class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? json['message'] ?? '',
      isUser: json['isUser'] ?? json['role'] == 'user',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      type: _parseMessageType(json['type']),
      metadata: json['metadata'],
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'symptom':
        return MessageType.symptom;
      case 'advice':
        return MessageType.advice;
      case 'emergency':
        return MessageType.emergency;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }
}

enum MessageType {
  text,
  symptom,
  advice,
  emergency,
}

class SymptomCheckResult {
  final String assessment;
  final String severity; // low, medium, high, emergency
  final List<String> possibleConditions;
  final List<String> recommendations;
  final bool requiresImmediateAttention;

  SymptomCheckResult({
    required this.assessment,
    required this.severity,
    required this.possibleConditions,
    required this.recommendations,
    required this.requiresImmediateAttention,
  });

  factory SymptomCheckResult.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResult(
      assessment: json['assessment'] ?? '',
      severity: json['severity'] ?? 'low',
      possibleConditions: List<String>.from(json['possibleConditions'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      requiresImmediateAttention: json['requiresImmediateAttention'] ?? false,
    );
  }
}
