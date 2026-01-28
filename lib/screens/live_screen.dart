import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bounce_button.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Live Detection")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: provider.currentImage != null
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          key: ValueKey(provider.currentImage.hashCode),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent, width: 4),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(provider.currentImage!, fit: BoxFit.contain),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar, size: 100, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text("Waiting for detection...", style: TextStyle(fontSize: 18)),
                        ],
                      ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status: ${provider.lastStatusCode}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: provider.lastStatusCode == 200 ? Colors.red : Colors.grey,
                          ),
                        ),
                        Text(provider.statusMessage),
                      ],
                    ),
                    
                    // Animated Button
                    BounceButton(
                      onPressed: () => provider.toggleLiveMode(!provider.isLive),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: provider.isLive ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(provider.isLive ? Icons.stop : Icons.play_arrow, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              provider.isLive ? "STOP" : "START",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (provider.isLive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(
                      color: Colors.redAccent,
                      backgroundColor: Colors.red[100],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}