import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'settings_page.dart';
import 'attach_content_page.dart';
import 'actions_hub_page.dart';

void main() {
  runApp(const CrisisChatApp());
}

class CrisisChatApp extends StatelessWidget {
  const CrisisChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crisis Knowledge Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const CrisisChatScreen(),
    );
  }
}

class CrisisChatScreen extends StatefulWidget {
  const CrisisChatScreen({super.key});

  @override
  State<CrisisChatScreen> createState() => _CrisisChatScreenState();
}

class _CrisisChatScreenState extends State<CrisisChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedScenario = 'supplier_failure';
  bool _isSending = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
      'Hi, I am your AI-based assistant for crisis knowledge transfer.\n\n'
          'Select a scenario above or describe your own, and I will connect to the information hub to support real-time decision making.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final Map<String, String> _scenarioTitles = const {
    'chemical_leak': 'Chemical leak in production / lab',
    'supplier_failure': 'Sudden supplier failure',
    'it_outage': 'Critical IT system outage',
  };

  final Map<String, List<String>> _suggestedPrompts = const {
    'chemical_leak': [
      'Immediate actions for chemical leak in mixing unit',
      'Who should be informed first?',
      'Show training material for handling toxic vapours'
    ],
    'supplier_failure': [
      'Supplier for key component failed, what now?',
      'List alternative suppliers from knowledge base',
      'What are the risks of switching supplier quickly?'
    ],
    'it_outage': [
      'Main ERP system is down, what is the fallback?',
      'How to communicate outage to employees?',
      'Which processes are most critical during outage?'
    ],
  };

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend({String? textOverride}) async {
    if (_isSending) return;

    final text = (textOverride ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _controller.clear();

      // Temporary "assistant is typing" message
      _messages.add(
        ChatMessage(
          text: 'Processing your input… connecting to information hub…',
          isUser: false,
          timestamp: DateTime.now(),
          isTemporary: true,
        ),
      );
    });

    _scrollToBottom();

    try {
      final reply = await BackendService.sendMessage(
        message: text,
        scenarioId: _selectedScenario,
      );

      setState(() {
        _messages.removeWhere((m) => m.isTemporary);
        _messages.add(reply);
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isTemporary);
        _messages.add(
          ChatMessage(
            text:
            '⚠️ I could not reach the backend right now.\n'
                'Error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF10B981),
              child: Icon(
                Icons.shield_moon_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crisis Knowledge Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online · RAG connected',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActionsHubPage()),
              );

              // Optional: handle "New Incident" coming back from that page
              if (result == 'new_incident') {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    ChatMessage(
                      text:
                      'New incident started. Describe the crisis or choose a scenario.',
                      isUser: false,
                      timestamp: DateTime.now(),
                    ),
                  );
                });
              }
            },
            icon: const Icon(Icons.dashboard_customize_outlined),
            tooltip: 'Action Center',
          ),
          IconButton(
            onPressed: () {
              // your existing settings navigation
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScenarioHeader(),
          const SizedBox(height: 4),
          _buildSuggestedPromptsRow(),
          _buildActionButtons(),
          const SizedBox(height: 4),
          _buildChatArea(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildScenarioHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316)),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedScenario,
                isExpanded: true,
                items: _scenarioTitles.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(
                      e.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedScenario = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Scenario',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPromptsRow() {
    final prompts = _suggestedPrompts[_selectedScenario] ?? [];
    if (prompts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: const TextStyle(fontSize: 11),
            ),
            onPressed: () => _handleSend(textOverride: prompt),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _actionBtn(
            icon: Icons.upload_file_outlined,
            text: 'Upload Document',
            onTap: () {
              // TODO: file picker + upload
            },
          ),

          _actionBtn(
            icon: Icons.menu_book_outlined,
            text: 'Knowledge Base',
            onTap: () {
              // TODO: open modal with categories
            },
          ),

          _actionBtn(
            icon: Icons.description_outlined,
            text: 'Generate Report',
            onTap: () {
              // TODO: compile conversation summary
            },
          ),

          _actionBtn(
            icon: Icons.support_agent_outlined,
            text: 'Escalate to Expert',
            onTap: () {
              // TODO: forward last messages to expert
            },
          ),

          _actionBtn(
            icon: Icons.refresh_outlined,
            text: 'New Incident',
            onTap: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                  'New incident started. Describe the crisis or choose a scenario.',
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String text, required Function onTap}) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isUser = message.isUser;
          return Align(
            alignment:
            isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF4F46E5)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: isUser
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (message.sources.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: -4,
                            children: message.sources
                                .map(
                                  (s) => Chip(
                                label: Text(
                                  s,
                                  style: const TextStyle(
                                      fontSize: 10),
                                ),
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttachContentPage()),
                );

                if (result != null) {
                  setState(() {
                    _messages.add(
                      ChatMessage(
                        text:
                        "📎 Attached Content\n"
                            "${result['file'] != null ? 'File: ${result['file'].path.split('/').last}\n' : ''}"
                            "${result['photo'] != null ? 'Photo added\n' : ''}"
                            "${result['notes'] != null && result['notes'] != '' ? 'Notes: ${result['notes']}' : ''}",
                        isUser: true,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Attach context',
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                    'Describe the crisis or ask about response steps...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _handleSend,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isSending
                      ? Colors.grey.shade400
                      : const Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> sources;
  final bool isTemporary;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.isTemporary = false,
  });
}

class BackendService {
  static const String _baseUrl =
      'https://your-backend-url.com/chat'; // TODO: replace with your backend

  static Future<ChatMessage> sendMessage({
    required String message,
    required String scenarioId,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'scenario_id': scenarioId,
      }),
    );

    if (response.statusCode != 200) {
      throw 'HTTP ${response.statusCode}: ${response.body}';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final replyText =
        data['reply'] as String? ?? 'No reply field in backend response.';
    final sources = (data['sources'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        const <String>[];

    return ChatMessage(
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      sources: sources,
    );
  }
}