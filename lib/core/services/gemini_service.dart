import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'knowledge_base_service.dart';

/// Service for interacting with Google Gemini AI
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  late final KnowledgeBaseService _knowledgeBase;
  ChatSession? _chatSession;

  /// Initialize Gemini service
  Future<void> initialize() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );

    _knowledgeBase = KnowledgeBaseService();
    await _knowledgeBase.initialize();
  }

  /// Start a new chat session
  void startNewChat() {
    final systemPrompt = _buildSystemPrompt();
    _chatSession = _model.startChat(history: [
      Content.text(systemPrompt),
      Content.model([TextPart('Hello! I\'m COMSATS GPT, your AI assistant for COMSATS University. I can help you with information about admissions, academics, campus life, scholarships, and much more. How can I assist you today?')]),
    ]);
  }

  /// Send a message and get response
  Future<String> sendMessage(String message) async {
    try {
      if (_chatSession == null) {
        startNewChat();
      }

      // Search knowledge base for relevant context
      final context = await _knowledgeBase.searchKnowledge(message);
      
      // Enhance the message with context
      final enhancedMessage = _buildEnhancedMessage(message, context);

      final response = await _chatSession!.sendMessage(
        Content.text(enhancedMessage),
      );

      return response.text ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
    } catch (e) {
      print('Error sending message to Gemini: $e');
      return _handleGeminiError(e);
    }
  }

  /// Generate a response without chat history (one-off question)
  Future<String> generateResponse(String prompt) async {
    try {
      final context = await _knowledgeBase.searchKnowledge(prompt);
      final enhancedPrompt = _buildEnhancedMessage(prompt, context);
      
      final response = await _model.generateContent([
        Content.text(_buildSystemPrompt()),
        Content.text(enhancedPrompt),
      ]);

      return response.text ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
    } catch (e) {
      print('Error generating response: $e');
      return _handleGeminiError(e);
    }
  }

  /// Build system prompt with knowledge base context
  String _buildSystemPrompt() {
    return '''You are COMSATS GPT, an intelligent AI assistant specifically designed to help students, prospective students, and anyone interested in COMSATS University (COMSATS Institute of Information Technology).

Your role and capabilities:
1. Provide accurate, helpful information about COMSATS University
2. Answer questions about admissions, academics, campus life, scholarships, facilities, and more
3. Be friendly, professional, and encouraging
4. Use the knowledge base provided to give accurate answers
5. If you don't know something, admit it honestly and suggest where they might find the information
6. Keep responses concise but informative
7. Use a conversational, student-friendly tone

Important guidelines:
- Always base your answers on the provided knowledge base when available
- If information is not in the knowledge base, use your general knowledge but mention it's general information
- Be encouraging and supportive to prospective and current students
- Provide specific details when available (dates, requirements, procedures, etc.)
- Format responses clearly with bullet points or numbered lists when appropriate
- If asked about something outside COMSATS University, politely redirect to COMSATS-related topics

Remember: You represent COMSATS University, so maintain a professional yet friendly demeanor.''';
  }

  /// Build enhanced message with knowledge base context
  String _buildEnhancedMessage(String userMessage, String context) {
    if (context.isEmpty) {
      return userMessage;
    }

    return '''Based on the following information from COMSATS University knowledge base:

$context

User Question: $userMessage

Please provide a helpful, accurate response based on the knowledge base information above. If the knowledge base doesn't contain relevant information, use your general knowledge but mention that it's general information and they should verify with official COMSATS sources.''';
  }

  /// Clear chat history
  void clearChat() {
    _chatSession = null;
  }

  /// Get chat history
  List<Content>? getChatHistory() {
    return _chatSession?.history.toList();
  }

  /// Handle Gemini API errors with user-friendly messages
  String _handleGeminiError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Check for quota exceeded errors
    if (errorString.contains('quota exceeded') || 
        errorString.contains('quota') ||
        errorString.contains('rate limit') ||
        errorString.contains('429')) {
      return '''⚠️ API Quota Exceeded

The Gemini API free tier quota has been exceeded. This happens when:
• Daily request limit is reached
• Token limit is exceeded
• Rate limits are hit

Solutions:
1. Wait for the quota to reset (usually 24 hours)
2. Get a new API key from https://ai.google.dev/
3. Upgrade to a paid plan for higher limits
4. Use a different API key

To update your API key:
• Go to https://ai.google.dev/
• Generate a new API key
• Update the GEMINI_API_KEY in your .env file
• Restart the application

For more information, visit:
https://ai.google.dev/gemini-api/docs/rate-limits''';
    }
    
    // Check for authentication errors
    if (errorString.contains('api key') || 
        errorString.contains('authentication') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return '''🔑 API Key Error

There's an issue with your Gemini API key. Please:
1. Verify your API key is correct in the .env file
2. Generate a new key at https://ai.google.dev/
3. Ensure the key has proper permissions
4. Restart the application after updating''';
    }
    
    // Check for network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return '''🌐 Network Error

Unable to connect to Gemini API. Please:
1. Check your internet connection
2. Try again in a few moments
3. Verify the API endpoint is accessible''';
    }
    
    // Generic error
    return '''❌ Error Processing Request

An unexpected error occurred: ${error.toString().split('\n').first}

Please try:
1. Sending your message again
2. Starting a new chat session
3. Checking your internet connection
4. Verifying your API configuration

If the problem persists, check the console for detailed error logs.''';
  }
}
