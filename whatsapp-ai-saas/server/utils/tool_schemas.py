# Tool definition for OpenAI function-calling / tools
from datetime import datetime
formatted_current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z")


find_rag_info_tool = {
    "type": "function",
    "function": {
        "name": "find_rag_info",
        "description": (
            "Use this tool to find specific information from the company's knowledge base (RAG). "
            "This is useful for answering questions about products, services, policies, or general inquiries "
            "that are likely documented in the company's files or website content."
            "When to call this tool: If you have not already rag context for User Query, So you need to use this tool when you can not find answer from previous chat context and Rag context that we provided."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "The specific question or topic to search for in the knowledge base."
                }
            },
            "required": ["query"]
        }
    }
}


TOOLS = [find_rag_info_tool]
