import 'package:flutter/material.dart';
import 'package:humainise_ai/data/industry_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Helper function needed for IndustryDetailScreen.fromRoute
Industry? getIndustryById(String id) {
  try {
    return industries.firstWhere((i) => i.id == id);
  } catch (e) {
    return null;
  }
}

// Color mapping for industries based on theme
const Color _educationColor = Color(0xFF1E88E5);
const Color _healthcareColor = Color(0xFFEF4444);
const Color _realEstateColor = Color(0xFF10B981);
const Color _retailColor = Color(0xFFF59E0B);
const Color _financeColor = Color(0xFF0EA5E9);
const Color _travelColor = Color(0xFF6366F1);
const Color _ngoColor = Color(0xFFEC4899);
const Color _automobileColor = Color(0xFF3B82F6);
const Color _manufacturingColor = Color(0xFF6B7280);
const Color _itSaasColor = Color(0xFF8B5CF6);
const Color _eventsColor = Color(0xFF14B8A6);
const Color _governmentColor = Color(0xFF374151);
const Color _logisticsColor = Color(0xFFF97316);
const Color _fitnessColor = Color(0xFFF43F5E);
const Color _schoolColor = Color(0xFF1D4ED8);
const Color _legalColor = Color(0xFF22C55E);
const Color _restaurantColor = Color(0xFFEAB308);
const Color _telecomColor = Color(0xFF64748B);
const Color _constructionColor = Color(0xFFA16207);
const Color _professionalColor = Color(0xFF0D9488);

