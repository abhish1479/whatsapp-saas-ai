import re
import json
from datetime import datetime

# ==========================================
# 1. SPECIFIC VALIDATION LOGIC (The Workers)
# ==========================================

def _validate_email(value: str):
    # Standard email regex
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    if re.match(pattern, value):
        return True, "Valid email"
    return False, "Invalid email format (example: name@domain.com)"

def _validate_phone(value: str):
    # Removes spaces, dashes, parentheses to check raw digits
    clean_number = re.sub(r'\D', '', value) 
    # Example: Check for standard 10-digit number
    if len(clean_number) == 10:
        return True, "Valid 10-digit phone number"
    if len(clean_number) > 10:
         return False, f"Number is too long ({len(clean_number)} digits). Expecting 10."
    return False, f"Number is too short ({len(clean_number)} digits). Expecting 10."

def _validate_pincode(value: str):
    # checks for exactly 6 digits (India standard)
    if re.match(r"^\d{6}$", value):
        return True, "Valid pincode"
    return False, "Pincode must be exactly 6 digits"

def _validate_url(value: str):
    pattern = r"^(http|https)://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
    if re.match(pattern, value):
        return True, "Valid URL"
    return False, "URL must start with http:// or https://"

def _validate_date(value: str):
    # Expects YYYY-MM-DD
    try:
        datetime.strptime(value, '%Y-%m-%d')
        return True, "Valid date"
    except ValueError:
        return False, "Date must be in YYYY-MM-DD format"

def _validate_pan(value: str):
    # Indian PAN Card Regex: 5 letters, 4 digits, 1 letter
    pattern = r"^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
    if re.match(pattern, value.upper()):
        return True, "Valid PAN"
    return False, "Invalid PAN format (Example: ABCDE1234F)"

# ==========================================
# 2. THE REGISTRY (The Brain)
# ==========================================

VALIDATION_REGISTRY = {
    "EMAIL": _validate_email,
    "PHONE": _validate_phone,
    "PINCODE": _validate_pincode,
    "URL": _validate_url,
    "DATE": _validate_date,
    "PAN_CARD": _validate_pan
}

# ==========================================
# 3. THE MASTER TOOL (The Gateway)
# ==========================================

def universal_validator(items_json: str):
    """
    The single entry point for the LLM.
    Args:
        items_json (str): A JSON string containing a list of items to validate.
                          Structure: [{"value": "...", "type": "..."}]
    """
    try:
        # Parse input from LLM
        items = json.loads(items_json)
        
        # If LLM sends a single object instead of a list, handle it gracefully
        if isinstance(items, dict): 
            items = [items]

        results = []
        
        for item in items:
            data_value = item.get("value", "")
            data_type = item.get("type", "").upper()
            
            # 1. Check if we have a validator for this type
            if data_type in VALIDATION_REGISTRY:
                validator_func = VALIDATION_REGISTRY[data_type]
                is_valid, message = validator_func(data_value)
                
                results.append({
                    "value": data_value,
                    "type": data_type,
                    "status": "valid" if is_valid else "invalid",
                    "message": message
                })
            else:
                # Fallback for unknown types
                results.append({
                    "value": data_value,
                    "type": data_type,
                    "status": "error",
                    "message": f"Unknown validation type: {data_type}. Supported: {list(VALIDATION_REGISTRY.keys())}"
                })
                
        return json.dumps({"validation_report": results}, indent=2)

    except json.JSONDecodeError:
        return json.dumps({"error": "Failed to decode JSON arguments."})
    except Exception as e:
        return json.dumps({"error": f"Internal Tool Error: {str(e)}"})

# --- TESTING THE TOOL LOCALLY ---
# if __name__ == "__main__":
#     # Simulate LLM sending a batch of data
#     llm_payload = json.dumps([
#         {"value": "john@gmail.com", "type": "EMAIL"},       # Valid
#         {"value": "98765", "type": "PINCODE"},              # Invalid (5 digits)
#         {"value": "ABCDE1234F", "type": "PAN_CARD"},        # Valid
#         {"value": "call-me-maybe", "type": "PHONE"}         # Invalid
#     ])

#     print("--- Simulating Agent Call ---")
#     print(universal_validator(llm_payload))