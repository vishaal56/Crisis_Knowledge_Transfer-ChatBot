import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool ragEnabled = true;
  bool darkMode = false;
  bool showSources = true;
  String responseDetail = "Normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Login"),
          _tile(
            icon: Icons.login,
            title: "Login / Logout",
            onTap: () {},
          ),
          _tile(
            icon: Icons.lock_reset,
            title: "Reset Password",
            onTap: () {},
          ),
          _divider(),

          _sectionTitle("Account Details"),
          _tile(icon: Icons.person, title: "Full Name", subtitle: "John Doe"),
          _tile(icon: Icons.email_outlined, title: "Email", subtitle: "john@company.com"),
          _tile(icon: Icons.group_outlined, title: "Department", subtitle: "Procurement"),
          _tile(icon: Icons.shield_outlined, title: "Role", subtitle: "Crisis Manager"),
          _tile(icon: Icons.edit_outlined, title: "Edit Profile"),
          _divider(),

          _sectionTitle("Assistant Preferences"),
          SwitchListTile(
            value: ragEnabled,
            onChanged: (value) {
              setState(() {
                ragEnabled = value;
              });
            },
            title: const Text("Enable Retrieval-Augmented Generation (RAG)"),
            subtitle: const Text("Improve accuracy using knowledge base"),
          ),

          SwitchListTile(
            value: showSources,
            onChanged: (value) {
              setState(() {
                showSources = value;
              });
            },
            title: const Text("Show Source Documents"),
          ),

          SwitchListTile(
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
            title: const Text("Dark Mode"),
          ),
          ListTile(
            title: const Text("Response Detail Level"),
            subtitle: Text(responseDetail),
            trailing: DropdownButton<String>(
              value: responseDetail,
              items: ["Short", "Normal", "Detailed"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => responseDetail = v!),
            ),
          ),
          _divider(),

          _sectionTitle("Crisis Data & Privacy"),
          _tile(
            icon: Icons.delete_forever_outlined,
            title: "Clear Conversation History",
            onTap: () {},
          ),
          _tile(
            icon: Icons.picture_as_pdf_outlined,
            title: "Export Last Report as PDF",
            onTap: () {},
          ),
          _tile(
            icon: Icons.security_outlined,
            title: "Data Privacy & Access Rules",
          ),
          _divider(),

          _sectionTitle("System"),
          _tile(
            icon: Icons.api_outlined,
            title: "Backend API URL",
            subtitle: "https://your-backend.com/chat",
          ),
          _tile(
            icon: Icons.storage_rounded,
            title: "Knowledge Base Status",
            subtitle: "52 documents indexed",
          ),
          _tile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle: "v1.0.0",
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _tile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
    );
  }

  Widget _divider() => const Divider(height: 32);
}