import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserNickname; // The other user's display name

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserNickname,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  final _messageController = TextEditingController();

  /// Real-time related variables
  late Echo echo;
  bool _otherUserTyping = false;
  bool _isTyping = false; // local user's typing status

  /// Emoji picker toggle
  bool _showEmojiPicker = false;

  /// Replace with your actual authenticated user ID
  final int myUserId = 999;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _setupEcho();
  }

  /// Fetch initial messages from the backend
  Future<void> _fetchMessages() async {
    try {
      final response = await ApiService().getMessages(widget.otherUserId);
      if (response.statusCode == 200) {
        setState(() {
          messages = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  /// Set up Laravel Echo with a Socket.IO client, passing the token from SharedPrefs
  Future<void> _setupEcho() async {
    // 1. Retrieve the auth token
    String? token = await ApiService.getToken();
    token ??= '';

    // 2. Create the Socket.IO client
    IO.Socket socket = IO.io(
      'http://127.0.0.1:6001', // Adjust as needed for your Soketi server
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket.connect();

    // 3. Create Echo instance with the required 'client' param and broadcaster=SocketIO
    echo = Echo(
      client: socket,
      broadcaster: EchoBroadcasterType.SocketIO,
      options: {
        'auth': {
          'headers': {
            'Authorization': 'Bearer $token',
          },
        },
      },
    );

    echo.connect();

    // 4. Subscribe to the private channel for the current user
    String channelName = 'private-chat.$myUserId';
    echo.private(channelName)
      .listen('MessageSent', (data) {
        // Only add the message if it belongs to this conversation
        if ((data['sender_id'] == widget.otherUserId) ||
            (data['receiver_id'] == widget.otherUserId)) {
          setState(() {
            messages.add(data);
          });
        }
      })
      .listen('TypingEvent', (data) {
        if (data['sender_id'] == widget.otherUserId) {
          setState(() {
            _otherUserTyping = data['is_typing'];
          });
        }
      })
      .listen('MessageRead', (data) {
        int msgId = data['message_id'];
        setState(() {
          messages = messages.map((msg) {
            if (msg['id'] == msgId) {
              msg['read_at'] = DateTime.now().toString();
            }
            return msg;
          }).toList();
        });
      });
  }

  /// Send a message to the backend
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await ApiService().sendMessage(widget.otherUserId, text);
      if (response.statusCode == 201) {
        setState(() {
          messages.add(response.data);
          _messageController.clear();
        });
        _sendTyping(false);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Notify the backend that we're typing or not
  void _sendTyping(bool typing) async {
    try {
      await ApiService().sendTyping(widget.otherUserId, typing);
    } catch (e) {
      debugPrint('Error sending typing status: $e');
    }
  }

  /// Mark a message as read
  void _markMessageAsRead(int messageId) async {
    try {
      await ApiService().markAsRead(messageId);
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  /// Callback for the emoji picker: (Category, Emoji)
  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController.text += emoji.emoji;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  /// Build a chat bubble for each message
  Widget _buildMessageBubble(dynamic msg) {
    final bool isMe = msg['sender_id'] == myUserId;
    final bubbleColor = isMe ? Colors.blue[100] : Colors.grey[200];
    final senderLabel = isMe ? 'You' : (msg['sender_nickname'] ?? 'Unknown');
    final bool isRead = msg['read_at'] != null;

    if (!isMe && msg['read_at'] == null) {
      _markMessageAsRead(msg['id']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            msg['message_text'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          if (isMe)
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                isRead ? Icons.done_all : Icons.done,
                size: 16,
                color: isRead ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    echo.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserNickname}'),
        bottom: _otherUserTyping
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'Typing...',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          // Emoji Picker
          _showEmojiPicker
              ? SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: _onEmojiSelected,
                    config: const Config(
                        height: 250, // Height of the emoji picker
                        emojiSet: defaultEmojiSet, // Default emoji set
                        emojiViewConfig: EmojiViewConfig(
                            columns: 7, // Number of columns
                            emojiSizeMax: 32.0, // Maximum emoji size
                            verticalSpacing: 0, // Vertical spacing between emojis
                            horizontalSpacing: 0, // Horizontal spacing between emojis
                            gridPadding: EdgeInsets.zero, // Padding around the grid
                            
                          ),
                        skinToneConfig: SkinToneConfig( // Initial category to display
                             // Background color
                            indicatorColor: Colors.blue), // Category indicator color
                        categoryViewConfig: CategoryViewConfig(), // Category view configuration
                        bottomActionBarConfig: BottomActionBarConfig(), // Bottom action bar configuration
                        searchViewConfig: SearchViewConfig() // Search view configuration
                      ),
                  ),
                )
              : const SizedBox.shrink(),

          // Text input + send
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      final typing = text.isNotEmpty;
                      if (typing != _isTyping) {
                        _isTyping = typing;
                        _sendTyping(typing);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
