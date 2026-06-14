import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../theme/app_theme.dart';

class EditorScreen extends StatefulWidget {
  final Memo? existingMemo;
  final void Function(Memo memo)? onSaved;

  const EditorScreen({
    super.key,
    this.existingMemo,
    this.onSaved,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _hasReminder;
  late DateTime _reminderTime;
  late bool _isPinned;
  late bool _reminded;
  bool _hasChanges = false;
  bool _showReminderSettings = false;

  @override
  void initState() {
    super.initState();
    final memo = widget.existingMemo;
    _titleController = TextEditingController(text: memo?.title ?? '');
    _contentController = TextEditingController(text: memo?.content ?? '');
    _hasReminder = memo?.hasReminder ?? false;
    _reminderTime = memo?.reminderTime ?? _defaultReminderTime();
    _isPinned = memo?.isPinned ?? false;
    _reminded = memo?.reminded ?? false;
    _showReminderSettings = _hasReminder;

    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
  }

  DateTime _defaultReminderTime() {
    final now = DateTime.now();
    // 默认明天上午9:00
    return DateTime(now.year, now.month, now.day + 1, 9, 0);
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final memo = Memo(
      id: widget.existingMemo?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isPinned: _isPinned,
      hasReminder: _hasReminder,
      reminderTime: _hasReminder ? _reminderTime : null,
      reminded: _reminded,
      createdAt: widget.existingMemo?.createdAt,
    );
    widget.onSaved?.call(memo);
    Navigator.pop(context);
  }

  void _showReminderPicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _reminderTime,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: '选择提醒日期',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderTime),
      helpText: '选择提醒时间',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (time == null || !mounted) return;

    setState(() {
      _reminderTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
      _hasChanges = true;
    });
  }

  void _quickReminder(Duration offset) {
    setState(() {
      _reminderTime = DateTime.now().add(offset);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMemo != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              _save();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(isEditing ? '编辑备忘录' : '新建备忘录'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? AppTheme.accentColor(context) : null,
            ),
            tooltip: '置顶',
            onPressed: () => setState(() {
              _isPinned = !_isPinned;
              _hasChanges = true;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '保存',
            onPressed: _save,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题输入
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain(context),
                ),
                decoration: InputDecoration(
                  hintText: '输入标题...',
                  border: InputBorder.none,
                  filled: false,
                ),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 8),

              // 内容输入
              TextField(
                controller: _contentController,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMain(context),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: '输入备忘录内容...',
                  border: InputBorder.none,
                  filled: false,
                ),
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),

              const SizedBox(height: 24),

              // 分隔线
              Divider(color: AppTheme.divider(context)),

              const SizedBox(height: 16),

              // 提醒设置区域
              _buildReminderSection(c),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSection(Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提醒开关
          Row(
            children: [
              const Icon(Icons.alarm, color: AppTheme.warning, size: 22),
              const SizedBox(width: 10),
              Text(
                '时间提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMain(context),
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: _hasReminder,
                activeColor: AppTheme.accentColor(context),
                onChanged: (v) {
                  setState(() {
                    _hasReminder = v;
                    _showReminderSettings = v;
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),

          // 提醒详细设置
          if (_showReminderSettings && _hasReminder) ...[
            const SizedBox(height: 16),
            Divider(color: AppTheme.divider(context)),
            const SizedBox(height: 16),

            // 当前提醒时间
            GestureDetector(
              onTap: _showReminderPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.accentColor(context).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: AppTheme.accent),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '提醒时间',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(_reminderTime),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentColor(context),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '更改',
                      style: TextStyle(
                        color: AppTheme.accentColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 快捷按钮
            Text(
              '快捷设置',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickButton('今天 18:00', () {
                  final now = DateTime.now();
                  _quickReminder(
                    DateTime(now.year, now.month, now.day, 18, 0).difference(now),
                  );
                }),
                _quickButton('明天 9:00', () {
                  final now = DateTime.now();
                  _quickReminder(
                    DateTime(now.year, now.month, now.day + 1, 9, 0)
                        .difference(now),
                  );
                }),
                _quickButton('1小时后', () {
                  _quickReminder(const Duration(hours: 1));
                }),
                _quickButton('30分钟后', () {
                  _quickReminder(const Duration(minutes: 30));
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor(context).withOpacity(0.1),
        foregroundColor: AppTheme.accentColor(context),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final wd = weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month}月${dt.day}日 周$wd '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
