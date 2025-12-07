import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AttachContentPage extends StatefulWidget {
  const AttachContentPage({super.key});

  @override
  State<AttachContentPage> createState() => _AttachContentPageState();
}

class _AttachContentPageState extends State<AttachContentPage> {
  File? selectedFile;
  File? selectedImage;

  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attach Content"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Add context to your crisis report",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Pick file
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.blue),
            title: const Text("Upload a File"),
            subtitle: selectedFile != null
                ? Text(selectedFile!.path.split('/').last)
                : const Text("PDF, DOCX, TXT, etc."),
            onTap: _pickFile,
          ),

          const Divider(),

          // Pick photo
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text("Add a Photo"),
            subtitle: selectedImage != null
                ? const Text("1 image selected")
                : const Text("Upload machine/area incident photo"),
            onTap: _pickPhoto,
          ),

          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  selectedImage!,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const Divider(),

          const Text(
            "Add Notes (optional)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: "Describe additional incident context...",
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Attach to Conversation"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF4F46E5),
            ),
            onPressed: () {
              Navigator.pop(context, {
                "file": selectedFile,
                "photo": selectedImage,
                "notes": notesController.text,
              });
            },
          ),
        ],
      ),
    );
  }
}