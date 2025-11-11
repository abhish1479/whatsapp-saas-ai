import json
import re
import logging
from typing import Any, Dict, Optional

class LLMJsonParser:
    """
    Safely parse JSON returned from LLM responses.

    Handles:
      - Extra text before/after JSON
      - Markdown code fences (```json ... ```)
      - Common JSON formatting issues
    """

    def __init__(self, strict: bool = False):
        """
        Args:
            strict (bool): If True, require that parsed JSON contains
                           both 'summary' and 'document' keys.
        """
        self.strict = strict
        self.logger = logging.getLogger(self.__class__.__name__)

    def parse(self, response_text: str) -> Optional[Dict[str, Any]]:
        """Main entrypoint for parsing."""
        if not response_text:
            self.logger.warning("Empty LLM response received.")
            return None

        cleaned = self._clean_text(response_text)
        json_str = self._extract_json(cleaned)

        if not json_str:
            self.logger.error("No valid JSON structure found in LLM output.")
            return None

        return self._parse_json(json_str)

    def _clean_text(self, text: str) -> str:
        """Remove code fences, trim whitespace."""
        cleaned = text.strip()
        cleaned = re.sub(r"^```json|```$", "", cleaned, flags=re.MULTILINE).strip()
        cleaned = re.sub(r"^```|```$", "", cleaned, flags=re.MULTILINE).strip()
        return cleaned

    def _extract_json(self, text: str) -> Optional[str]:
        """
        Extract the first JSON object from a messy string.
        Supports cases where text contains other content around JSON.
        """
        match = re.search(r"\{[\s\S]*\}", text)
        if match:
            return match.group(0)
        return None

    def _parse_json(self, json_str: str) -> Optional[Dict[str, Any]]:
        """Attempt to parse the JSON string and validate structure."""
        try:
            data = json.loads(json_str)

            if self.strict:
                if not isinstance(data, dict):
                    raise ValueError("Parsed JSON is not a dictionary.")
                if "summary" not in data or "document" not in data:
                    raise ValueError("Missing required keys: 'summary' or 'document'.")

            return data

        except json.JSONDecodeError as e:
            self.logger.error(f"Failed to parse JSON: {e}")
            return None
        except Exception as e:
            self.logger.error(f"Unexpected parsing error: {e}")
            return None
