import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LocalScreen extends StatelessWidget {
  const LocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Captured Violations")),
      body: provider.savedImages.isEmpty
          ? const Center(child: Text("No violations recorded locally."))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.savedImages.length,
              itemBuilder: (ctx, i) {
                final file = provider.savedImages[i] as File;
                return InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (_) => Dialog(
                      child: Image.file(file),
                    ));
                  },
                  // LONG PRESS TO DELETE
                  onLongPress: () {
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text("Delete Image?"),
                      content: const Text("This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx), 
                          child: const Text("Cancel")
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteImage(file);
                            Navigator.pop(ctx);
                          }, 
                          child: const Text("Delete", style: TextStyle(color: Colors.red))
                        ),
                      ],
                    ));
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(file, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.touch_app, color: Colors.white, size: 14),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}