# Tool definition for OpenAI function-calling / tools
from datetime import datetime
formatted_current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z")


get_all_tickets_tool = {
    "type": "function",
    "function": {
        "name": "get_all_tickets",
        "description": (
            "Fetch all tickets for a user automatically using their WhatsApp mobile number. "
            "Do NOT ask the user for their phone number. "
            "Show only the last 3 ticket details and a summary grouped by TicketStatus.\n\n"
            "Formatted in readable text with new lines."
            "When to call this tool:\n"
            "1. If the user asks for ticket status but llm can not found ticket ID in chat history or does not provide any ticket ID.\n"
            "2. If the user provides a ticket ID, but no status is found for that ticket.\n"
            "3. Essentially, call this tool whenever the system cannot fetch a ticket by ID."
        ),
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    }
}

get_ticket_status_tool = {
    "type": "function",
    "function": {
        "name": "get_ticket_status",
        "description": (
            "Fetch current status of a ticket by ticket_id. "
            "Phone number is read from the WhatsApp sender automatically; "
            "do NOT ask the user for phone number."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "ticket_id": {"type": "string", "description": "e.g. 383UP2507160659,T3830000000677(do not include these tickets)"},
            },
            "required": ["ticket_id"]
        }
    }
}

create_ticket_tool = {
    "type": "function",
    "function": {
        "name": "create_ticket",
        "description": (
            # --- Main instruction to the LLM ---
            "Use this tool to create a new service ticket. "
            "First, politely ask the user for the following details in a clear, user-friendly format, "
            "using icons (emojis) and listing each item on a new line. "
            "Do not just list the technical field names. "
            "Example format to ask:\n"
            " 📝 To create your service ticket, I need a few details:\n"
            "1️⃣ Your full name?\n"
            "2️⃣ Your complete address (including house number, street, area)?\n"
            "3️⃣ Your area's pincode?\n"
            "4️⃣ Your preferred appointment date and time (e.g., 'tomorrow 4 PM' or '2025-09-25 15:00')?\n"
            "5️⃣ The product category needing service (e.g., 'Air Conditioner', 'Refrigerator')?\n"
            "(Optional) Model number if you have it?\n"
            # --- Standard operational details ---
            "Infer the phone number from the WhatsApp sender. "
            f"The current date and time in India (IST) is {formatted_current_time}. "
            "Use JobType from enum ['Service','Installation','Demo'] (default 'Service'). "
            "All other fields are hardcoded."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "CustomerName": {"type": "string"},
                "AddressLine": {"type": "string"},
                "Pincode": {"type": "string"},
                "AppointmentStartTime": {
                    "type": "string",
                    "description": (
                        "Preferred appointment start date and time. "
                        f"The current date and time in India (IST) is {formatted_current_time}. "
                        "Acceptable formats include ISO 8601 (e.g., '2025-07-21T16:00:00'), "
                        "or relative times (e.g., 'tomorrow 4 PM', 'next Monday 10 AM', 'today at 3 PM'). "
                        "Convert colloquial phrases like 'kal saam 4 baje' to a standard format if possible (e.g., 'tomorrow 4 PM')."
                        "Always try to get a specific date and time."
                    )
                },
                "ProductCategory": {"type": "string"},
                "ModelNumber": {"type": "string", "nullable": True},
                "JobType": {
                    "type": "string",
                    "enum": ["Service", "Installation", "Demo"],
                    "description": "If user doesn't specify, default to 'Service'."
                }
            },
            "required": [
                "CustomerName", "AddressLine", "Pincode",
                "AppointmentStartTime", "ProductCategory"
            ]
        }
    }
}


TOOLS = [get_ticket_status_tool,create_ticket_tool,get_all_tickets_tool]
