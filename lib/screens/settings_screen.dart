import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // ================= APPEARANCE =================
          _buildHeader(context, "Appearance"),
          ListTile(
            leading: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text("Dark Mode"),
            subtitle:
                Text(provider.isDarkMode ? "Enabled" : "Disabled"),
            trailing: Switch(
              value: provider.isDarkMode,
              activeColor:
                  Theme.of(context).colorScheme.primary,
              onChanged: (val) => provider.toggleTheme(val),
            ),
          ),

          const Divider(),

          // ================= DETECTION SETTINGS =================
          _buildHeader(context, "Detection Config"),

          ListTile(
            title: const Text("Auto-Save Images"),
            subtitle:
                const Text("Save every detected image to local storage"),
            trailing: Switch(
              value: provider.autoSaveEnabled,
              onChanged: (val) => provider.toggleAutoSave(val),
              activeColor: Colors.teal,
            ),
          ),

          ListTile(
            title:
                Text("Polling Interval: ${provider.pollingInterval} sec"),
            subtitle:
                const Text("How often to check for litter"),
          ),
          Slider(
            value: provider.pollingInterval.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: Colors.teal,
            label: "${provider.pollingInterval}s",
            onChanged: (val) {
              provider.setPollingInterval(val.toInt());
            },
          ),

          const Divider(),

          // ================= STORAGE INFO =================
          _buildHeader(context, "Storage"),

          ListTile(
            leading:
                const Icon(Icons.folder_open, color: Colors.amber),
            title: const Text("Storage Location"),
            subtitle: Text(
              provider.saveDirectory ?? "Unknown",
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
            isThreeLine: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Files are stored in the App Data folder"),
                ),
              );
            },
          ),

          const Divider(),

          // ================= AUDIO =================
          _buildHeader(context, "Alerts"),

          ListTile(
            leading:
                const Icon(Icons.music_note, color: Colors.blue),
            title: const Text("Custom Alarm Sound"),
            subtitle: Text(
              provider.customAudioPath != null
                  ? "Custom File Selected"
                  : "Default System Behavior",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (await Permission.audio.request().isGranted ||
                  await Permission.storage.request().isGranted) {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );

                if (result != null &&
                    result.files.single.path != null) {
                  provider
                      .setCustomAudio(result.files.single.path!);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= SECTION HEADER =================
  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
