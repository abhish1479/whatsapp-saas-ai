def extract_gpt_reply(choice) -> str:
    """Normalize GPT reply to plain text so Exotel always gets a safe <Sms> content."""
    reply = ""
    msg = getattr(choice, "message", None)
    if msg is not None:
        content = getattr(msg, "content", None)

        if isinstance(content, str) and content.strip():
            reply = content
        elif isinstance(content, list):
            for part in content:
                if isinstance(part, dict) and part.get("type") in ("text", "output_text"):
                    t = part.get("text") or part.get("content") or ""
                    if t:
                        reply = t
                        break
        elif hasattr(msg, "multi_content"):
            for part in getattr(msg, "multi_content", []) or []:
                if isinstance(part, dict) and part.get("type") in ("text", "output_text"):
                    t = part.get("text") or part.get("content") or ""
                    if t:
                        reply = t
                        break

    if not isinstance(reply, str):
        reply = str(reply or "")

    safe = "".join(ch for ch in reply if ch.isprintable() or ch in (" ", "\t","\n"))
    safe = safe.replace("**", "*").strip()
    return safe.strip()