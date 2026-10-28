import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrms_ai_copilot/common/constants/app_constants.dart';
import 'package:hrms_ai_copilot/common/widgets/app_ui.dart';
import 'package:hrms_ai_copilot/common/widgets/responsive_layout.dart';
import 'package:hrms_ai_copilot/core/providers/app_providers.dart';
import 'package:hrms_ai_copilot/models/ai_conversation_model.dart';

/// [ChatScreen] provides an interactive AI Assistant workspace for HR Q&A.
///
/// Supports:
/// - Asking HR policy, leave balance, employee, or organization questions.
/// - Persisting & retrieving chat history threads.
/// - Adaptive split-screen layout on Desktop (history panel + chat canvas).
/// - Drawer/bottom sheet history picker on Mobile.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AiConversationMessageModel> _messages = [];
  List<AiConversationModel> _conversations = [];
  String? _conversationId;
  String _conversationTitle = 'New Chat';
  bool _isSending = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches saved user conversation threads from the AI backend repository.
  Future<void> _loadConversations() async {
    try {
      final items = await ref.read(aiChatRepositoryProvider).getConversations();
      if (!mounted) return;
      setState(() => _conversations = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    }
  }

  /// Resets state to start a new unlinked chat session.
  void _startNewChat() {
    setState(() {
      _conversationId = null;
      _conversationTitle = 'New Chat';
      _messages = [];
      _error = null;
    });
  }

  /// Loads full message history for the selected conversation thread.
  Future<void> _openConversation(AiConversationModel item) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await ref.read(aiChatRepositoryProvider).getConversation(item.id);
      if (!mounted) return;
      setState(() {
        _conversationId = detail.id;
        _conversationTitle = detail.title;
        _messages = detail.messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _friendlyError(error);
      });
    }
  }

  /// Sends the user message to the AI copilot and receives streaming/async assistant reply.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
      _error = null;
      _messages = [
        ..._messages,
        AiConversationMessageModel(role: 'user', content: text),
      ];
    });
    _scrollToBottom();

    try {
      final response = await ref.read(aiChatRepositoryProvider).sendMessage(
            message: text,
            conversationId: _conversationId,
          );
      if (!mounted) return;
      setState(() {
        _conversationId = response.conversationId ?? _conversationId;
        _messages = [
          ..._messages,
          AiConversationMessageModel(role: 'assistant', content: response.message),
        ];
        if (_conversationTitle == 'New Chat') {
          _conversationTitle = text.length > 60 ? '${text.substring(0, 60)}…' : text;
        }
        _isSending = false;
      });
      await _loadConversations();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _error = _friendlyError(error);
      });
    }
  }

  /// Resets messages in the active chat thread after user confirmation.
  Future<void> _resetCurrentChat() async {
    final id = _conversationId;
    if (id == null) {
      _startNewChat();
      return;
    }
    final confirmed = await _confirm(
      title: 'Reset chat?',
      message: 'This will remove all messages but keep this chat in your history.',
      confirmLabel: 'Reset',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(aiChatRepositoryProvider).resetConversation(id);
      if (!mounted) return;
      setState(() {
        _messages = [];
        _error = null;
      });
      await _loadConversations();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    }
  }

  /// Permanently deletes the active conversation thread.
  Future<void> _deleteCurrentChat() async {
    final id = _conversationId;
    if (id == null) {
      _startNewChat();
      return;
    }
    final confirmed = await _confirm(
      title: 'Delete chat?',
      message: 'This permanently deletes the chat and its messages.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(aiChatRepositoryProvider).deleteConversation(id);
      if (!mounted) return;
      setState(() {
        _conversationId = null;
        _conversationTitle = 'New Chat';
        _messages = [];
        _error = null;
      });
      await _loadConversations();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    }
  }

  /// Shows confirmation alert dialog.
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Displays chat history bottom sheet on mobile devices.
  void _showHistoryMobile() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Chat history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      tooltip: 'New chat',
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _startNewChat();
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _conversations.isEmpty
                    ? const Center(child: Text('No saved chats yet.'))
                    : ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _conversations[index];
                          return ListTile(
                            leading: const Icon(Icons.chat_bubble_outline),
                            title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: item.updatedAt == null ? null : Text(_formatDate(item.updatedAt!)),
                            selected: item.id == _conversationId,
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _openConversation(item);
                            },
                            trailing: IconButton(
                              tooltip: 'Delete chat',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await _confirm(
                                  title: 'Delete chat?',
                                  message: 'This permanently deletes "${item.title}" and its messages.',
                                  confirmLabel: 'Delete',
                                );
                                if (!confirmed || !mounted) return;
                                try {
                                  await ref.read(aiChatRepositoryProvider).deleteConversation(item.id);
                                  if (!mounted) return;
                                  if (_conversationId == item.id) {
                                    setState(() {
                                      _conversationId = null;
                                      _conversationTitle = 'New Chat';
                                      _messages = [];
                                    });
                                  }
                                  await _loadConversations();
                                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                                  if (mounted) _showHistoryMobile();
                                } catch (error) {
                                  if (mounted) setState(() => _error = _friendlyError(error));
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats date into DD/MM/YYYY format string.
  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  /// Cleans technical error prefixes for presentation.
  String _friendlyError(Object error) {
    final text = error.toString();
    return text.replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
  }

  /// Smoothly scrolls message list to the newest bottom message.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(AppColors.primary);
    final isDesktop = AppBreakpoints.isDesktop(context);

    // Desktop split-view layout with history sidebar
    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(AppColors.background),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left persistent history sidebar for desktop
            SizedBox(
              width: 280,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Color(AppColors.border)),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chat History',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _startNewChat,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _conversations.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No saved conversations.', style: TextStyle(color: Color(AppColors.mutedText))),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _conversations.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                              itemBuilder: (context, index) {
                                final item = _conversations[index];
                                final isSelected = item.id == _conversationId;
                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor: const Color(AppColors.primaryLight),
                                  leading: Icon(
                                    Icons.chat_bubble_outline,
                                    color: isSelected ? primary : const Color(AppColors.mutedText),
                                    size: 18,
                                  ),
                                  title: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? primary : const Color(AppColors.text),
                                    ),
                                  ),
                                  subtitle: item.updatedAt == null
                                      ? null
                                      : Text(
                                          _formatDate(item.updatedAt!),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                  onTap: () => _openConversation(item),
                                  trailing: isSelected
                                      ? IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 16),
                                          onPressed: () async {
                                            final confirmed = await _confirm(
                                              title: 'Delete chat?',
                                              message: 'Permanently delete "${item.title}"?',
                                              confirmLabel: 'Delete',
                                            );
                                            if (!confirmed || !mounted) return;
                                            try {
                                              await ref.read(aiChatRepositoryProvider).deleteConversation(item.id);
                                              if (!mounted) return;
                                              if (_conversationId == item.id) {
                                                _startNewChat();
                                              }
                                              await _loadConversations();
                                            } catch (err) {
                                              if (mounted) setState(() => _error = _friendlyError(err));
                                            }
                                          },
                                        )
                                      : null,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Chat Workspace View
            Expanded(
              child: Column(
                children: [
                  _buildChatAppBar(context, primary, isDesktop),
                  if (_error != null)
                    MaterialBanner(
                      content: Text(_error!),
                      leading: const Icon(Icons.error_outline),
                      actions: [
                        TextButton(onPressed: () => setState(() => _error = null), child: const Text('Dismiss')),
                      ],
                    ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _messages.isEmpty
                            ? _buildWelcome(primary)
                            : ResponsiveCenter(
                                maxWidth: 900,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  itemCount: _messages.length + (_isSending ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (_isSending && index == _messages.length) {
                                      return _buildTypingBubble();
                                    }
                                    return _buildMessageBubble(_messages[index], primary, isDesktop);
                                  },
                                ),
                              ),
                  ),
                  _buildInputArea(primary, isDesktop),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: _buildChatAppBar(context, primary, false),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(onPressed: () => setState(() => _error = null), child: const Text('Dismiss')),
              ],
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildWelcome(primary)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        itemCount: _messages.length + (_isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isSending && index == _messages.length) {
                            return _buildTypingBubble();
                          }
                          return _buildMessageBubble(_messages[index], primary, false);
                        },
                      ),
          ),
          _buildInputArea(primary, false),
        ],
      ),
    );
  }

  /// Builds top AppBar with conversation title and chat actions.
  PreferredSizeWidget _buildChatAppBar(BuildContext context, Color primary, bool isDesktop) {
    return AppBar(
      titleSpacing: 12,
      leading: const AppBackButton(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryLight),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.auto_awesome, color: primary, size: 19),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.aiCopilot,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  _conversationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(AppColors.mutedText)),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(tooltip: 'Chat history', onPressed: _showHistoryMobile, icon: const Icon(Icons.history)),
        IconButton(tooltip: 'New chat', onPressed: _startNewChat, icon: const Icon(Icons.add)),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'reset') _resetCurrentChat();
            if (value == 'delete') _deleteCurrentChat();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'reset', child: ListTile(dense: true, leading: Icon(Icons.restart_alt), title: Text('Reset chat'))),
            PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline), title: Text('Delete chat'))),
          ],
        ),
      ],
    );
  }

  /// Builds message input bar with text field and submit button.
  Widget _buildInputArea(Color primary, bool isDesktop) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 12, 10, isDesktop ? 24 : 12, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(AppColors.border))),
        ),
        child: ResponsiveCenter(
          maxWidth: 900,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: AppStrings.askCopilot,
                    filled: true,
                    fillColor: const Color(AppColors.background),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _isSending ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
                icon: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds initial empty state welcome screen with suggestion chips.
  Widget _buildWelcome(Color primary) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: const Color(AppColors.primaryLight), borderRadius: BorderRadius.circular(22)),
              child: Icon(Icons.auto_awesome, size: 38, color: primary),
            ),
            const SizedBox(height: 18),
            const Text('How can I help you today?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const Text(
                'Ask about leave balances, HR policies, employees, or HR processes. Your conversations are saved securely to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(AppColors.mutedText), height: 1.45),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _suggestion('Explain company leave policy'),
                _suggestion('How do I apply for annual leave?'),
                _suggestion('Who is in my department?'),
                _suggestion('Help me with HR processes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds prompt suggestion chip widget.
  Widget _suggestion(String text) {
    return ActionChip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  /// Builds formatted user or assistant chat message bubble.
  Widget _buildMessageBubble(AiConversationMessageModel message, Color primary, bool isDesktop) {
    final isUser = message.isUser;
    final maxBubbleWidth = isDesktop ? 680.0 : 0.82;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            isDesktop ? BoxConstraints(maxWidth: maxBubbleWidth) : BoxConstraints(maxWidth: MediaQuery.of(context).size.width * maxBubbleWidth),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: const Color(AppColors.border)),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: SelectableText(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(AppColors.text),
            height: 1.5,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Builds typing indicator bubble displayed while waiting for assistant response.
  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(AppColors.border)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
