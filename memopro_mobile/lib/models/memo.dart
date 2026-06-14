import 'package:uuid/uuid.dart';

class Memo {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  bool hasReminder;
  DateTime? reminderTime;
  bool reminded;

  Memo({
    String? id,
    this.title = '',
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.hasReminder = false,
    this.reminderTime,
    this.reminded = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
        'hasReminder': hasReminder,
        'reminderTime': reminderTime?.toIso8601String(),
        'reminded': reminded,
      };

  factory Memo.fromJson(Map<String, dynamic> json) => Memo(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
        hasReminder: json['hasReminder'] as bool? ?? false,
        reminderTime: json['reminderTime'] != null
            ? DateTime.parse(json['reminderTime'] as String)
            : null,
        reminded: json['reminded'] as bool? ?? false,
      );

  Memo copyWith({
    String? title,
    String? content,
    bool? isPinned,
    bool? hasReminder,
    DateTime? reminderTime,
    bool? reminded,
  }) =>
      Memo(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        isPinned: isPinned ?? this.isPinned,
        hasReminder: hasReminder ?? this.hasReminder,
        reminderTime: reminderTime ?? this.reminderTime,
        reminded: reminded ?? this.reminded,
      );

  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (content.trim().isNotEmpty) {
      return content.trim().length > 50
          ? '${content.trim().substring(0, 50)}...'
          : content.trim();
    }
    return '新建备忘录';
  }

  String get displayContent {
    if (content.trim().isEmpty) return '点击编辑内容...';
    return content.trim();
  }

  String get displayDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${updatedAt.month}/${updatedAt.day} ${updatedAt.hour}:${updatedAt.minute.toString().padLeft(2, '0')}';
  }

  bool get isOverdue {
    if (!hasReminder || reminderTime == null || reminded) return false;
    return reminderTime!.isBefore(DateTime.now());
  }
}
