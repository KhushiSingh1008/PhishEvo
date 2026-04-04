import os
from google.cloud import firestore

# Initialize Firestore DB (requires GOOGLE_APPLICATION_CREDENTIALS)
db = firestore.Client()

def init_db():
    """Seeds Firestore if collections are empty."""
    families_ref = db.collection("campaign_families")
    if not list(families_ref.limit(1).stream()):
        # Seed logic here
        pass

def insert_url(raw_url, genome, family, score, mutations):
    doc_ref = db.collection("analyses").document()
    doc_ref.set({
        "raw_url": raw_url,
        "genome": genome,
        "family": family,
        "score": score,
        "mutations": mutations,
        "timestamp": firestore.SERVER_TIMESTAMP
    })

def get_all_families():
    docs = db.collection("campaign_families").stream()
    return [doc.to_dict() for doc in docs]

def add_to_blocklist(pattern, reason, family):
    doc_ref = db.collection("blocklist").document()
    doc_ref.set({
        "pattern": pattern,
        "reason": reason,
        "family": family
    })

def get_recent_analyses(limit=20):
    docs = db.collection("analyses").order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()
    return [doc.to_dict() for doc in docs]
