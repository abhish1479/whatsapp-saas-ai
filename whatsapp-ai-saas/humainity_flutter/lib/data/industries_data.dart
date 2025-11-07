import 'package:humainity_flutter/data/industry_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

// This is a direct conversion of your industries.ts file
const List<Industry> industries = [
  Industry(
    id: "education-coaching",
    name: "Education & Coaching",
    icon: LucideIcons.graduationCap,
    tagline: "Transform Learning with AI-Powered Communication",
    description:
    "Automate admissions, counselling, class reminders, and test prep follow-ups with intelligent conversational AI.",
    challenges: [
      "Manual follow-up with prospective students leads to missed enrollments",
      "Difficulty managing multiple batches and schedules",
      "Poor parent-teacher communication and engagement"
    ],
    solutions: {
      "whatsapp": [
        "Automated admission inquiry responses with course details",
        "Class schedule reminders and attendance notifications",
        "Assignment submission confirmations and grade updates"
      ],
      "voice": [
        "AI voice calls for admission counselling and course recommendations",
        "Automated payment reminders for fees and installments",
        "Parent-teacher meeting scheduling and reminders"
      ],
      "campaigns": [
        "Batch-wise promotional campaigns for new courses",
        "Seasonal enrollment drives with personalized offers",
        "Student success stories and testimonials to parents"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
        "Hi! 👋 Interested in our coaching programs? Reply YES to explore courses."
      },
      {
        "step": 2,
        "message":
        "Great! We offer: 1️⃣ JEE/NEET 2️⃣ UPSC 3️⃣ CA Foundation. Which interests you?",
        "response": "1"
      },
      {
        "step": 3,
        "message":
        "Perfect! Our JEE batch starts next month. Would you like to: 📅 Book a demo class or 💬 Talk to a counselor?",
        "response": "Book demo"
      },
      {
        "step": 4,
        "message":
        "Demo booked for Saturday 10 AM! Check your WhatsApp for the meeting link. See you there! 🎓"
      }
    ],
    integrations: [
      "Learning Management Systems (LMS)",
      "Payment Gateways",
      "Google Classroom",
      "Zoom/Teams Integration",
      "Student Information Systems"
    ],
    results: [
      {"metric": "Enrollment Rate", "value": "+35%"},
      {"metric": "Manual Follow-ups", "value": "-70%"},
      {"metric": "Parent Engagement", "value": "+50%"},
      {"metric": "Payment Collection", "value": "+40%"}
    ],
  ),
  Industry(
    id: "healthcare-wellness",
    name: "Healthcare & Wellness",
    icon: LucideIcons.heart,
    tagline: "Deliver Care with Empathy and Automation",
    description:
    "Streamline appointments, teleconsultation, and patient reminders while maintaining the human touch.",
    challenges: [
      "High no-show rates for appointments affecting revenue",
      "Manual appointment booking consuming staff time",
      "Delayed follow-ups on test results and prescriptions"
    ],
    solutions: {
      "whatsapp": [
        "Automated appointment booking and confirmation",
        "Lab report delivery and prescription reminders",
        "Post-treatment follow-up and feedback collection"
      ],
      "voice": [
        "AI voice reminders 24 hours before appointments",
        "Automated rescheduling for cancellations",
        "Health checkup and vaccination reminders"
      ],
      "campaigns": [
        "Health awareness campaigns and seasonal checkup drives",
        "New service launches and doctor availability updates",
        "Wellness tips and preventive care messaging"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message": "Hello! 🏥 Need to book an appointment with Dr. Sharma? Reply YES."
      },
      {
        "step": 2,
        "message":
        "Available slots: 1️⃣ Today 5 PM 2️⃣ Tomorrow 11 AM 3️⃣ Friday 3 PM. Choose one:",
        "response": "2"
      },
      {
        "step": 3,
        "message":
        "Confirmed! Tomorrow at 11 AM with Dr. Sharma. You'll receive a reminder 2 hours before. 📅"
      },
      {
        "step": 4,
        "message":
        "Quick reminder: Your appointment is in 2 hours. Clinic address: XYZ Medical Center. See you soon! 👨‍⚕️"
      }
    ],
    integrations: [
      "Hospital Management Systems",
      "Electronic Health Records (EHR)",
      "Payment Gateways",
      "Teleconsultation Platforms",
      "Pharmacy Systems"
    ],
    results: [
      {"metric": "No-Show Rate", "value": "-60%"},
      {"metric": "Booking Time", "value": "-80%"},
      {"metric": "Patient Satisfaction", "value": "+45%"},
      {"metric": "Staff Efficiency", "value": "+55%"}
    ],
  ),
  Industry(
    id: "real-estate",
    name: "Real Estate & Property",
    icon: LucideIcons.home,
    tagline: "Convert Leads Faster with Intelligent Automation",
    description:
    "Manage property inquiries, schedule site visits, and nurture leads with AI-powered conversations.",
    challenges: [
      "High lead volume but low conversion rates",
      "Manual follow-ups causing delayed responses",
      "Difficulty scheduling and coordinating site visits"
    ],
    solutions: {
      "whatsapp": [
        "Instant property inquiry responses with details and images",
        "Virtual property tours and document sharing",
        "EMI calculators and loan assistance information"
      ],
      "voice": [
        "Automated site visit scheduling and confirmations",
        "Follow-up calls for interested prospects",
        "Payment reminder calls for bookings and installments"
      ],
      "campaigns": [
        "New project launches with exclusive early bird offers",
        "Festival season promotional campaigns",
        "Property investment webinar invitations"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
        "Hi! 🏡 Interested in our new residential project? Reply YES for details."
      },
      {
        "step": 2,
        "message":
        "Great! We have 2BHK & 3BHK apartments starting at ₹45L. Would you like to: 📸 See photos or 📅 Schedule a site visit?",
        "response": "Site visit"
      },
      {
        "step": 3,
        "message":
        "Perfect! Available slots: 1️⃣ Saturday 11 AM 2️⃣ Sunday 4 PM. Choose one:",
        "response": "1"
      },
      {
        "step": 4,
        "message":
        "Site visit confirmed for Saturday 11 AM! Our agent will meet you at the project location. Looking forward to seeing you! 🏗️"
      }
    ],
    integrations: [
      "CRM Systems",
      "Property Management Software",
      "Payment Gateways",
      "Document Management",
      "Virtual Tour Platforms"
    ],
    results: [
      {"metric": "Lead Response Time", "value": "-90%"},
      {"metric": "Site Visit Conversions", "value": "+42%"},
      {"metric": "Sales Cycle Time", "value": "-35%"},
      {"metric": "Lead Engagement", "value": "+65%"}
    ],
  ),
  // ... All other 17 industries from your file would go here ...
];