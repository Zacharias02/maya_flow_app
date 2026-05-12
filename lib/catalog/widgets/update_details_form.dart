import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/update_details_form_schema.dart';

final updateDetailsForm = CatalogItem(
  name: 'UpdateDetailsForm',
  dataSchema: updateDetailsFormSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _UpdateDetailsForm(itemContext: itemContext, data: data);
  },
);

class _UpdateDetailsForm extends StatefulWidget {
  const _UpdateDetailsForm({required this.itemContext, required this.data});

  final CatalogItemContext itemContext;
  final Map<String, dynamic> data;

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
    _nameCtrl = TextEditingController(
      text: widget.data['fullName'] as String? ?? '',
    );
    _emailCtrl = TextEditingController(
      text: widget.data['email'] as String? ?? '',
    );
    _phoneCtrl = TextEditingController(
      text: widget.data['phone'] as String? ?? '',
    );
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
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        surfaceId: widget.itemContext.surfaceId,
        name: 'UpdateDetailsForm_saved',
        sourceComponentId: widget.itemContext.id,
        context: {
          'widget': 'UpdateDetailsForm',
          'summary': 'User tapped Save on the personal details form.',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MayaCatalogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MayaCatalogTheme.tintSurface(context),
                  borderRadius: MayaCatalogTheme.innerRadius,
                ),
                child: Icon(Icons.person_rounded, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update details', style: MayaCatalogTheme.titleStyle(context)),
                    Text(
                      'Review and save your profile',
                      style: MayaCatalogTheme.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameCtrl,
            style: MayaCatalogTheme.fieldValueStyle(context),
            decoration: MayaCatalogTheme.inputDecoration(
              context,
              label: 'Full name',
              prefixIcon: Icons.badge_outlined,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            style: MayaCatalogTheme.fieldValueStyle(context),
            decoration: MayaCatalogTheme.inputDecoration(
              context,
              label: 'Email',
              prefixIcon: Icons.alternate_email_rounded,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            style: MayaCatalogTheme.fieldValueStyle(context),
            decoration: MayaCatalogTheme.inputDecoration(
              context,
              label: 'Phone',
              prefixIcon: Icons.phone_iphone_rounded,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: MayaCatalogTheme.primaryFilledButtonStyle(context),
              onPressed: _saved ? null : _save,
              icon: Icon(_saved ? Icons.check_rounded : Icons.save_rounded, size: 22),
              label: Text(_saved ? 'Saved' : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
