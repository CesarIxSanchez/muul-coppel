import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_models.dart';

class ProfileService {
  ProfileService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('No hay sesión activa');
    return id;
  }

  Future<UserProfile?> getMyUserProfile() async {
    final data = await _client.from('users').select().eq('id', _uid).maybeSingle();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  Future<UserProfile> createUserProfile({
    required String username,
    required UserGender gender,
    String language = 'es-MX',
  }) async {
    var candidate = _normalizeUsername(username);
    final random = Random();

    for (var i = 0; i < 5; i++) {
      try {
        final data = await _client
            .from('users')
            .insert({
              'id': _uid,
              'username': candidate,
              'gender': gender.dbValue,
              'language': language,
              'avatar_url': 'https://i.pravatar.cc/300?img=12',
            })
            .select()
            .single();
        return UserProfile.fromMap(data);
      } on PostgrestException catch (e) {
        if (e.code != '23505') rethrow;
        candidate = '@${candidate.replaceAll('@', '')}${random.nextInt(90000) + 10000}';
      }
    }

    throw Exception('No se pudo generar un username único.');
  }

  Future<UserProfile> updateUserProfile({
    String? newUsername,
    UserGender? gender,
    String? language,
    String? avatarUrl,
  }) async {
    final current = await getMyUserProfile();
    if (current == null) throw Exception('Perfil no encontrado');

    final updates = <String, dynamic>{};

    if (newUsername != null && newUsername.isNotEmpty && newUsername != current.username) {
      if (current.lastUsernameChangeDate != null &&
          DateTime.now().difference(current.lastUsernameChangeDate!).inDays < 30) {
        throw Exception('Solo puedes cambiar tu username una vez cada mes.');
      }
      updates['username'] = _normalizeUsername(newUsername);
      updates['last_username_change_date'] = DateTime.now().toIso8601String();
    }

    if (gender != null) updates['gender'] = gender.dbValue;
    if (language != null) updates['language'] = language;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isEmpty) return current;

    try {
      final data = await _client.from('users').update(updates).eq('id', _uid).select().single();
      return UserProfile.fromMap(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ese username ya existe.');
      }
      rethrow;
    }
  }

  Future<BusinessProfile?> getMyBusinessProfile() async {
    final data = await _client.from('businesses').select().eq('id', _uid).maybeSingle();
    if (data == null) return null;
    return BusinessProfile.fromMap(data);
  }

  Future<BusinessProfile> registerBusiness({
    required String businessName,
    required String address,
    String language = 'es-MX',
  }) async {
    final data = await _client
        .from('businesses')
        .insert({
          'id': _uid,
          'business_name': businessName.trim(),
          'address': address.trim(),
          'language': language,
          'avatar_url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=400&q=80',
        })
        .select()
        .single();

    return BusinessProfile.fromMap(data);
  }

  Future<BusinessProfile> updateBusinessProfile({
    required String language,
    String? avatarUrl,
  }) async {
    final data = await _client
        .from('businesses')
        .update({
          'language': language,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
        })
        .eq('id', _uid)
        .select()
        .single();
    return BusinessProfile.fromMap(data);
  }

  String _normalizeUsername(String input) {
    final clean = input.trim().replaceAll(' ', '').replaceAll('@', '');
    if (clean.isEmpty) throw Exception('Username inválido');
    return '@$clean';
  }
}
