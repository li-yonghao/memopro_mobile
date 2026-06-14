import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MemoService.instance.addListener(_onDataChanged);
    ReminderService.instance.initialize();

    // 键盘快捷键
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MemoService.instance.removeListener(_onDataChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyN) {
          _createNewMemo();
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyF) {
          setState(() {
            _showSearch = !_showSearch;
            if (_showSearch) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchController.text = '';
                _searchQuery = '';
              });
            }
          });
          return true;
        }
      }
    }
    return false;
  }

  void _createNewMemo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          onSaved: (memo) {
            MemoService.instance.addMemo(memo);
          },
        ),
      ),
    );
  }

  void _openMemo(Memo memo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          existingMemo: memo,
          onSaved: (updated) {
            MemoService.instance.updateMemo(
              memo.id,
              title: updated.title,
              content: updated.content,
              hasReminder: updated.hasReminder,
              reminderTime: updated.reminderTime,
              reminded: updated.reminded,
            );
            // 重新调度提醒
            if (updated.hasReminder && updated.reminderTime != null) {
              ReminderService.instance.scheduleReminder(updated);
            } else {
              ReminderService.instance.cancelReminder(memo);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memos = _searchQuery.isEmpty
        ? MemoService.instance.memos
        : MemoService.instance.search(_searchQuery);
    final pinned = memos.where((m) => m.isPinned).toList();
    final unpinned = memos.where((m) => !m.isPinned).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoPro'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            tooltip: '搜索 (Ctrl+F)',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: '切换主题',
            onPressed: widget.toggleTheme,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'about':
                  _showAbout();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'about', child: Text('关于 MemoPro')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          Expanded(
            child: memos.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      final memo = memos[index];
                      final showPinHeader = index == 0 && memo.isPinned;
                      final showUnpinHeader =
                          index == pinned.length && unpinned.isNotEmpty;
                      return Column(
                        children: [
                          if (showPinHeader) _buildSectionHeader('📌 置顶'),
                          if (showUnpinHeader) _buildSectionHeader('📝 全部'),
                          _buildMemoCard(memo),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewMemo,
        tooltip: '新建备忘录',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '搜索备忘录...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary(context),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMemoCard(Memo memo) {
    final hasReminder = memo.hasReminder && memo.reminderTime != null;
    final isOverdue = memo.isOverdue;

    return Dismissible(
      key: Key(memo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除备忘录'),
            content: Text('确定要删除「${memo.displayTitle}」吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        MemoService.instance.deleteMemo(memo.id);
        ReminderService.instance.cancelReminder(memo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除「${memo.displayTitle}」'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () => MemoService.instance.addMemo(memo),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _openMemo(memo),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        memo.displayTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMain(context),
                          decoration: memo.isPinned
                              ? null
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (memo.isPinned)
                      Icon(Icons.push_pin,
                          size: 16, color: AppTheme.accentColor(context)),
                    if (hasReminder) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isOverdue ? Icons.alarm_off : Icons.alarm,
                        size: 16,
                        color: isOverdue
                            ? AppTheme.danger
                            : AppTheme.accentColor(context),
                      ),
                    ],
                  ],
                ),
                if (memo.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    memo.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(context),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      memo.displayDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    if (hasReminder) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatReminder(memo.reminderTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? AppTheme.danger
                              : AppTheme.accentColor(context),
                        ),
                      ),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () => MemoService.instance.togglePin(memo.id),
                      child: Icon(
                        Icons.push_pin_outlined,
                        size: 18,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.note_add_outlined,
            size: 64,
            color: AppTheme.textSecondary(context).withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '没有找到相关备忘录' : '还没有备忘录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? '换个关键词试试' : '点击右下角 + 创建第一个',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReminder(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('MemoPro'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v1.0.0', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('专业桌面备忘录应用'),
            Text('© 2026 MemoPro'),
            SizedBox(height: 16),
            Text('特性：', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('• 亮暗主题自动切换'),
            Text('• 自定义标题与内容'),
            Text('• 时间提醒闹钟通知'),
            Text('• 置顶 / 搜索 / 滑动删除'),
            Text('• iOS & Android 双端适配'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
