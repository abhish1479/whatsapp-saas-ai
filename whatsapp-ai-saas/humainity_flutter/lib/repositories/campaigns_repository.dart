import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/models/campaign_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This class handles all data operations for Campaigns.
class CampaignsRepository {
  final SupabaseClient _supabase;

  CampaignsRepository(this._supabase);

  Future<List<Campaign>> fetchCampaigns() async {
    final data = await _supabase
        .from('campaigns')
        .select('*')
        .order('created_at', ascending: false);
    return data.map((json) => Campaign.fromJson(json)).toList();
  }

  Future<Campaign> createCampaign(Map<String, dynamic> formData) async {
    final campaignData = {
      ...formData,
      'total_contacts': 0,
      'contacts_reached': 0,
      'successful_deliveries': 0,
      'failed_deliveries': 0,
    };

    final data = await _supabase
        .from('campaigns')
        .insert(campaignData)
        .select()
        .single();
    return Campaign.fromJson(data);
  }

  Future<Campaign> updateStatus(String id, String newStatus) async {
    final data = await _supabase
        .from('campaigns')
        .update({'status': newStatus})
        .eq('id', id)
        .select()
        .single();
    return Campaign.fromJson(data);
  }

  Future<void> deleteCampaign(String id) async {
    await _supabase.from('campaigns').delete().eq('id', id);
  }

  Future<Campaign> fetchCampaignDetails(String campaignId) async {
    final data = await _supabase
        .from('campaigns')
        .select('*')
        .eq('id', campaignId)
        .single();
    return Campaign.fromJson(data);
  }

  Future<List<CampaignLog>> fetchCampaignLogs(String campaignId) async {
    final data = await _supabase
        .from('campaign_logs')
        .select('*')
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);
    return data.map((json) => CampaignLog.fromJson(json)).toList();
  }
}