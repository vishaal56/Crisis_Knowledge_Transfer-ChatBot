import 'package:flutter/material.dart';

class ActionsHubPage extends StatelessWidget {
  const ActionsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4F46E5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action Center'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crisis Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose what you want to do with the crisis assistant.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _actionCard(
                    context,
                    icon: Icons.upload_file_outlined,
                    title: 'Upload Document',
                    description:
                    'Attach SOPs, incident logs, or guidelines to the conversation.',
                    accent: accent,
                    onTap: () {
                      // TODO: navigate to your attach file page
                      // e.g. Navigator.pushNamed(context, '/attach');
                    },
                  ),
                  _actionCard(
                    context,
                    icon: Icons.menu_book_outlined,
                    title: 'Knowledge Base',
                    description:
                    'Browse crisis procedures, checklists, and training material.',
                    accent: accent,
                    onTap: () {
                      // TODO: open KB page / modal
                    },
                  ),
                  _actionCard(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Generate Report',
                    description:
                    'Create a summary report of this incident and assistant replies.',
                    accent: accent,
                    onTap: () {
                      // TODO: trigger report generation
                    },
                  ),
                  _actionCard(
                    context,
                    icon: Icons.support_agent_outlined,
                    title: 'Escalate to Expert',
                    description:
                    'Prepare an escalation message and share conversation context.',
                    accent: accent,
                    onTap: () {
                      // TODO: escalation flow
                    },
                  ),
                  _actionCard(
                    context,
                    icon: Icons.refresh_rounded,
                    title: 'New Incident',
                    description:
                    'Start a fresh conversation for a new crisis scenario.',
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context, 'new_incident');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color accent,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.04),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}