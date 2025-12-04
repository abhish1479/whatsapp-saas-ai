import asyncio
import base64
from services.llm import analysis
from utils.file_extractor import FileExtractor
from utils.json_parser import LLMJsonParser
from utils.web_crawler import scrape_single_page
# from utils.log import append_usage

async def analyze_file_from_bytes(tenant_id :int,file_name:str,file_bytes: bytes, ) -> str:
    
    file_txt = FileExtractor.extract_text(file_bytes, file_name)
    if file_txt.strip() == "":
        return "No extractable text found in the file."
    FILE_PROMPT = """ You are an intelligent document refinement assistant.

                        Your task:
                        You will receive raw text extracted from a file. The text may contain formatting noise, incomplete sentences, or missing context.

                        Your goals:
                        1. **Refine the text** — clean, structure, and rewrite it in clear, coherent language while preserving the original meaning. You may add minimal factual or contextual details only if necessary for clarity or completeness.
                        2. **Segment the text** into meaningful chunks or sections (for example: per paragraph, logical idea, or topic boundary). Each chunk must stand alone semantically.Also inlcude fee ,prices or URL if any.
                        3. **Assign concise metadata** to each chunk, including relevant fields such as:
                        - `title` (if identifiable)
                        - `section` or `topic`
                        - `page_number` or `order`
                        - `keywords` (3–7 short keywords comma-separated)
                        - `language` (ISO code, e.g., "en")
                        - `source_type` (e.g., "pdf", "docx", "text")
                        - Any additional relevant contextual tags.

                        4. **Generate a detailed but concise summary** of the entire document.  
                        - Capture key ideas, themes, and purpose.  
                        - Be precise and informative — not a simple abstract or bullet list.  
                        - Focus on meaning, not formatting.
                        5.Gernerate tags (2-3) that best describe the content of the document.

                        **Important rules:**
                        - Do NOT include irrelevant or unrelated information.
                        - Do NOT add external knowledge beyond what supports refinement or understanding.
                        - Return your response strictly in JSON format.

                        **Output JSON structure (mandatory):**

                        ```json
                        {
                        "summary": "Detailed and concise document summary.",
                        "tags": ["tag1", "tag2", "tag3"],
                        "document": [
                            {
                            "id": "{file_name}+uuid",
                            "text": "Refined text chunk.",
                            "metadata": {
                                "title": "...",
                                "section": "...",
                                "page_number": 1,
                                "keywords": "...",
                                "language": "en",
                                "source_type": "pdf"
                            }
                            }
                        ]
                        }
                        """

    response = await analysis(tenant_id,file_txt.strip(),FILE_PROMPT)
    
    print(f"LLM response: {response[:200]}...")  # Print the first 500 characters of the response for debugging
    parser = LLMJsonParser(strict=True)
    parsed_output = parser.parse(response)
    print(f"parsed_output: {parsed_output}") # Print the parsed output for debugging
    return parsed_output



async def analyze_Web(tenant_id :int,source_url:str, ) -> str:
    
    file_txt =await scrape_single_page(source_url)
    if file_txt.strip() == "":
        return "No extractable text found in the file."
    FILE_PROMPT = """ You are an intelligent document refinement assistant.

                        Your task:
                        You will receive raw text extracted from a web. The text may contain formatting noise, incomplete sentences, or missing context.

                        Your goals:
                        1. **Refine the text** — clean, structure, and rewrite it in clear, coherent language while preserving the original meaning. You may add minimal factual or contextual details only if necessary for clarity or completeness.
                        2. **Segment the text** into meaningful chunks or sections (for example: per paragraph, logical idea,topic boundary). Each chunk must stand alone semantically.
                        3. **If a text contains pricing , fees, duration, location, or URL, **it must be preserved and highlighted in that chunk.**
                        4. **Assign concise metadata** to each chunk, including relevant fields such as:
                        - `title` (if identifiable)
                        - `section` or `topic`
                        - `page` or `order`
                        - `keywords` (3–7 short keywords comma-separated)
                        - `language` (ISO code, e.g., "en")
                        - `source_type` (e.g., "pdf", "docx", "text")
                        - Any additional relevant contextual tags.

                        4. **Generate a detailed but concise summary** of the entire document.  
                        - Capture key ideas, themes, and purpose.  
                        - Be precise and informative — not a simple abstract or bullet list.  
                        - Focus on meaning, not formatting.
                        5.Gernerate tags (2-3) that best describe the content of the document.

                        **Important rules:**
                        - Do NOT include irrelevant or unrelated information.
                        - Do NOT add external knowledge beyond what supports refinement or understanding.
                        - Return your response strictly in JSON format.

                        **Output JSON structure (mandatory):**

                        ```json
                        {
                        "summary": "Detailed and concise document summary.",
                        "tags": ["tag1", "tag2", "tag3"],
                        "document": [
                            {
                            "id": "{source_url}+uuid",
                            "text": "Refined text chunk.",
                            "metadata": {
                                "title": "...",
                                "section": "...",
                                "page": "...",
                                "keywords": "...",
                                "language": "en",
                                "source_type": "web"
                            }
                            }
                        ]
                        }
                        """

    print(f"Extracted text : {file_txt.strip()}")  # Debugging line to check extracted text length
    response = await analysis(tenant_id,file_txt.strip(),FILE_PROMPT)
    
    print(f"LLM response: {response[:200]}...")  # Print the first 500 characters of the response for debugging
    parser = LLMJsonParser(strict=True)
    parsed_output = parser.parse(response)
    print(f"parsed_output: {parsed_output}") # Print the parsed output for debugging
    return parsed_output
    
