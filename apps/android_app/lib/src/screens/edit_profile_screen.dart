import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.isBusiness,
    this.businessProfile,
  });

  final UserProfile profile;
  final bool isBusiness;
  final BusinessProfile? businessProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _service = ProfileService();
  late final TextEditingController _usernameCtrl;
  late UserGender _gender;
  late String _language;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(
      text: widget.profile.username.replaceAll('@', ''),
    );
    _gender = widget.profile.gender;
    _language = widget.profile.language;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.isBusiness) {
        await _service.updateUserProfile(
          newUsername: _usernameCtrl.text,
          language: _language,
        );
        await _service.updateBusinessProfile(language: _language);
      } else {
        await _service.updateUserProfile(
          newUsername: _usernameCtrl.text,
          gender: _gender,
          language: _language,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            if (!widget.isBusiness) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<UserGender>(
                initialValue: _gender,
                items: UserGender.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? UserGender.notSpecified),
                decoration: const InputDecoration(labelText: 'Genero'),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              items: const [
                DropdownMenuItem(value: 'es-MX', child: Text('Espanol (Mexico)')),
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                DropdownMenuItem(value: 'pt-BR', child: Text('Portugues (Brasil)')),
                DropdownMenuItem(value: 'zh-CN', child: Text('Chino Mandarin')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'es-MX'),
              decoration: const InputDecoration(labelText: 'Lenguaje favorito'),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
