import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_service.dart';
import '../providers/ai_provider.dart';

// ---------------------------------------------------------------------------
// Model pesan
// ---------------------------------------------------------------------------

enum _Sender { user, assistant }

class _ChatMessage {
  final _Sender sender;
  final String text;
  const _ChatMessage({required this.sender, required this.text});
}

// ---------------------------------------------------------------------------
// State + Notifier (Riverpod 3.x — Notifier/NotifierProvider)
// ---------------------------------------------------------------------------

class _ChatState {
  final List<_ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const _ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  _ChatState copyWith({
    List<_ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      _ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class _ChatNotifier extends Notifier<_ChatState> {
  late AiService _service;

  @override
  _ChatState build() {
    _service = ref.read(aiServiceProvider);
    return const _ChatState();
  }

  /// Kirim [question] ke AI dan tambahkan respons ke daftar pesan.
  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    // Tambah pesan user
    state = state.copyWith(
      messages: [
        ...state.messages,
        _ChatMessage(sender: _Sender.user, text: question.trim()),
      ],
      isLoading: true,
      clearError: true,
    );

    try {
      final answer = await _service.ask(question.trim());
      state = state.copyWith(
        messages: [
          ...state.messages,
          _ChatMessage(sender: _Sender.assistant, text: answer),
        ],
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Layanan AI sedang sibuk. Coba lagi nanti atau gunakan mode offline.',
      );
    }
  }

  /// Tambahkan respons fallback lokal langsung ke daftar pesan.
  void addFallback() {
    const fallback = 'Maaf, layanan AI sementara tidak tersedia. '
        'Untuk informasi jadwal, hubungi akademik kampus atau cek portal mahasiswa.';
    state = state.copyWith(
      messages: [
        ...state.messages,
        const _ChatMessage(sender: _Sender.assistant, text: fallback),
      ],
      clearError: true,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider menggunakan Riverpod 3.x API
final _chatProvider =
    NotifierProvider.autoDispose<_ChatNotifier, _ChatState>(_ChatNotifier.new);

// ---------------------------------------------------------------------------
// ChatScreen Widget
// ---------------------------------------------------------------------------

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    await ref.read(_chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _showApiKeyDialog() async {
    final service = ref.read(aiServiceProvider);
    final currentKey = await service.getApiKey();
    if (!mounted) return;

    final keyController = TextEditingController(text: currentKey ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur API Key Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Gemini API Key Anda.\n'
              'Key disimpan aman di perangkat dan tidak dikirim ke server kami.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await service.saveApiKey(keyController.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key berhasil disimpan ✓')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    keyController.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: const Text('Layanan AI Sibuk'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(_chatProvider.notifier).clearError();
            },
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(_chatProvider.notifier).addFallback();
            },
            child: const Text('Gunakan Jawaban Offline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(_chatProvider);

    // Tampilkan error dialog saat errorMessage muncul
    ref.listen<_ChatState>(_chatProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _showErrorDialog(next.errorMessage!);
      }
      if (next.messages.length != prev?.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten Kampus AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'Atur API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _SecurityBanner(),
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyState(onSetKey: _showApiKeyDialog)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: chatState.messages.length,
                    itemBuilder: (_, i) =>
                        _MessageBubble(message: chatState.messages[i]),
                  ),
          ),
          if (chatState.isLoading) const _TypingIndicator(),
          _InputBar(
            controller: _inputController,
            isLoading: chatState.isLoading,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SecurityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Jangan kirim NIK, nomor telepon, email, atau data sensitif ke AI.',
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onSetKey;
  const _EmptyState({required this.onSetKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined,
                size: 72, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            const Text(
              'Halo! Saya asisten kampus Anda.\nSilakan ajukan pertanyaan seputar akademik.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onSetKey,
              icon: const Icon(Icons.key, size: 16),
              label: const Text('Atur API Key terlebih dahulu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == _Sender.user;
    return FadeTransition(
      opacity: _opacity,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: isUser ? Colors.indigo.shade600 : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: isUser
              ? Text(
                  widget.message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              : _StreamingText(text: widget.message.text),
        ),
      ),
    );
  }
}

/// Efek streaming/typing pada respons asisten (animasi per-3-karakter).
class _StreamingText extends StatefulWidget {
  final String text;
  const _StreamingText({required this.text});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText> {
  String _displayed = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _typeNext();
  }

  void _typeNext() {
    if (!mounted || _charIndex >= widget.text.length) return;
    final end = (_charIndex + 3).clamp(0, widget.text.length);
    setState(() {
      _displayed = widget.text.substring(0, end);
      _charIndex = end;
    });
    Future.delayed(const Duration(milliseconds: 18), _typeNext);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayed,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 40, height: 20, child: _DotsLoader()),
                const SizedBox(width: 8),
                Text(
                  'Asisten sedang menjawab...',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final tick = (_ctrl.value * 3).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == tick
                    ? Colors.indigo.shade600
                    : Colors.grey.shade400,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Tanya sesuatu tentang kampus...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: isLoading ? null : onSend,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