// This is the complete conversion of your industries.ts file
const List<Industry> industries = [
  // 1. Education & Coaching
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
    color: _educationColor,
  ),

  // 2. Healthcare & Wellness
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
        "message":
            "Hello! 🏥 Need to book an appointment with Dr. Sharma? Reply YES."
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
    color: _healthcareColor,
  ),

  // 3. Real Estate & Property
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
    color: _realEstateColor,
  ),

  // 4. Retail & Ecommerce
  Industry(
    id: "retail-ecommerce",
    name: "Retail & Ecommerce",
    icon: LucideIcons.shoppingCart,
    tagline: "Deliver Exceptional Shopping Experiences at Scale",
    description:
        "Automate order tracking, promotions, and feedback collection while personalizing customer interactions.",
    challenges: [
      "High cart abandonment rates affecting revenue",
      "Manual order status queries overwhelming support teams",
      "Low repeat purchase rates and customer retention"
    ],
    solutions: {
      "whatsapp": [
        "Automated order confirmations and tracking updates",
        "Personalized product recommendations and upsells",
        "Easy returns and refund processing"
      ],
      "voice": [
        "Abandoned cart recovery calls with special offers",
        "Order delivery confirmation and feedback calls",
        "COD payment reminder calls"
      ],
      "campaigns": [
        "Flash sales and limited-time offer announcements",
        "New arrival notifications based on browsing history",
        "Loyalty program updates and reward redemptions"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hi! 🛍️ You left items in your cart. Complete your order now and get 10% OFF! Interested?",
        "response": "Yes"
      },
      {
        "step": 2,
        "message":
            "Awesome! Here's your cart: 1x Blue Denim Jacket (₹1,999). Total: ₹1,799 after discount. Proceed to payment?",
        "response": "Yes"
      },
      {
        "step": 3,
        "message": "Payment options: 1️⃣ UPI 2️⃣ Card 3️⃣ COD. Choose one:",
        "response": "1"
      },
      {
        "step": 4,
        "message":
            "Order confirmed! 🎉 Your jacket will arrive by Thursday. Track here: [link]. Thank you for shopping with us!"
      }
    ],
    integrations: [
      "Ecommerce Platforms (Shopify, WooCommerce)",
      "Payment Gateways",
      "Inventory Management",
      "Shipping Partners",
      "CRM Systems"
    ],
    results: [
      {"metric": "Cart Recovery Rate", "value": "+28%"},
      {"metric": "Support Tickets", "value": "-65%"},
      {"metric": "Repeat Purchases", "value": "+38%"},
      {"metric": "Customer Lifetime Value", "value": "+45%"}
    ],
    color: _retailColor,
  ),

  // 5. Finance & Insurance
  Industry(
    id: "finance-insurance",
    name: "Finance & Insurance",
    icon: LucideIcons.dollarSign,
    tagline: "Build Trust Through Timely, Transparent Communication",
    description:
        "Automate loan applications, claims processing, and payment reminders with compliant AI communication.",
    challenges: [
      "High dropout rates during loan application process",
      "Manual follow-ups for EMI payments causing delays",
      "Poor claim status communication leading to dissatisfaction"
    ],
    solutions: {
      "whatsapp": [
        "Instant loan eligibility checks and pre-approved offers",
        "Document collection and verification updates",
        "Policy renewal reminders and easy renewal links"
      ],
      "voice": [
        "EMI payment reminder calls with flexible options",
        "Claim status update calls and document requests",
        "Insurance policy review and upsell calls"
      ],
      "campaigns": [
        "Seasonal loan offers (festival, education, home)",
        "Insurance awareness campaigns and new product launches",
        "Financial planning webinar invitations"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! 💰 Need a personal loan? Check your pre-approved offer instantly. Reply YES."
      },
      {
        "step": 2,
        "message":
            "Great news! You're pre-approved for up to ₹5 lakhs at 10.5% p.a. Loan amount needed?",
        "response": "3 lakhs"
      },
      {
        "step": 3,
        "message":
            "Perfect! EMI: ₹9,950/month for 36 months. Upload documents: 1️⃣ PAN 2️⃣ Aadhaar 3️⃣ Salary slips. Start?",
        "response": "Yes"
      },
      {
        "step": 4,
        "message":
            "Documents received! ✅ Your application is under review. You'll get approval within 24 hours. We'll keep you updated! 🏦"
      }
    ],
    integrations: [
      "Core Banking Systems",
      "Loan Management Software",
      "Payment Gateways",
      "Credit Bureaus",
      "KYC Platforms"
    ],
    results: [
      {"metric": "Loan Completion Rate", "value": "+32%"},
      {"metric": "EMI Collection", "value": "+48%"},
      {"metric": "Processing Time", "value": "-55%"},
      {"metric": "Customer Satisfaction", "value": "+40%"}
    ],
    color: _financeColor,
  ),

  // 6. Travel & Hospitality
  Industry(
    id: "travel-hospitality",
    name: "Travel & Hospitality",
    icon: LucideIcons.plane,
    tagline: "Create Memorable Journeys from Booking to Feedback",
    description:
        "Automate bookings, cancellations, check-in reminders, and feedback with personalized guest communication.",
    challenges: [
      "High booking cancellation rates without proper reminders",
      "Manual check-in processes causing guest wait times",
      "Low post-stay feedback and review collection"
    ],
    solutions: {
      "whatsapp": [
        "Instant booking confirmations with itinerary details",
        "Digital check-in and room preference collection",
        "Local recommendations and concierge services"
      ],
      "voice": [
        "Pre-arrival welcome calls and special requests",
        "Flight delay notifications and alternative arrangements",
        "Post-checkout feedback calls and loyalty offers"
      ],
      "campaigns": [
        "Seasonal travel packages and early bird discounts",
        "Loyalty program benefits and tier upgrades",
        "Destination-specific promotional campaigns"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Welcome! ✈️ Your booking at Ocean View Resort is confirmed! Check-in: June 15. Excited?",
        "response": "Yes!"
      },
      {
        "step": 2,
        "message":
            "Fantastic! 🌴 Pre-check-in questions: 1️⃣ Room preference? 2️⃣ Special occasions? 3️⃣ Dietary requirements?",
        "response": "Sea view, Anniversary"
      },
      {
        "step": 3,
        "message":
            "Perfect! We'll arrange a sea-view room with anniversary décor. 🎉 Any other special requests?"
      },
      {
        "step": 4,
        "message":
            "24 hours to your stay! Check-in after 2 PM. Resort address: [link]. Have a wonderful journey! 🏖️"
      }
    ],
    integrations: [
      "Property Management Systems",
      "Booking Engines",
      "Payment Gateways",
      "Review Platforms",
      "Channel Managers"
    ],
    results: [
      {"metric": "No-Show Rate", "value": "-45%"},
      {"metric": "Guest Satisfaction", "value": "+52%"},
      {"metric": "Review Collection", "value": "+60%"},
      {"metric": "Repeat Bookings", "value": "+35%"}
    ],
    color: _travelColor,
  ),

  // 7. NGO & Community Services
  Industry(
    id: "ngo-community",
    name: "NGO & Community Services",
    icon: LucideIcons.users,
    tagline: "Amplify Your Impact with Automated Outreach",
    description:
        "Manage donors, coordinate volunteers, and organize events with efficient, heartfelt communication.",
    challenges: [
      "Low donor retention and repeat contributions",
      "Difficulty coordinating volunteer schedules and events",
      "Limited resources for personalized communication"
    ],
    solutions: {
      "whatsapp": [
        "Automated donation receipts and tax certificates",
        "Volunteer shift reminders and event updates",
        "Impact stories and campaign progress updates"
      ],
      "voice": [
        "Personalized thank-you calls to donors",
        "Volunteer recruitment and onboarding calls",
        "Event reminder calls and attendance confirmations"
      ],
      "campaigns": [
        "Monthly impact reports to donor community",
        "Fundraising campaign launches with success stories",
        "Volunteer appreciation and recognition programs"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! 🤝 Thank you for your interest in our education program. Would you like to: 💰 Donate or 👋 Volunteer?",
        "response": "Donate"
      },
      {
        "step": 2,
        "message":
            "Wonderful! Your donation helps educate underprivileged children. Amount: 1️⃣ ₹500 2️⃣ ₹1000 3️⃣ Custom",
        "response": "2"
      },
      {
        "step": 3,
        "message":
            "Thank you! ₹1,000 can provide books for 5 children. 💳 Payment link: [link]. Complete donation?",
        "response": "Done"
      },
      {
        "step": 4,
        "message":
            "🙏 Thank you for your generosity! Your contribution will change lives. Tax receipt sent via email. Stay connected for updates! ❤️"
      }
    ],
    integrations: [
      "Donation Platforms",
      "Volunteer Management Systems",
      "Event Management Tools",
      "Email Marketing",
      "CRM Systems"
    ],
    results: [
      {"metric": "Donor Retention", "value": "+42%"},
      {"metric": "Volunteer Engagement", "value": "+55%"},
      {"metric": "Event Attendance", "value": "+38%"},
      {"metric": "Campaign Reach", "value": "+70%"}
    ],
    color: _ngoColor,
  ),

  // 8. Automobile & Service Centers
  Industry(
    id: "automobile",
    name: "Automobile & Service Centers",
    icon: LucideIcons.car,
    tagline: "Drive Customer Loyalty with Proactive Service",
    description:
        "Automate test drives, service reminders, and feedback collection for enhanced customer relationships.",
    challenges: [
      "Low test drive conversion rates due to poor follow-up",
      "Missed service appointments affecting revenue",
      "Limited customer engagement post-purchase"
    ],
    solutions: {
      "whatsapp": [
        "Test drive booking and confirmation with vehicle availability",
        "Service due reminders based on mileage and time",
        "AMC package renewals and exclusive offers"
      ],
      "voice": [
        "Post-test-drive follow-up calls for conversion",
        "Service appointment reminders and rescheduling",
        "Customer satisfaction surveys after service completion"
      ],
      "campaigns": [
        "New model launch events and exclusive previews",
        "Seasonal service camps and maintenance packages",
        "Loyalty program benefits and referral rewards"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hi! 🚗 Interested in test driving the new XUV700? Book your slot now! Reply YES."
      },
      {
        "step": 2,
        "message":
            "Great! Available slots: 1️⃣ Today 4 PM 2️⃣ Tomorrow 11 AM 3️⃣ Saturday 10 AM. Choose:",
        "response": "3"
      },
      {
        "step": 3,
        "message":
            "Booked! Saturday 10 AM at our showroom. Please bring your driving license. Excited to see you! 🏎️"
      },
      {
        "step": 4,
        "message":
            "Thanks for the test drive! 🌟 How was your experience? Would you like to: 📋 Check financing options or 💬 Speak to sales advisor?",
        "response": "Financing"
      }
    ],
    integrations: [
      "Dealership Management Systems",
      "Service Scheduling Software",
      "CRM Platforms",
      "Payment Gateways",
      "Inventory Management"
    ],
    results: [
      {"metric": "Test Drive Conversions", "value": "+30%"},
      {"metric": "Service Revenue", "value": "+45%"},
      {"metric": "Customer Retention", "value": "+40%"},
      {"metric": "NPS Score", "value": "+25 points"}
    ],
    color: _automobileColor,
  ),

  // 9. Manufacturing & Distribution
  Industry(
    id: "manufacturing",
    name: "Manufacturing & Distribution",
    icon: LucideIcons.factory,
    tagline: "Streamline B2B Communication and Order Processing",
    description:
        "Automate order forms, dealer communication, and inventory updates for efficient supply chain management.",
    challenges: [
      "Manual order processing causing delays and errors",
      "Poor communication with dealers and distributors",
      "Lack of real-time inventory visibility"
    ],
    solutions: {
      "whatsapp": [
        "Automated order confirmation and processing updates",
        "Real-time inventory availability and pricing updates",
        "Invoice and dispatch notification delivery"
      ],
      "voice": [
        "Automated order status update calls to dealers",
        "Payment follow-up calls for outstanding invoices",
        "New product launch announcement calls"
      ],
      "campaigns": [
        "Monthly dealer performance reports and incentives",
        "New product catalog launches with ordering options",
        "Seasonal demand forecasts and stock alerts"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! 📦 Welcome to our dealer portal. Need to place an order? Reply with product code."
      },
      {
        "step": 2,
        "message":
            "Product: Steel Rods - Grade A. Available: 500 units @ ₹450/unit. Quantity needed?",
        "response": "200"
      },
      {
        "step": 3,
        "message":
            "Order summary: 200 units = ₹90,000. Dispatch: 3-5 days. Confirm order?",
        "response": "Yes"
      },
      {
        "step": 4,
        "message":
            "Order confirmed! 🎉 Order ID: #MFG12345. You'll receive dispatch details soon. Invoice sent via email. Thank you!"
      }
    ],
    integrations: [
      "ERP Systems",
      "Inventory Management",
      "Order Management Systems",
      "Accounting Software",
      "Logistics Platforms"
    ],
    results: [
      {"metric": "Order Processing Time", "value": "-60%"},
      {"metric": "Order Accuracy", "value": "+50%"},
      {"metric": "Dealer Satisfaction", "value": "+45%"},
      {"metric": "Payment Collection", "value": "+35%"}
    ],
    color: _manufacturingColor,
  ),

  // 10. IT & SaaS Companies
  Industry(
    id: "it-saas",
    name: "IT & SaaS Companies",
    icon: LucideIcons.code,
    tagline: "Nurture Leads and Onboard Users with Intelligence",
    description:
        "Automate lead nurturing, support ticketing, and user onboarding for scalable customer success.",
    challenges: [
      "High lead volume but low trial-to-paid conversion",
      "Manual onboarding causing poor activation rates",
      "Support queries overwhelming small teams"
    ],
    solutions: {
      "whatsapp": [
        "Automated trial signup confirmations with quick start guides",
        "Feature tips and best practice tutorials during trial",
        "Upgrade prompts with personalized pricing offers"
      ],
      "voice": [
        "High-value lead qualification and demo scheduling calls",
        "Trial expiry reminder calls with conversion offers",
        "Customer success check-in calls for enterprise clients"
      ],
      "campaigns": [
        "Product update announcements and new feature launches",
        "Webinar invitations for user education and engagement",
        "Referral program promotions and rewards"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Welcome to CloudFlow! 🚀 Your free trial is active. Need help getting started?",
        "response": "Yes"
      },
      {
        "step": 2,
        "message":
            "Great! Quick start: 1️⃣ Connect your data 2️⃣ Create workflow 3️⃣ Deploy automation. Which first?",
        "response": "1"
      },
      {
        "step": 3,
        "message":
            "Perfect! Click here to connect: [link]. Video tutorial: [link]. Need a demo call?",
        "response": "No, thanks"
      },
      {
        "step": 4,
        "message":
            "Awesome progress! 🎉 You've created 3 workflows. Your trial ends in 5 days. Ready to upgrade? Special offer inside! 💎"
      }
    ],
    integrations: [
      "CRM Systems",
      "Support Ticketing Platforms",
      "Analytics Tools",
      "Payment Gateways",
      "Product Analytics"
    ],
    results: [
      {"metric": "Trial Activation Rate", "value": "+55%"},
      {"metric": "Trial-to-Paid Conversion", "value": "+38%"},
      {"metric": "Support Response Time", "value": "-70%"},
      {"metric": "User Engagement", "value": "+60%"}
    ],
    color: _itSaasColor,
  ),

  // 11. Events & Entertainment
  Industry(
    id: "events-entertainment",
    name: "Events & Entertainment",
    icon: LucideIcons.calendar,
    tagline: "Create Unforgettable Experiences with Seamless Communication",
    description:
        "Automate ticketing, RSVPs, campaign outreach, and feedback for successful event management.",
    challenges: [
      "Low RSVP and attendance rates for events",
      "Manual ticketing and registration processes",
      "Poor post-event engagement and feedback collection"
    ],
    solutions: {
      "whatsapp": [
        "Instant ticket confirmations with QR codes and event details",
        "Event reminders with venue maps and parking information",
        "Live event updates and schedule changes"
      ],
      "voice": [
        "RSVP confirmation calls for exclusive events",
        "Last-minute seat availability announcement calls",
        "Post-event feedback and future event promotion calls"
      ],
      "campaigns": [
        "Early bird ticket offers and group discounts",
        "Artist announcements and event teaser campaigns",
        "VIP package promotions and exclusive experiences"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "🎭 Comedy Night with Kumar! 🎤 April 20, 7 PM. Tickets selling fast! Interested?",
        "response": "Yes!"
      },
      {
        "step": 2,
        "message":
            "Awesome! Tickets: 1️⃣ Silver ₹499 2️⃣ Gold ₹799 3️⃣ Platinum ₹1,299. Choose:",
        "response": "2"
      },
      {
        "step": 3,
        "message": "Gold ticket selected! Quantity?",
        "response": "2"
      },
      {
        "step": 4,
        "message":
            "Total: ₹1,598 for 2 Gold tickets. Payment link: [link]. Complete booking now! ⚡"
      },
      {
        "step": 5,
        "message":
            "🎉 Booking confirmed! E-tickets sent. Event: April 20, 7 PM. Show this at entry. See you there! 🎊"
      }
    ],
    integrations: [
      "Ticketing Platforms",
      "Event Management Software",
      "Payment Gateways",
      "Email Marketing",
      "CRM Systems"
    ],
    results: [
      {"metric": "Ticket Sales", "value": "+48%"},
      {"metric": "Event Attendance", "value": "+35%"},
      {"metric": "Last-Minute Bookings", "value": "+52%"},
      {"metric": "Repeat Attendees", "value": "+40%"}
    ],
    color: _eventsColor,
  ),

  // 12. Government & Public Services
  Industry(
    id: "government-public",
    name: "Government & Public Services",
    icon: LucideIcons.building,
    tagline: "Empower Citizens with Transparent, Accessible Services",
    description:
        "Automate citizen queries, grievance handling, and service notifications for responsive governance.",
    challenges: [
      "High volume of citizen queries overwhelming helplines",
      "Delayed grievance resolution affecting public trust",
      "Limited reach for important government announcements"
    ],
    solutions: {
      "whatsapp": [
        "Automated responses to common queries (certificates, schemes)",
        "Grievance ticket creation and status tracking",
        "Benefit scheme eligibility checks and application guidance"
      ],
      "voice": [
        "Multi-language support for citizen helplines",
        "Appointment reminders for government services",
        "Emergency alerts and disaster management notifications"
      ],
      "campaigns": [
        "New scheme launches and enrollment drives",
        "Awareness campaigns for citizen welfare programs",
        "Voter registration and election reminders"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Welcome to Citizen Services! 🏛️ How can we help? 1️⃣ Birth Certificate 2️⃣ Property Tax 3️⃣ File Complaint",
        "response": "1"
      },
      {
        "step": 2,
        "message":
            "Birth Certificate application: Required docs: 1️⃣ Hospital certificate 2️⃣ Parents' ID. Ready to apply?",
        "response": "Yes"
      },
      {
        "step": 3,
        "message":
            "Upload documents here: [link]. Application fee: ₹50. You'll receive certificate in 7 days. 📄"
      },
      {
        "step": 4,
        "message":
            "Application received! ✅ Application ID: BC12345. Track status: [link]. Thank you for using our service! 🙏"
      }
    ],
    integrations: [
      "Citizen Portal Systems",
      "Grievance Management Platforms",
      "Document Verification Systems",
      "Payment Gateways",
      "SMS Gateways"
    ],
    results: [
      {"metric": "Query Resolution Time", "value": "-65%"},
      {"metric": "Citizen Satisfaction", "value": "+50%"},
      {"metric": "Service Accessibility", "value": "+75%"},
      {"metric": "Grievance Resolution", "value": "+45%"}
    ],
    color: _governmentColor,
  ),

  // 13. Logistics & Supply Chain
  Industry(
    id: "logistics-supply",
    name: "Logistics & Supply Chain",
    icon: LucideIcons.truck,
    tagline: "Deliver Transparency from Pickup to Doorstep",
    description:
        "Automate pickup scheduling, tracking updates, and delivery alerts for seamless logistics operations.",
    challenges: [
      "Poor shipment visibility causing customer anxiety",
      "Failed deliveries due to unavailability",
      "Manual coordination of pickup and delivery schedules"
    ],
    solutions: {
      "whatsapp": [
        "Real-time shipment tracking with live location updates",
        "Automated delivery slot confirmation with customers",
        "POD (Proof of Delivery) sharing and digital signatures"
      ],
      "voice": [
        "Pickup scheduling confirmation calls",
        "Pre-delivery calls to confirm availability",
        "Failed delivery follow-up and rescheduling calls"
      ],
      "campaigns": [
        "Service area expansion announcements",
        "Festive season shipping deadline reminders",
        "Express delivery service promotions"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Your shipment #LOG56789 is out for delivery! 📦 Expected by 5 PM today. Track: [link]"
      },
      {
        "step": 2,
        "message":
            "Delivery partner is 3 stops away! 🚚 Will you be available to receive?",
        "response": "Yes"
      },
      {
        "step": 3,
        "message":
            "Perfect! Your package will arrive in 15-20 minutes. Please keep your phone handy. 📱"
      },
      {
        "step": 4,
        "message":
            "Package delivered successfully! ✅ Please rate your experience: ⭐⭐⭐⭐⭐. Thank you for choosing us! 🙏"
      }
    ],
    integrations: [
      "Shipping Management Systems",
      "GPS Tracking",
      "Route Optimization Tools",
      "Payment Gateways",
      "CRM Systems"
    ],
    results: [
      {"metric": "Failed Deliveries", "value": "-55%"},
      {"metric": "Customer Inquiries", "value": "-70%"},
      {"metric": "Delivery Efficiency", "value": "+40%"},
      {"metric": "Customer Satisfaction", "value": "+48%"}
    ],
    color: _logisticsColor,
  ),

  // 14. Beauty, Fitness & Lifestyle
  Industry(
    id: "beauty-fitness",
    name: "Beauty, Fitness & Lifestyle",
    icon: LucideIcons.dumbbell,
    tagline: "Build Lasting Relationships Through Personalized Engagement",
    description:
        "Automate appointments, membership renewals, and feedback collection for wellness businesses.",
    challenges: [
      "High no-show rates for appointments impacting revenue",
      "Manual membership renewal follow-ups causing lapses",
      "Low customer retention and repeat visits"
    ],
    solutions: {
      "whatsapp": [
        "Automated appointment booking with service selection",
        "Membership expiry reminders with easy renewal links",
        "Post-service feedback and personalized recommendations"
      ],
      "voice": [
        "Appointment reminder calls 24 hours in advance",
        "Birthday wishes with exclusive offers",
        "Inactive member re-engagement calls with promotions"
      ],
      "campaigns": [
        "Seasonal packages and festive special offers",
        "New service launches and expert introduction",
        "Referral program promotions with rewards"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hi! 💆‍♀️ Ready to book your next spa session? Reply YES for available slots."
      },
      {
        "step": 2,
        "message":
            "Available services: 1️⃣ Swedish Massage 2️⃣ Aromatherapy 3️⃣ Deep Tissue. Choose:",
        "response": "1"
      },
      {
        "step": 3,
        "message":
            "Swedish Massage - 60 mins ₹1,500. Available: 1️⃣ Today 3 PM 2️⃣ Tomorrow 11 AM. Pick slot:",
        "response": "2"
      },
      {
        "step": 4,
        "message":
            "Booked! 🎉 Tomorrow 11 AM. Therapist: Sarah. We'll send reminder. Looking forward to pampering you! ✨"
      }
    ],
    integrations: [
      "Salon/Spa Management Software",
      "Membership Management",
      "Payment Gateways",
      "Feedback Platforms",
      "Marketing Automation"
    ],
    results: [
      {"metric": "No-Show Rate", "value": "-50%"},
      {"metric": "Membership Renewals", "value": "+45%"},
      {"metric": "Customer Retention", "value": "+40%"},
      {"metric": "Revenue per Customer", "value": "+35%"}
    ],
    color: _fitnessColor,
  ),

  // 15. Education Institutions (Schools)
  Industry(
    id: "education-institutions",
    name: "Education Institutions",
    icon: LucideIcons.school,
    tagline: "Strengthen School-Parent Communication at Scale",
    description:
        "Automate enquiry handling, parent communication, and administrative notifications for schools and universities.",
    challenges: [
      "Overwhelming admission inquiries during peak season",
      "Poor parent engagement in student activities",
      "Time-consuming administrative announcements"
    ],
    solutions: {
      "whatsapp": [
        "Automated admission inquiry responses with brochure sharing",
        "Daily homework and assignment notifications",
        "Event invitations and permission slip collection"
      ],
      "voice": [
        "Admission counseling and campus tour scheduling calls",
        "Absentee notification calls to parents",
        "Parent-teacher meeting reminders and confirmations"
      ],
      "campaigns": [
        "New academic year enrollment campaigns",
        "School event announcements and achievement highlights",
        "Alumni engagement and reunion notifications"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Welcome to Greenwood School! 🎓 Interested in admission for 2025-26? Reply YES."
      },
      {
        "step": 2,
        "message":
            "Great! We offer: 1️⃣ Primary (1-5) 2️⃣ Middle (6-8) 3️⃣ High School (9-12). Which grade?",
        "response": "1"
      },
      {
        "step": 3,
        "message":
            "Perfect! Primary admission open. Schedule campus tour? 1️⃣ This Saturday 2️⃣ Next Sunday",
        "response": "1"
      },
      {
        "step": 4,
        "message":
            "Campus tour booked for Saturday 10 AM! 🏫 Bring your child along. Address: [link]. See you soon! 📚"
      }
    ],
    integrations: [
      "Student Information Systems",
      "Learning Management Systems",
      "Payment Gateways",
      "Parent Portal",
      "Attendance Systems"
    ],
    results: [
      {"metric": "Inquiry Response Time", "value": "-80%"},
      {"metric": "Parent Engagement", "value": "+55%"},
      {"metric": "Admission Conversion", "value": "+32%"},
      {"metric": "Administrative Time", "value": "-60%"}
    ],
    color: _schoolColor,
  ),

  // 16. Legal & Consulting Firms
  Industry(
    id: "legal-consulting",
    name: "Legal & Consulting Firms",
    icon: LucideIcons.scale,
    tagline: "Professionalize Client Communication and Document Management",
    description:
        "Automate appointment scheduling, document sharing, and client updates for professional services.",
    challenges: [
      "Manual appointment scheduling consuming billable hours",
      "Delayed client updates affecting satisfaction",
      "Inefficient document sharing and signature collection"
    ],
    solutions: {
      "whatsapp": [
        "Automated consultation booking with lawyer availability",
        "Secure document sharing and digital signature collection",
        "Case status updates and hearing reminders"
      ],
      "voice": [
        "Consultation reminder calls with preparation guidelines",
        "New client onboarding and requirement collection calls",
        "Follow-up calls for pending documentation"
      ],
      "campaigns": [
        "Legal awareness webinars and workshops",
        "New service area announcements (tax, IP, corporate)",
        "Seasonal advisory campaigns (tax planning, compliance)"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! ⚖️ Need legal consultation? Book appointment with our specialists. Reply YES."
      },
      {
        "step": 2,
        "message":
            "Practice areas: 1️⃣ Corporate Law 2️⃣ Family Law 3️⃣ Property Law 4️⃣ Tax. Choose:",
        "response": "1"
      },
      {
        "step": 3,
        "message":
            "Corporate Law - Senior Partner available. 1️⃣ Thu 2 PM 2️⃣ Fri 4 PM. Select slot:",
        "response": "1"
      },
      {
        "step": 4,
        "message":
            "Confirmed! 📅 Thursday 2 PM. Office address: [link]. Please bring relevant documents. See you! 💼"
      }
    ],
    integrations: [
      "Case Management Software",
      "Document Management Systems",
      "Billing Software",
      "Digital Signature Platforms",
      "CRM Systems"
    ],
    results: [
      {"metric": "Scheduling Time", "value": "-75%"},
      {"metric": "Client Satisfaction", "value": "+42%"},
      {"metric": "Document Processing", "value": "-60%"},
      {"metric": "Billable Hours", "value": "+25%"}
    ],
    color: _legalColor,
  ),

  // 17. Hospitality & Restaurants
  Industry(
    id: "hospitality-restaurants",
    name: "Hospitality & Restaurants",
    icon: LucideIcons.utensilsCrossed,
    tagline: "Serve Excellence from Reservation to Review",
    description:
        "Automate table bookings, menu requests, and feedback collection for exceptional dining experiences.",
    challenges: [
      "High no-show rates for table reservations",
      "Manual order taking during peak hours causing delays",
      "Low online review collection affecting reputation"
    ],
    solutions: {
      "whatsapp": [
        "Instant table reservation with availability checking",
        "Digital menu sharing and pre-ordering options",
        "Special occasion setup requests (birthdays, anniversaries)"
      ],
      "voice": [
        "Reservation confirmation calls with special requests",
        "Pre-arrival calls for large group bookings",
        "Post-dining feedback calls and promotion sharing"
      ],
      "campaigns": [
        "New menu launches and chef's special promotions",
        "Festival and holiday reservation reminders",
        "Loyalty program benefits and exclusive events"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Welcome to Spice Garden! 🍽️ Book a table for today? Reply YES."
      },
      {
        "step": 2,
        "message":
            "Great! Party size and preferred time? (e.g., 4 people, 8 PM)",
        "response": "4 people, 8 PM"
      },
      {
        "step": 3,
        "message":
            "Perfect! Table for 4 at 8 PM. 1️⃣ Indoor AC 2️⃣ Rooftop. Preference?",
        "response": "2"
      },
      {
        "step": 4,
        "message":
            "Rooftop table confirmed! ✨ Reservation ID: RES789. Address: [link]. See you at 8 PM! 🌟"
      }
    ],
    integrations: [
      "Restaurant Management Systems",
      "POS Systems",
      "Delivery Platforms",
      "Review Management",
      "Inventory Management"
    ],
    results: [
      {"metric": "No-Show Rate", "value": "-45%"},
      {"metric": "Table Turnover", "value": "+30%"},
      {"metric": "Online Reviews", "value": "+55%"},
      {"metric": "Repeat Customers", "value": "+40%"}
    ],
    color: _restaurantColor,
  ),

  // 18. Telecom & Utilities
  Industry(
    id: "telecom-utilities",
    name: "Telecom & Utilities",
    icon: LucideIcons.phone,
    tagline: "Resolve Issues Faster with Proactive Communication",
    description:
        "Automate complaint handling, bill payments, and service alerts for utility providers.",
    challenges: [
      "High call volumes overwhelming customer service centers",
      "Delayed bill payment reminders causing revenue loss",
      "Poor communication during service outages"
    ],
    solutions: {
      "whatsapp": [
        "Automated complaint registration and ticket tracking",
        "Bill notifications with payment links and usage details",
        "Service outage alerts and restoration updates"
      ],
      "voice": [
        "Overdue payment reminder calls with easy payment options",
        "New connection activation confirmation calls",
        "Service satisfaction surveys post resolution"
      ],
      "campaigns": [
        "New plan launches and upgrade opportunities",
        "Seasonal recharge offers and cashback promotions",
        "Digital payment adoption campaigns"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! 📱 Your bill of ₹699 is due on June 30. Pay now to avoid disconnection. Reply PAY."
      },
      {
        "step": 2,
        "message": "Payment options: 1️⃣ UPI 2️⃣ Card 3️⃣ Net Banking. Choose:",
        "response": "1"
      },
      {
        "step": 3,
        "message":
            "UPI payment link: [link]. Amount: ₹699. Complete payment now. ⚡"
      },
      {
        "step": 4,
        "message":
            "Payment received! ✅ Thank you! New recharge valid till July 30. Need help? Reply HELP anytime. 🙏"
      }
    ],
    integrations: [
      "Billing Systems",
      "CRM Platforms",
      "Payment Gateways",
      "Network Management Systems",
      "Support Ticketing"
    ],
    results: [
      {"metric": "Call Center Load", "value": "-60%"},
      {"metric": "Payment Collection", "value": "+48%"},
      {"metric": "Complaint Resolution", "value": "-50% time"},
      {"metric": "Customer Satisfaction", "value": "+45%"}
    ],
    color: _telecomColor,
  ),

  // 19. Construction & Interior Design
  Industry(
    id: "construction-interior",
    name: "Construction & Interior Design",
    icon: LucideIcons.hardHat,
    tagline: "Build Trust Through Transparent Project Communication",
    description:
        "Automate site visit scheduling, quotation sharing, and project updates for construction businesses.",
    challenges: [
      "Poor client communication during project execution",
      "Manual quotation processes causing delays",
      "Difficulty in coordinating site visits with multiple stakeholders"
    ],
    solutions: {
      "whatsapp": [
        "Automated quotation sharing with cost breakdowns",
        "Daily project progress updates with photos",
        "Material approval requests and feedback collection"
      ],
      "voice": [
        "Site visit scheduling and confirmation calls",
        "Payment milestone reminder calls",
        "Project completion and handover coordination calls"
      ],
      "campaigns": [
        "Portfolio showcases and completed project highlights",
        "Seasonal offers on interior design packages",
        "Client testimonials and referral program promotions"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hi! 🏗️ Interested in interior design for your 3BHK? Get free consultation! Reply YES."
      },
      {
        "step": 2,
        "message":
            "Awesome! When would you like our designer to visit? 1️⃣ This weekend 2️⃣ Next week",
        "response": "1"
      },
      {
        "step": 3,
        "message": "Perfect! Saturday or Sunday? Morning or evening?",
        "response": "Saturday morning"
      },
      {
        "step": 4,
        "message":
            "Site visit scheduled! 📅 Saturday 10 AM. Our designer will bring portfolio and samples. Address please?"
      }
    ],
    integrations: [
      "Project Management Software",
      "CAD Tools",
      "Payment Gateways",
      "Supplier Management",
      "CRM Systems"
    ],
    results: [
      {"metric": "Client Communication", "value": "+65%"},
      {"metric": "Project Delays", "value": "-40%"},
      {"metric": "Payment Collection", "value": "+50%"},
      {"metric": "Referrals", "value": "+45%"}
    ],
    color: _constructionColor,
  ),

  // 20. Professional Services (CA/HR/Training)
  Industry(
    id: "professional-services",
    name: "Professional Services (CA/HR/Training)",
    icon: LucideIcons.briefcase,
    tagline: "Scale Your Practice with Automated Client Management",
    description:
        "Automate onboarding, consultation scheduling, and form collection for CAs, HR firms, and training providers.",
    challenges: [
      "High volume of client inquiries during compliance seasons",
      "Manual document collection causing processing delays",
      "Difficulty in coordinating training schedules with attendees"
    ],
    solutions: {
      "whatsapp": [
        "Automated service inquiry responses with pricing",
        "Document checklist sharing and collection tracking",
        "Training session reminders and material sharing"
      ],
      "voice": [
        "Consultation appointment confirmation calls",
        "Compliance deadline reminder calls to clients",
        "Post-service feedback and referral request calls"
      ],
      "campaigns": [
        "Tax season preparation reminders and checklist",
        "New course launches and early bird discounts",
        "Compliance update webinars and workshops"
      ]
    },
    conversationFlow: [
      {
        "step": 1,
        "message":
            "Hello! 💼 Need help with ITR filing? Our CA can assist. Reply YES for details."
      },
      {
        "step": 2,
        "message":
            "Great! ITR filing package: ₹999 (Salary) | ₹2,499 (Business). Which applies to you?",
        "response": "Salary"
      },
      {
        "step": 3,
        "message":
            "Perfect! Documents needed: 1️⃣ Form 16 2️⃣ Bank statements 3️⃣ Investment proofs. Ready to share?",
        "response": "Yes"
      },
      {
        "step": 4,
        "message":
            "Upload here: [secure link]. Processing time: 2-3 days. You'll receive filed ITR acknowledgment. Let's get started! 📊"
      }
    ],
    integrations: [
      "Practice Management Software",
      "Document Management",
      "Payment Gateways",
      "E-filing Portals",
      "Learning Management Systems"
    ],
    results: [
      {"metric": "Client Onboarding Time", "value": "-70%"},
      {"metric": "Document Collection", "value": "-60% time"},
      {"metric": "Client Satisfaction", "value": "+50%"},
      {"metric": "Service Capacity", "value": "+45%"}
    ],
    color: _professionalColor,
  ),
];
