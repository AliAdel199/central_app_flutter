import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> logAction({String? action, String? table, String? recordId, String? description}) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  await Supabase.instance.client.from('logs').insert({
    'user_id': userId,
    'action': action,
    'table_name': table,
    'record_id': recordId,
    'description': description,
  });
}
