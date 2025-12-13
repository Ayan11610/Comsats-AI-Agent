import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../models/message.dart';

// Dummy data provider
final chatProvider = StateNotifierProvider<ChatNotifier, List<Conversation>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<Conversation>> {
  ChatNotifier() : super(_getDummyConversations());

  static List<Conversation> _getDummyConversations() {
    final now = DateTime.now();
    return [
      Conversation(
        id: '1',
        title: 'Data Structures Assignment Help',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        messages: [
          Message(
            id: '1',
            content: 'Can you explain Binary Search Trees?',
            isUser: true,
            timestamp: now.subtract(const Duration(days: 2, hours: 1)),
          ),
          Message(
            id: '2',
            content: '''# Binary Search Trees (BST)

A **Binary Search Tree** is a node-based binary tree data structure with the following properties:

## Key Properties:
1. The left subtree of a node contains only nodes with keys **less than** the node's key
2. The right subtree of a node contains only nodes with keys **greater than** the node's key
3. Both left and right subtrees must also be binary search trees

## Time Complexity:
- **Search**: O(log n) average, O(n) worst case
- **Insert**: O(log n) average, O(n) worst case
- **Delete**: O(log n) average, O(n) worst case

## Example Code (C++):
```cpp
struct Node {
    int data;
    Node* left;
    Node* right;
};

Node* insert(Node* root, int value) {
    if (root == NULL) {
        return new Node{value, NULL, NULL};
    }
    if (value < root->data)
        root->left = insert(root->left, value);
    else
        root->right = insert(root->right, value);
    return root;
}
```

Would you like me to explain any specific operation in detail?''',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 2, hours: 1)),
          ),
        ],
      ),
      Conversation(
        id: '2',
        title: 'Database Normalization',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        messages: [
          Message(
            id: '3',
            content: 'What is the difference between 2NF and 3NF?',
            isUser: true,
            timestamp: now.subtract(const Duration(days: 5)),
          ),
          Message(
            id: '4',
            content: '''# Database Normalization: 2NF vs 3NF

## Second Normal Form (2NF)
A table is in 2NF if:
- It is in **1NF** (First Normal Form)
- All non-key attributes are **fully functionally dependent** on the primary key
- No partial dependencies exist

**Example of violation:**
```
StudentCourse(StudentID, CourseID, StudentName, CourseName)
```
Here, StudentName depends only on StudentID (partial dependency).

## Third Normal Form (3NF)
A table is in 3NF if:
- It is in **2NF**
- No **transitive dependencies** exist
- All attributes depend directly on the primary key

**Example of violation:**
```
Student(StudentID, DeptID, DeptName)
```
Here, DeptName depends on DeptID, not directly on StudentID.

## Key Difference:
- **2NF** eliminates partial dependencies
- **3NF** eliminates transitive dependencies

Both are essential for reducing data redundancy and improving data integrity!''',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      Conversation(
        id: '3',
        title: 'OOP Concepts',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        messages: [
          Message(
            id: '5',
            content: 'Explain polymorphism with an example',
            isUser: true,
            timestamp: now.subtract(const Duration(days: 7)),
          ),
          Message(
            id: '6',
            content: '''# Polymorphism in OOP

**Polymorphism** means "many forms" - it allows objects of different classes to be treated as objects of a common parent class.

## Types of Polymorphism:

### 1. Compile-time (Static) Polymorphism
Achieved through **method overloading**:

```java
class Calculator {
    int add(int a, int b) {
        return a + b;
    }
    
    double add(double a, double b) {
        return a + b;
    }
}
```

### 2. Runtime (Dynamic) Polymorphism
Achieved through **method overriding**:

```java
class Animal {
    void makeSound() {
        System.out.println("Some sound");
    }
}

class Dog extends Animal {
    @Override
    void makeSound() {
        System.out.println("Bark!");
    }
}

class Cat extends Animal {
    @Override
    void makeSound() {
        System.out.println("Meow!");
    }
}

// Usage
Animal myDog = new Dog();
myDog.makeSound(); // Output: Bark!
```

## Benefits:
- Code reusability
- Flexibility
- Easier maintenance

This is a fundamental concept in COMSATS OOP courses!''',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 7)),
          ),
        ],
      ),
    ];
  }

  void addMessage(String conversationId, String content, bool isUser) {
    final uuid = const Uuid();
    final newMessage = Message(
      id: uuid.v4(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(
          messages: [...conversation.messages, newMessage],
          updatedAt: DateTime.now(),
        );
      }
      return conversation;
    }).toList();
  }

  void createNewConversation(String title) {
    final uuid = const Uuid();
    final newConversation = Conversation(
      id: uuid.v4(),
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    state = [newConversation, ...state];
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
