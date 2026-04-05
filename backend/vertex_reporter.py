"""
PhishEvo — Gemini Threat Reporter

Calls Google's Gemini API via google-generativeai SDK and falls back to a structured 
mock report if credentials are missing.
"""
import os
import json

try:
    import google.generativeai as genai
    from google.api_core.exceptions import GoogleAPIError
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False

def _has_credentials():
    return bool(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS") or os.environ.get("GEMINI_API_KEY"))

def generate_report(analysis_data: dict) -> dict:
    """
    Generates a threat report using Gemini 1.5 Pro.
    Falls back to a mock report if credentials are missing or API call fails.
    """
    fallback_report = {
        "threat_level": "HIGH" if analysis_data.get("confidence", 0) > 0.8 else "MEDIUM",
        "summary": f"Analyzed URL '{analysis_data.get('url', 'Unknown')}' matches the '{analysis_data.get('campaign_match', 'Unknown')}' campaign family with {analysis_data.get('confidence', 0):.0%} confidence.",
        "indicators": [f"Genome string: {analysis_data.get('genome', 'Unknown')}"],
        "recommended_actions": ["Block immediately on firewalls", "Notify targeted users"],
        "campaign_context": f"This threat belongs to the {analysis_data.get('campaign_match', 'Unknown')} family, known for frequent mutations."
    }

    if not (HAS_GEMINI and _has_credentials()):
        print("Gemini API skipped (no credentials). Using fallback report.")
        return fallback_report

    try:
        if os.environ.get("GEMINI_API_KEY"):
            genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))

        model = genai.GenerativeModel("gemini-1.5-pro")
        
        prompt = f"""
        Analyze the following phishing threat data and return a JSON object.
        Do not use markdown blocks, no preamble, ONLY direct raw JSON.
        
        Threat Data:
        - URL: {analysis_data.get('url', 'N/A')}
        - Genome: {analysis_data.get('genome', 'N/A')}
        - Campaign Match: {analysis_data.get('campaign_match', 'N/A')}
        - Confidence Score: {analysis_data.get('confidence', 0)}
        - Predicted Next Variants: {analysis_data.get('predicted_variants', [])}
        
        Required JSON Structure:
        {{
            "threat_level": "HIGH" | "MEDIUM" | "LOW",
            "summary": "one paragraph plain English summary",
            "indicators": ["indicator1", "indicator2", ...],
            "recommended_actions": ["action1", "action2", ...],
            "campaign_context": "paragraph about the matched campaign family"
        }}
        """
        
        response = model.generate_content(prompt)
        text = response.text.strip()
        
        if text.startswith("```json"):
            text = text[7:]
        elif text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]
            
        result = json.loads(text.strip())
        
        # Verify schema
        required_keys = {"threat_level", "summary", "indicators", "recommended_actions", "campaign_context"}
        if not required_keys.issubset(result.keys()):
            raise ValueError("Missing keys in Gemini response schema.")
            
        return result
        
    except Exception as e:
        print(f"Gemini API generation failed: {e}. Using fallback report.")
        return fallback_report

# Legacy shim 
def generate_threat_report(family, similarity, mutations, predictions) -> str:
    return "This is a placeholder UI format."
