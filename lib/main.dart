
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const JarvisApp());
}

const cyan = Color(0xFF55E7FF);
const background = Color(0xFF070B13);
const panel = Color(0xFF101827);

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'J.A.R.V.I.S.',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AssistantHome(),
    );
  }
}

class AssistantHome extends StatefulWidget {
  const AssistantHome({super.key});

  @override
  State<AssistantHome> createState() => _AssistantHomeState();
}

class _AssistantHomeState extends State<AssistantHome>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final messages = <Map<String, String>>[
    {
      'role': 'assistant',
      'text':
          'Systems online. I am J.A.R.V.I.S. Your personal assistant interface is ready. What would you like to do?',
    },
  ];

  late final AnimationController pulse;
  int selectedTab = 0;
  bool thinking = false;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty || thinking) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
      controller.clear();
      thinking = true;
    });

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        messages.add({
          'role': 'assistant',
          'text': replyFor(text),
        });
        thinking = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  String replyFor(String text) {
    final input = text.toLowerCase();
    if (input.contains('hello') || input.contains('hi')) {
      return 'Hello! All local interface systems are ready. How can I help?';
    }
    if (input.contains('time')) {
      return 'Your device time is ${TimeOfDay.now().format(context)}.';
    }
    if (input.contains('name')) {
      return 'I am J.A.R.V.I.S. — your assistant interface.';
    }
    return 'Message received. This is the interface demo; connecting a real AI service will enable intelligent answers.';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide) buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      buildTopBar(wide),
                      Expanded(
                        child: selectedTab == 0
                            ? buildAssistant(wide)
                            : selectedTab == 1
                                ? buildExtensions()
                                : buildMemory(),
                      ),
                      if (selectedTab == 0) buildComposer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  backgroundColor: panel,
                  indicatorColor: cyan.withValues(alpha: 0.15),
                  selectedIndex: selectedTab,
                  onDestinationSelected: (value) {
                    setState(() => selectedTab = value);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.blur_on),
                      label: 'Assistant',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.extension_outlined),
                      label: 'Extensions',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.memory),
                      label: 'Memory',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF0B111D),
        border: Border(right: BorderSide(color: Color(0xFF1D2B3D))),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.blur_on, color: cyan, size: 38),
          const SizedBox(height: 12),
          const Text(
            'J.A.R.V.I.S.',
            style: TextStyle(
              color: cyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 35),
          for (int i = 0; i < 3; i++)
            sidebarItem(
              i,
              ['Assistant', 'Extensions', 'Memory'][i],
              [
                Icons.grid_view_rounded,
                Icons.extension_outlined,
                Icons.memory,
              ][i],
            ),
          const Spacer(),
          const Divider(color: Color(0xFF243247)),
          const Row(
            children: [
              Icon(Icons.circle, color: cyan, size: 9),
              SizedBox(width: 8),
              Text('LOCAL DEMO', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(int index, String label, IconData icon) {
    final active = selectedTab == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: active ? cyan.withValues(alpha: 0.10) : Colors.transparent,
        leading: Icon(icon, color: active ? cyan : Colors.white54),
        title: Text(
          label,
          style: TextStyle(color: active ? cyan : Colors.white70),
        ),
        onTap: () => setState(() => selectedTab = index),
      ),
    );
  }

  Widget buildTopBar(bool wide) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1D2B3D))),
      ),
      child: Row(
        children: [
          if (!wide) ...[
            const Icon(Icons.blur_on, color: cyan, size: 28),
            const SizedBox(width: 10),
            const Text(
              'J.A.R.V.I.S.',
              style: TextStyle(
                color: cyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ] else
            const Text(
              'PERSONAL ASSISTANT',
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
          const Spacer(),
          const Icon(Icons.circle, color: cyan, size: 8),
          const SizedBox(width: 8),
          const Text(
            'SYSTEM READY',
            style: TextStyle(color: cyan, fontSize: 11, letterSpacing: 1),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.settings_outlined, color: Colors.white54),
        ],
      ),
    );
  }

  Widget buildAssistant(bool wide) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 18,
        vertical: 24,
      ),
      children: [
        Center(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (context, child) {
                  final scale = 0.96 + pulse.value * 0.06;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: wide ? 145 : 120,
                      height: wide ? 145 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            cyan.withValues(alpha: 0.22),
                            const Color(0xFF142A42),
                            background,
                          ],
                        ),
                        border: Border.all(
                          color: cyan.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cyan.withValues(alpha: 0.16),
                            blurRadius: 35,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.blur_on,
                        color: cyan,
                        size: 65,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'AT YOUR SERVICE',
                style: TextStyle(
                  color: cyan,
                  letterSpacing: 4,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How can I help?',
                style: TextStyle(
                  fontSize: wide ? 30 : 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal command centre',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        for (final message in messages) buildMessage(message),
        if (thinking)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('J.A.R.V.I.S. is processing...',
                  style: TextStyle(color: cyan)),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            suggestion('What time is it?'),
            suggestion('Introduce yourself'),
            suggestion('Hello J.A.R.V.I.S.'),
          ],
        ),
      ],
    );
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF17334A) : panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? cyan.withValues(alpha: 0.25)
                : const Color(0xFF243247),
          ),
        ),
        child: Text(message['text'] ?? ''),
      ),
    );
  }

  Widget suggestion(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      side: BorderSide(color: cyan.withValues(alpha: 0.3)),
      backgroundColor: panel,
      onPressed: () {
        controller.text = text;
        sendMessage();
      },
    );
  }

  Widget buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1D2B3D))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask J.A.R.V.I.S. anything...',
                filled: true,
                fillColor: panel,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Voice input is not connected yet',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice input will be added later.'),
                ),
              );
            },
            icon: const Icon(Icons.mic_none, color: cyan),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            onPressed: sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: cyan,
              foregroundColor: background,
            ),
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }

  Widget buildExtensions() {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text('EXTENSIONS',
            style: TextStyle(color: cyan, letterSpacing: 3)),
        const SizedBox(height: 8),
        const Text('Expand your assistant',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        extensionCard(Icons.language, 'Web Search',
            'Connect a search service for online answers.'),
        extensionCard(Icons.calendar_month, 'Daily Planner',
            'Plan tasks and routines.'),
        extensionCard(Icons.smart_toy_outlined, 'AI Engine',
            'Connect a secure AI backend for real responses.'),
        extensionCard(Icons.graphic_eq, 'Voice Control',
            'Add speech recognition and spoken replies.'),
      ],
    );
  }

  Widget extensionCard(IconData icon, String title, String description) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(icon, color: cyan, size: 30),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: const Icon(Icons.lock_outline, color: Colors.white38),
      ),
    );
  }

  Widget buildMemory() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.memory, color: cyan, size: 58),
            SizedBox(height: 18),
            Text('MEMORY SYSTEM',
                style: TextStyle(color: cyan, letterSpacing: 3)),
            SizedBox(height: 12),
            Text(
              'Memory storage is not connected yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'A secure storage layer will be added in a later step.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
