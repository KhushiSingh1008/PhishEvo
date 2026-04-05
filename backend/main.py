import os
from dotenv import load_dotenv

# Load environment variables from .env file directly into system memory
load_dotenv()

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from encoder import encode_url
from aligner import align_to_campaigns
from predictor import build_transition_matrix, predict_next_variants
from vertex_reporter import generate_report
from firestore_db import PhishEvoDatabase

app = FastAPI(title="PhishEvo End-to-End API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

db = PhishEvoDatabase()

@app.on_event("startup")
def startup_event():
    print("Verifying/Seeding initial database state...")
    families = db.get_all_families()
    if not families:
        print("Database is empty. Seeding reference campaigns...")
        db.save_family({
            "family_name": "PayPal-Impersonation", 
            "reference_genome": "BNTMQ",
            "description": "Standard PayPal login credential harvester"
        })
        db.save_family({
            "family_name": "Amazon-Scam", 
            "reference_genome": "BSTDQ",
            "description": "Amazon phishing site mock dataset"
        })
        db.save_family({
            "family_name": "Banking-Fraud", 
            "reference_genome": "BBTMX",
            "description": "Banking fraud variant"
        })
        db.save_family({
            "family_name": "Crypto-Theft", 
            "reference_genome": "HNTDQ",
            "description": "Crypto wallet drainer"
        })
        db.save_family({
            "family_name": "Netflix-Phish", 
            "reference_genome": "BNSMX",
            "description": "Netflix subscription renew scam"
        })
    else:
        print(f"Found {len(families)} campaigns connected to db.")

def calculate_risk_level(similarity: float) -> str:
    if similarity >= 0.70:
        return "HIGH"
    elif similarity >= 0.40:
        return "MEDIUM"
    elif similarity >= 0.15:
        return "LOW"
    else:
        return "SAFE"

class AnalyzeRequest(BaseModel):
    url: str

@app.post("/analyze")
def analyze_url(req: AnalyzeRequest):
    url = req.url
    
    # 1. Genome String Generation
    genome = encode_url(url)
    
    # 2. Load Campaigns for Alignment
    campaigns = db.get_all_families()
    
    # 3. Align to find best match
    alignment = align_to_campaigns(genome, campaigns)
    campaign_match = alignment.get("best_match", "Unknown")
    confidence = alignment.get("confidence", 0.0)
    
    # 4. Load genome history for this campaign to predict mutations
    genome_history = db.get_genome_history(campaign_match)
    
    # Pre-pend a reference genome to history to guarantee data if no history yet
    ref_genome = ""
    for c in campaigns:
        if c.get("family_name") == campaign_match or c.get("name") == campaign_match:
            ref_genome = c.get("reference_genome", "")
            break
            
    if ref_genome and ref_genome not in genome_history:
        genome_history.insert(0, ref_genome)
        
    history_with_current = genome_history + [genome]
    
    # 5. Predict Next Variants
    transition_matrix = build_transition_matrix(history_with_current)
    predicted_variants = predict_next_variants(genome, transition_matrix)
    
    # Simulate adding proactive rules to blocklist
    if predicted_variants and predicted_variants[0] != "Insufficient data for prediction":
        for v in predicted_variants:
            db.add_to_blocklist(f"predicted_pattern_{v}")

    # 6. Generate Threat Report via Gemini (or fallback)
    analysis_data = {
        "url": url,
        "genome": genome,
        "campaign_match": campaign_match,
        "confidence": confidence,
        "predicted_variants": predicted_variants
    }
    report = generate_report(analysis_data)
    
    # 7. Save the overall analysis into DB
    analysis_data["report"] = report
    db.save_analysis(analysis_data)
    
    # 8. Return response directly to frontend (exact required JSON structural fit)
    if isinstance(report, str):
        report = {
            "threat_level": calculate_risk_level(confidence),
            "summary": report,
            "indicators": [],
            "recommended_actions": [],
            "campaign_context": ""
        }
    else:
        report["threat_level"] = report.get("threat_level") or calculate_risk_level(confidence)
        
    return {
        "url": url,
        "genome": genome,
        "campaign_match": campaign_match,
        "confidence": confidence,
        "predicted_variants": predicted_variants,
        "report": report
    }

@app.get("/families")
def get_families():
    return db.get_all_families()

@app.get("/analyses")
def get_analyses():
    return db.get_all_analyses()

@app.post("/blocklist")
async def add_to_blocklist(request: dict):
    try:
        url = request.get("url", "") or request.get("pattern", "")
        
        # Add to database
        db.add_to_blocklist(url)
        
        return {
            "success": True,
            "message": f"URL '{url}' added to blocklist",
            "url": url
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/blocklist")
async def get_blocklist():
    try:
        items = db.get_blocklist()
        return {"blocklist": items, "count": len(items)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    return {"status": "ok", "version": "1.0"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
