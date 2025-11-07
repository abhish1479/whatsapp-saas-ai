import 'package:humainity_flutter/models/template.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This class handles all data operations for Templates.
class TemplatesRepository {
  final SupabaseClient _supabase;

  TemplatesRepository(this._supabase);

  Future<List<MessageTemplate>> fetchTemplates({String? type}) async {
    var query = _supabase
        .from('message_templates')
        .select('id, name, type, message_text') // Fetch only necessary fields for list
        .eq('is_active', true);

    if (type != null) {
      query = query.eq('type', type);
    }

    final data = await query;
    return data.map((json) => MessageTemplate.fromJson(json)).toList();
  }

  Future<MessageTemplate> fetchTemplateById(String id) async {
    final data = await _supabase
        .from('message_templates')
        .select('*') // Fetch all fields for detail view
        .eq('id', id)
        .single();
    return MessageTemplate.fromJson(data);
  }

  // *** FIX: Added saveTemplate method ***
  Future<MessageTemplate> saveTemplate(Map<String, dynamic> formData, String? id) async {
    if (id == null) {
      // Create new
      final data = await _supabase
          .from('message_templates')
          .insert(formData)
          .select()
          .single();
      return MessageTemplate.fromJson(data);
    } else {
      // Update
      final data = await _supabase
          .from('message_templates')
          .update(formData)
          .eq('id', id)
          .select()
          .single();
      return MessageTemplate.fromJson(data);
    }
  }

  // *** FIX: Added deleteTemplate method ***
  Future<void> deleteTemplate(String id) async {
    await _supabase
        .from('message_templates')
        .delete()
        .eq('id', id);
  }
}