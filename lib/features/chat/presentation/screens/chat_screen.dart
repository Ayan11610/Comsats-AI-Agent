import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/chat_provider.dart';
import '../../models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    ref.read(chatProvider.notifier).addMessage(
          widget.conversationId,
          message,
          true,
        );

    _messageController.clear();
    _scrollToBottom();

    // Show typing indicator
    setState(() => _isTyping = true);

    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 2));

    // Add AI response
    final aiResponse = _generateDummyResponse(message);
    ref.read(chatProvider.notifier).addMessage(
          widget.conversationId,
          aiResponse,
          false,
        );

    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  String _generateDummyResponse(String userMessage) {
    // Simple dummy responses based on keywords
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return '''Hello! I'm COMSATS GPT, your AI academic assistant. How can I help you with your studies today?

I can assist you with:
- Course concepts and explanations
- Assignment help
- Exam preparation
- University policies
- Programming questions

What would you like to know?''';
    }

    if (lowerMessage.contains('data structure') || lowerMessage.contains('dsa')) {
      return '''# Data Structures

I can help you with various data structures topics! Here are some common ones:

## Linear Data Structures:
- **Arrays**: Fixed-size sequential collection
- **Linked Lists**: Dynamic size, node-based
- **Stacks**: LIFO (Last In First Out)
- **Queues**: FIFO (First In First Out)

## Non-Linear Data Structures:
- **Trees**: Hierarchical structure
- **Graphs**: Network of nodes and edges
- **Hash Tables**: Key-value pairs

## Example: Stack Implementation
```cpp
class Stack {
    int top;
    int arr[MAX];
public:
    Stack() { top = -1; }
    void push(int x);
    int pop();
    bool isEmpty();
};
```

Which specific data structure would you like to learn about?''';
    }

    if (lowerMessage.contains('database') || lowerMessage.contains('sql')) {
      return '''# Database Management

I can help you with database concepts! Here are key topics:

## SQL Basics:
- **SELECT**: Retrieve data
- **INSERT**: Add new records
- **UPDATE**: Modify existing data
- **DELETE**: Remove records

## Example Query:
```sql
SELECT student_name, gpa 
FROM students 
WHERE department = 'CS' 
ORDER BY gpa DESC;
```

## Normalization:
- 1NF, 2NF, 3NF, BCNF
- Reduces redundancy
- Improves data integrity

What specific database topic do you need help with?''';
    }

    // Default response
    return '''I understand you're asking about: "$userMessage"

While I have access to COMSATS-specific knowledge, I can provide general academic assistance on this topic. 

**Here's what I can help with:**
- Explain concepts in detail
- Provide code examples
- Suggest study resources
- Answer specific questions

Could you please provide more details about what you'd like to know? For example:
- Which course is this for?
- What specific aspect are you struggling with?
- Do you need theoretical explanation or practical examples?

I'm here to help! ''';
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(selectedConversationProvider);

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: const Center(
          child: Text('Conversation not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.title,
              style: const TextStyle(fontSize: 16),
            ),
            if (_isTyping)
              Text(
                'AI is typing...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                // TODO: Implement clear chat
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: conversation.messages.isEmpty
                ? _buildEmptyChat(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversation.messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == conversation.messages.length) {
                        return _buildTypingIndicator();
                      }
                      final message = conversation.messages[index];
                      return _buildMessageBubble(message, index);
                    },
                  ),
          ),

          // Input Field
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            'Start the conversation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Ask me anything about your courses, assignments, or COMSATS policies',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: message.isUser
            ? Text(
                message.content,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 15,
                ),
              )
            : MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                  code: TextStyle(
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.red.shade700,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  h1: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  h2: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  h3: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  listBullet: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: (index * 50).ms);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(delay: (index * 200).ms, duration: 600.ms)
        .then()
        .fadeOut(duration: 600.ms);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
