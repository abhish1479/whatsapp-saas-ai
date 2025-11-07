import 'package:humainity_flutter/models/customer.dart';
import 'package:humainity_flutter/models/customer_campaign.dart';
import 'package:humainity_flutter/models/engagement.dart';
import 'package:humainity_flutter/models/payment.dart';
import 'package:humainity_flutter/models/saved_filter_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This class handles all direct Supabase data operations for the CRM feature.
class CrmRepository {
  final SupabaseClient _supabase;

  CrmRepository(this._supabase);

  Future<Customer> fetchCustomerById(String customerId) async {
    final data = await _supabase
        .from('customers')
        .select('*')
        .eq('id', customerId)
        .single();
    return Customer.fromJson(data);
  }

  Future<List<Customer>> fetchCustomers() async {
    final data = await _supabase
        .from('customers')
        .select('*')
        .order('created_at', ascending: false);
    return data.map((json) => Customer.fromJson(json)).toList();
  }

  Future<List<SavedFilterList>> fetchSavedLists() async {
    final data = await _supabase
        .from('saved_filter_lists')
        .select('*')
        .order('created_at', ascending: false);
    return data.map((json) => SavedFilterList.fromJson(json)).toList();
  }

  Future<Customer> addCustomer(Map<String, dynamic> formData) async {
    final data =
    await _supabase.from('customers').insert(formData).select().single();
    return Customer.fromJson(data);
  }

  Future<Customer> updateCustomerStatus(String customerId, String newStatus) async {
    final data = await _supabase
        .from('customers')
        .update({'status': newStatus})
        .eq('id', customerId)
        .select()
        .single();
    return Customer.fromJson(data);
  }

  Future<List<Engagement>> fetchEngagements(String customerId) async {
    final data = await _supabase
        .from('customer_engagements')
        .select('*')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return data.map((json) => Engagement.fromJson(json)).toList();
  }

  Future<List<Payment>> fetchPayments(String customerId) async {
    final data = await _supabase
        .from('payments')
        .select('*')
        .eq('customer_id', customerId)
        .order('payment_date', ascending: false);
    return data.map((json) => Payment.fromJson(json)).toList();
  }

  Future<List<CustomerCampaign>> fetchCampaigns(String customerId) async {
    final data = await _supabase
        .from('customer_campaigns')
        .select('*, campaigns(name)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return data.map((json) => CustomerCampaign.fromJson(json)).toList();
  }

  Future<Engagement> addEngagement(Map<String, dynamic> formData) async {
    final data = await _supabase
        .from('customer_engagements')
        .insert(formData)
        .select()
        .single();
    return Engagement.fromJson(data);
  }
}