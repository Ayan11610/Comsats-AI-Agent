import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../../../core/services/gemini_service.dart';

// Gemini service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, List<Conversation>>((ref) {
  return ChatNotifier(ref.watch(geminiServiceProvider));
});

class ChatNotifier extends StateNotifier<List<Conversation>> {
  final GeminiService _geminiService;
  
  ChatNotifier(this._geminiService) : super([]);

  /// Send a message and get AI response
  Future<void> sendMessage(String conversationId, String content) async {
    final uuid = const Uuid();
    
    // Add user message
    final userMessage = Message(
      id: uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(
          messages: [...conversation.messages, userMessage],
          updatedAt: DateTime.now(),
        );
      }
      return conversation;
    }).toList();

    // Get AI response
    try {
      final response = await _geminiService.sendMessage(content);
      
      // Add AI response
      final aiMessage = Message(
        id: uuid.v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.map((conversation) {
        if (conversation.id == conversationId) {
          return conversation.copyWith(
            messages: [...conversation.messages, aiMessage],
            updatedAt: DateTime.now(),
          );
        }
        return conversation;
      }).toList();
    } catch (e) {
      // Add error message
      final errorMessage = Message(
        id: uuid.v4(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.map((conversation) {
        if (conversation.id == conversationId) {
          return conversation.copyWith(
            messages: [...conversation.messages, errorMessage],
            updatedAt: DateTime.now(),
          );
        }
        return conversation;
      }).toList();
    }
  }

  String createNewConversation(String title) {
    final uuid = const Uuid();
    final conversationId = uuid.v4();
    final newConversation = Conversation(
      id: conversationId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    state = [newConversation, ...state];
    
    // Start new chat session in Gemini
    _geminiService.startNewChat();
    
    return conversationId;
  }

  void deleteConversation(String conversationId) {
    state = state.where((c) => c.id != conversationId).toList();
  }

  void renameConversation(String conversationId, String newTitle) {
    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(title: newTitle);
      }
      return conversation;
    }).toList();
  }

  Conversation? getConversationById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Current conversation provider
final currentConversationIdProvider = StateProvider<String?>((ref) => null);

// Selected conversation provider
final selectedConversationProvider = Provider<Conversation?>((ref) {
  final conversationId = ref.watch(currentConversationIdProvider);
  if (conversationId == null) return null;
  
  final conversations = ref.watch(chatProvider);
  try {
    return conversations.firstWhere((c) => c.id == conversationId);
  } catch (e) {
    return null;
  }
});

