import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.appState, super.key});

  final AppState appState;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailAddressController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _roleTitleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final credentials = widget.appState.userCredentials;
    _fullNameController = TextEditingController(text: credentials.fullName);
    _businessNameController =
        TextEditingController(text: credentials.businessName);
    _emailAddressController =
        TextEditingController(text: credentials.emailAddress);
    _phoneNumberController =
        TextEditingController(text: credentials.phoneNumber);
    _roleTitleController = TextEditingController(text: credentials.roleTitle);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailAddressController.dispose();
    _phoneNumberController.dispose();
    _roleTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final credentials = widget.appState.userCredentials;

    return PageScaffold(
      title: 'Settings',
      subtitle:
          'Store your business identity and contact credentials locally so reports and future sync features can use the right account details.',
      eyebrow: 'User profile',
      headerIcon: Icons.settings_rounded,
      accentColor: const Color(0xFF334155),
      statusLabel: credentials.completionLabel,
      statusColor: credentials.isComplete
          ? const Color(0xFFBBF7D0)
          : const Color(0xFFFDE68A),
      highlights: [
        PageHeaderHighlight(
          label: 'Owner',
          value:
              credentials.fullName.isEmpty ? 'Not set' : credentials.fullName,
        ),
        PageHeaderHighlight(
          label: 'Business',
          value: credentials.businessName.isEmpty
              ? 'Not set'
              : credentials.businessName,
        ),
        PageHeaderHighlight(
          label: 'Contact',
          value: credentials.emailAddress.isEmpty
              ? 'Not set'
              : credentials.emailAddress,
        ),
      ],
      actions: [
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveCredentials,
          icon: const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Saving...' : 'Save credentials'),
        ),
      ],
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              final width =
                  wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Profile credentials',
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField(
                              controller: _fullNameController,
                              label: 'Full name',
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _businessNameController,
                              label: 'Business / company name',
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _emailAddressController,
                              label: 'Email address',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _emailValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _phoneNumberController,
                              label: 'Phone number',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: _requiredValue,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _roleTitleController,
                              label: 'Role / title',
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _isSaving ? null : _saveCredentials,
                                icon: const Icon(Icons.save_outlined),
                                label: Text(
                                  _isSaving ? 'Saving...' : 'Save credentials',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Storage & usage',
                      child: Column(
                        children: [
                          _SettingsInfoRow(
                            icon: Icons.storage_rounded,
                            title: 'Local storage',
                            subtitle:
                                'Your settings are saved on this device and remain available offline.',
                            value: 'Active',
                          ),
                          const Divider(height: 24),
                          _SettingsInfoRow(
                            icon: Icons.badge_outlined,
                            title: 'Profile status',
                            subtitle: credentials.isComplete
                                ? 'Your account details are complete and ready to use.'
                                : 'Complete the core fields so reports and identity details are accurate.',
                            value: credentials.completionLabel,
                          ),
                          const Divider(height: 24),
                          _SettingsInfoRow(
                            icon: Icons.sync_outlined,
                            title: 'Sync readiness',
                            subtitle: widget.appState.syncStatus.isOnline
                                ? 'Saved credentials can be synchronized when connected services are added.'
                                : '${widget.appState.syncStatus.pendingChanges} local changes are waiting while offline.',
                            value: widget.appState.syncStatus.isOnline
                                ? 'Online'
                                : 'Offline',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.appState.saveUserCredentials(
      fullName: _fullNameController.text,
      businessName: _businessNameController.text,
      emailAddress: _emailAddressController.text,
      phoneNumber: _phoneNumberController.text,
      roleTitle: _roleTitleController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credentials saved locally.')),
    );
  }

  String? _requiredValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _emailValue(String? value) {
    final requiredCheck = _requiredValue(value);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    final normalized = value!.trim();
    if (!normalized.contains('@') || !normalized.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }
}

class _SettingsInfoRow extends StatelessWidget {
  const _SettingsInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF334155)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
