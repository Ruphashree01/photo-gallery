import 'package:flutter/material.dart';
import 'package:photo_gallery/models/photo.dart';
import 'services/database_service.dart';

class AddPhotoDialog extends StatefulWidget {
  final Function(Photos) onAdd;

  AddPhotoDialog({required this.onAdd});

  @override
  _AddPhotoDialogState createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final DatabaseService _databaseService = DatabaseService();

  final _photographerController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  bool _isValidURL(String url) {
    final urlPattern =
        r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$';
    final regExp = RegExp(urlPattern, caseSensitive: false);
    return regExp.hasMatch(url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Add Photo')),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: "Photographer Name",
                controller: _photographerController,
              ),
              SizedBox(height: 15),
              _buildTextField(
                label: "Image URL",
                controller: _urlController,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 15),
              _buildTextField(
                label: "Description",
                controller: _descriptionController,
              ),
              SizedBox(height: 15),
              _buildDateField(
                controller: _dateController,
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL'),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            primary: Colors.white,
            backgroundColor: Colors.orange,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final photographerName = _photographerController.text;
            final imageURL = _urlController.text;
            final description = _descriptionController.text;

            if (photographerName.isEmpty ||
                imageURL.isEmpty ||
                description.isEmpty ||
                _selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Please fill all fields and select a date.')),
              );
              return;
            }

            if (!_isValidURL(imageURL)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Enter a valid URL.')),
              );
              return;
            }

            Photos photo = Photos(
              name: photographerName,
              url: imageURL,
              description: description,
              dateTime: DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                0,
                0,
                0,
                0,
                0,
              ),
            );

            widget.onAdd(photo);
            _databaseService.addPhoto(photo);
            Navigator.of(context).pop();
          },
          child: Text('ADD'),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            primary: Colors.orange,
            onPrimary: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                hintText: 'Select the Date',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _photographerController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
