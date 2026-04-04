import vertexai
from vertexai.generative_models import GenerativeModel

# Initialize Vertex AI (Make sure GOOGLE_CLOUD_PROJECT is set in the environment)
vertexai.init()
model = GenerativeModel("gemini-1.5-pro")

def generate_threat_report(family, similarity, mutations, predictions) -> str:
    """Generates a threat report using Vertex AI Gemini 1.5 Pro."""
    prompt = f"""
    Analyze the following phishing threat:
    - Campaign Family: {family}
    - Similarity Score: {similarity}%
    - Detected Mutations: {mutations}
    - Predicted Next Variants: {predictions}
    
    Provide a concise technical threat report.
    """
    response = model.generate_content(prompt)
    return response.text
