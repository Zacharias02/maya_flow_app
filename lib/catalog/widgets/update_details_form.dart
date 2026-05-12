import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../schemas/update_details_form_schema.dart';

final updateDetailsForm = CatalogItem(
  name: 'UpdateDetailsForm',
  dataSchema: updateDetailsFormSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _UpdateDetailsForm(data: data);
  },
);

class _UpdateDetailsForm extends StatefulWidget {
  final Map<String, dynamic> data;

  const _UpdateDetailsForm({required this.data});

  @override
  State<_UpdateDetailsForm> createState() => _UpdateDetailsFormState();
}

class _UpdateDetailsFormState extends State<_UpdateDetailsForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data['fullName'] as String? ?? '');
    _emailCtrl = TextEditingController(text: widget.data['email'] as String? ?? '');
    _phoneCtrl = TextEditingController(text: widget.data['phone'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Personal Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saved ? null : _save,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
