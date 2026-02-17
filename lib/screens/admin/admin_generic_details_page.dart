import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class AdminGenericDetailsPage extends StatefulWidget {
  final String collectionName;
  final String title; // "Edit Category", "Edit Character", etc.
  final String docId;
  final Map<String, dynamic> initialData;

  const AdminGenericDetailsPage({
    super.key,
    required this.collectionName,
    required this.title,
    required this.docId,
    required this.initialData,
  });

  @override
  State<AdminGenericDetailsPage> createState() =>
      _AdminGenericDetailsPageState();
}

class _AdminGenericDetailsPageState extends State<AdminGenericDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.docId)
          .update({
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            // We can add 'updatedAt': FieldValue.serverTimestamp() if needed
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving changes: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection(widget.collectionName)
            .doc(widget.docId)
            .delete();
        if (mounted) {
          Navigator.pop(context); // Go back to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteItem,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.label_outline,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description / Prompt',
                    icon: Icons.description_outlined,
                    maxLines: 10,
                    hint:
                        'Enter full description here. This will be used for AI generation.',
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppTheme.primaryColor)
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: 120,
                ), // Align icon to top for textarea
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
