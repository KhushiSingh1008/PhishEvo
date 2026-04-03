import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import database
from encoder import encode_url, get_url_features
from aligner import align_url
from predictor import predict_mutations

app = FastAPI(title="PhishEvo API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_event():
    print("Initializing database...")
    database.init_db()

class AnalyzeRequest(BaseModel):
    url: str

@app.post("/analyze")
def analyze_url(req: AnalyzeRequest):
    url = req.url
    genome = encode_url(url)
    features = get_url_features(url)
    
    # Run placeholder alignment
    align_result = align_url(genome)
    family = align_result.get("family", "Unknown")
    similarity = align_result.get("similarity", 0.0)
    mutations = align_result.get("mutations", {})
    
    # Run placeholder prediction
    predictions = predict_mutations(family, genome)
    
    # Persist the scanned URL into DB
    database.insert_url(url, genome, family, similarity, mutations)
    
    return {
        "url": url,
        "genome": genome,
        "family": family,
        "similarity": similarity,
        "mutations": mutations,
        "predictions": predictions,
        "features": features
    }

@app.get("/families")
def get_families():
    return database.get_all_families()

@app.get("/analyses")
def get_analyses():
    return database.get_recent_analyses(20)

@app.get("/blocklist")
def get_blocklist():
    # Since get_all_blocklist wasn't added to database.py earlier, we'll execute it directly here
    conn = database.get_connection()
    c = conn.cursor()
    c.execute("SELECT * FROM blocklist ORDER BY added_at DESC")
    results = [dict(row) for row in c.fetchall()]
    conn.close()
    return results

@app.get("/health")
def health_check():
    return {"status": "ok", "version": "1.0"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
