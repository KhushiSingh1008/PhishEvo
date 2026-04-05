import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.environ.get('GEMINI_API_KEY', ''))

def generate_threat_report(
    family: str,
    similarity: float,
    genome: str,
    mutations: list,
    predictions: list
) -> str:
    model = genai.GenerativeModel('gemini-1.5-flash')

    prompt = f"""You are a cybersecurity threat analyst for PhishEvo.

PHISHING URL ANALYSIS:
Campaign Family: {family}
Genome Sequence: {genome}
Similarity Score: {similarity:.1f}%
Mutations from reference: {mutations}
Predicted next variants: {predictions}

Write a threat intelligence report in exactly 4 short paragraphs:
Paragraph 1: Overall threat level and family identification.
Paragraph 2: What the genome sequence reveals about attack technique.
Paragraph 3: What the mutations indicate about campaign evolution.
Paragraph 4: Specific recommended defensive actions.

Keep each paragraph to 2-3 sentences.
Write professionally. No markdown. No bullet points."""

    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception:
        return (f"Threat detected: {family} family variant with "
                f"{similarity:.1f}% structural similarity. "
                f"Genome pattern {genome} indicates automated "
                f"phishing infrastructure. Block URL and report "
                f"to security team immediately.")