import 'package:flutter/material.dart';

/// Data model for a conversational AI agent profile.
class AiAgent {
  final String id;
  final String name;
  final String persona;
  final String role;
  final String imagePath;
  final Color primaryColor;

  const AiAgent({
    required this.id,
    required this.name,
    required this.persona,
    required this.role,
    required this.imagePath,
    required this.primaryColor,
  });
}

// Data for the pre-configured agents. These paths reference the assets
// you have in your project's assets/images folder.
const List<AiAgent> presetAgents = [
  AiAgent(
    id: 'agent-sarah',
    name: 'Sarah',
    persona: 'Proactive Sales Representative',
    role:
        'Sarah specializes in identifying warm leads, qualifying prospects based on stated needs, and proactively booking follow-up demonstration calls.',
    imagePath: 'assets/images/agent-sarah.jpg',
    primaryColor: Color(0xFF1E88E5), // Green
  ),
  AiAgent(
    id: 'agent-alex',
    name: 'Alex',
    persona: 'Friendly Customer Success Agent',
    role:
        'Alex is designed to help new customers with onboarding, address common usage issues, and provide quick links to tutorials and documentation.',
    imagePath: 'assets/images/agent-alex.jpg',
    primaryColor: Color(0xFF1E88E5), // Blue
  ),
  AiAgent(
    id: 'agent-maya',
    name: 'Maya',
    persona: 'Technical Support Specialist',
    role:
        'Maya is an expert in troubleshooting complex technical problems, analyzing error logs, and providing detailed, step-by-step resolution guides.',
    imagePath: 'assets/images/agent-maya.jpg',
    primaryColor: Color(0xFF1E88E5), // Red
  ),
  AiAgent(
    id: 'agent-david',
    name: 'David',
    persona: 'Design your own AI persona from scratch.',
    role:
        'This agent has no pre-set instructions. You must define the name, persona, and role explicitly for optimal performance.',
    imagePath: 'assets/images/agent-david.jpg', // Placeholder image
    primaryColor: Color(0xFF1E88E5), // Deep Purple
  ),
];

// Data map for custom role tags (used in AIAgentScreen)
const Map<String, String> roleDescriptions = {
  'Customer Support':
      'Acts as a customer support agent, prioritizing prompt answers, troubleshooting, and providing helpful solutions based on uploaded knowledge.',
  'Recruitment':
      'Acts as a virtual recruiter, screening candidates, answering FAQ about open positions, and scheduling initial interview calls.',
  'Feedback':
      'Acts as a feedback collector, engaging users about their recent experience and logging detailed sentiment and survey responses.',
  'Appointment':
      'Acts as an appointment setter/scheduler, managing calendar availability and confirming bookings across all channels.',
  'Sales Enquiry':
      'Acts as a lead qualification specialist, gathering prospect data, answering product-specific queries, and forwarding hot leads to a human sales rep.',
  'Outbound Sales':
      'Acts as a proactive sales agent, launching campaigns, handling initial objections, and nurturing leads over several personalized touchpoints.',
};
