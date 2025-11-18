import 'package:flutter/material.dart';

class Industry {
  final String id;
  final String name;
  final IconData icon;
  final String tagline;
  final String description;
  final List<String> challenges;
  final Map<String, List<String>> solutions;
  final List<Map<String, dynamic>> conversationFlow;
  final List<String> integrations;
  final List<Map<String, String>> results;
  
  final Color color; 

  const Industry({
    required this.id,
    required this.name,
    required this.icon,
    required this.tagline,
    required this.description,
    required this.challenges,
    required this.solutions,
    required this.conversationFlow,
    required this.integrations,
    required this.results,
    required this.color,
  });
}