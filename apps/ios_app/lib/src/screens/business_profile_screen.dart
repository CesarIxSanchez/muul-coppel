import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _service = ProfileService();
  BusinessProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _profile = await _service.getMyBusinessProfile();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final current = _profile;
    if (current == null) return;

    final avatarCtrl = TextEditingController(text: current.avatarUrl ?? '');
    var lang = current.language;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil de negocio'),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Nombre del negocio (bloqueado)',
                  hintText: current.businessName,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Dirección (bloqueada)',
                  hintText: current.address,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: lang,
                items: const [
                  DropdownMenuItem(value: 'es-MX', child: Text('Español (México)')),
                  DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                ],
                onChanged: (v) => setLocal(() => lang = v ?? 'es-MX'),
                decoration: const InputDecoration(labelText: 'Idioma'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avatarCtrl,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (saved != true) return;

    await _service.updateBusinessProfile(language: lang, avatarUrl: avatarCtrl.text.trim());
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('No existe perfil de negocio para este usuario.')),
      );
    }

    final p = _profile!;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Negocio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundImage: NetworkImage(p.avatarUrl ?? 'https://i.pravatar.cc/300?img=22'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: p.businessName,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Nombre del negocio (inmutable)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: p.address,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Dirección (inmutable)'),
            ),
            const SizedBox(height: 10),
            Text('Idioma actual: ${p.language}'),
            const Spacer(),
            FilledButton(onPressed: _edit, child: const Text('Editar campos permitidos')),
          ],
        ),
      ),
    );
  }
}
