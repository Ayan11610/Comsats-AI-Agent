import 'package:flutter/services.dart';

/// Service for loading and searching COMSATS knowledge base
class KnowledgeBaseService {
  static final KnowledgeBaseService _instance = KnowledgeBaseService._internal();
  factory KnowledgeBaseService() => _instance;
  KnowledgeBaseService._internal();

  final Map<String, String> _knowledgeBase = {};
  bool _isInitialized = false;

  /// Initialize knowledge base by loading all markdown files
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // List of knowledge base files
      final files = [
        'acedemics.md',
        'admissions.md',
        'alumni.md',
        'campuses.md',
        'cdc and ssbc.md',
        'extra activities and societies.md',
        'portals.md',
        'scholarship.md',
        'students affairs.md',
        'teachers.md',
      ];

      // Load each file
      for (final file in files) {
        try {
          final content = await rootBundle.loadString('assets/knowledge_base/$file');
          _knowledgeBase[file] = content;
        } catch (e) {
          print('Error loading $file: $e');
        }
      }

      _isInitialized = true;
      print('Knowledge base initialized with ${_knowledgeBase.length} documents');
    } catch (e) {
      print('Error initializing knowledge base: $e');
    }
  }

  /// Search knowledge base for relevant information
  Future<String> searchKnowledge(String query) async {
    if (!_isInitialized) {
      await initialize();
    }

    final queryLower = query.toLowerCase();
    final relevantSections = <String>[];

    // Keywords mapping to files
    final keywordMap = {
      'admission': ['admissions.md'],
      'apply': ['admissions.md'],
      'fee': ['admissions.md', 'scholarship.md'],
      'academic': ['acedemics.md'],
      'course': ['acedemics.md'],
      'program': ['acedemics.md', 'admissions.md'],
      'degree': ['acedemics.md', 'admissions.md'],
      'scholarship': ['scholarship.md'],
      'financial': ['scholarship.md'],
      'campus': ['campuses.md'],
      'location': ['campuses.md'],
      'city': ['campuses.md'],
      'teacher': ['teachers.md'],
      'faculty': ['teachers.md'],
      'professor': ['teachers.md'],
      'portal': ['portals.md'],
      'lms': ['portals.md'],
      'student': ['students affairs.md', 'portals.md'],
      'society': ['extra activities and societies.md'],
      'club': ['extra activities and societies.md'],
      'activity': ['extra activities and societies.md'],
      'event': ['extra activities and societies.md'],
      'career': ['cdc and ssbc.md'],
      'job': ['cdc and ssbc.md'],
      'placement': ['cdc and ssbc.md'],
      'internship': ['cdc and ssbc.md'],
      'alumni': ['alumni.md'],
      'graduate': ['alumni.md'],
    };

    // Find relevant files based on keywords
    final relevantFiles = <String>{};
    for (final entry in keywordMap.entries) {
      if (queryLower.contains(entry.key)) {
        relevantFiles.addAll(entry.value);
      }
    }

    // If no specific keywords found, search all files
    if (relevantFiles.isEmpty) {
      relevantFiles.addAll(_knowledgeBase.keys);
    }

    // Extract relevant content from files
    for (final file in relevantFiles) {
      final content = _knowledgeBase[file];
      if (content != null) {
        // Simple relevance check - look for query terms in content
        final contentLower = content.toLowerCase();
        final queryWords = queryLower.split(' ').where((w) => w.length > 3).toList();
        
        var relevanceScore = 0;
        for (final word in queryWords) {
          if (contentLower.contains(word)) {
            relevanceScore++;
          }
        }

        // If content is relevant, add it
        if (relevanceScore > 0 || relevantFiles.length == 1) {
          // Extract relevant sections (limit to 1000 characters per file)
          final sections = _extractRelevantSections(content, queryWords);
          if (sections.isNotEmpty) {
            relevantSections.add('From ${file.replaceAll('.md', '')}:\n$sections');
          }
        }
      }
    }

    // Combine and limit total context
    if (relevantSections.isEmpty) {
      return '';
    }

    final combined = relevantSections.join('\n\n---\n\n');
    
    // Limit total context to ~3000 characters to avoid token limits
    if (combined.length > 3000) {
      return combined.substring(0, 3000) + '...';
    }

    return combined;
  }

  /// Extract relevant sections from content based on query words
  String _extractRelevantSections(String content, List<String> queryWords) {
    final lines = content.split('\n');
    final relevantLines = <String>[];
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();
      
      // Check if line contains any query words
      var isRelevant = false;
      for (final word in queryWords) {
        if (lineLower.contains(word)) {
          isRelevant = true;
          break;
        }
      }

      if (isRelevant) {
        // Add context: previous line, current line, and next 2 lines
        if (i > 0 && !relevantLines.contains(lines[i - 1])) {
          relevantLines.add(lines[i - 1]);
        }
        relevantLines.add(line);
        if (i + 1 < lines.length) relevantLines.add(lines[i + 1]);
        if (i + 2 < lines.length) relevantLines.add(lines[i + 2]);
      }
    }

    final result = relevantLines.join('\n');
    
    // Limit to 800 characters per file
    if (result.length > 800) {
      return result.substring(0, 800) + '...';
    }

    return result;
  }

  /// Get all knowledge base content (for debugging)
  Map<String, String> getAllContent() {
    return Map.from(_knowledgeBase);
  }

  /// Get specific file content
  String? getFileContent(String fileName) {
    return _knowledgeBase[fileName];
  }

  /// Check if knowledge base is initialized
  bool get isInitialized => _isInitialized;

  /// Get number of loaded documents
  int get documentCount => _knowledgeBase.length;
}
