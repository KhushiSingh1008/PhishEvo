"""
PhishEvo — Database Abstraction Layer

Uses Firestore if credentials are available, and falls back to SQLite 
(the existing database.py) if not.
"""
import os
import database  # the existing SQLite mock

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    HAS_FIRESTORE = True
except ImportError:
    HAS_FIRESTORE = False

class PhishEvoDatabase:
    def __init__(self):
        self.use_firestore = False
        self.db = None
        
        if HAS_FIRESTORE and os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
            try:
                if not firebase_admin._apps:
                    cred = credentials.Certificate(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"))
                    firebase_admin.initialize_app(cred)
                self.db = firestore.client()
                self.use_firestore = True
                print("Database Init: Using Google Cloud Firestore")
            except Exception as e:
                print(f"Failed to initialize Firestore: {e}. Falling back to SQLite.")
                self.use_firestore = False
                
        if not self.use_firestore:
            database.init_db()
            print("Database Init: Using SQLite Fallback")

    def save_analysis(self, data: dict) -> str:
        if self.use_firestore:
            doc_ref = self.db.collection("analyses").document()
            doc_ref.set(data)
            return doc_ref.id
        else:
            url_id = database.insert_url(
                data.get("url", ""),
                data.get("genome", ""),
                data.get("campaign_match", ""),
                data.get("confidence", 0.0),
                {}  # mutations payload
            )
            return str(url_id)

    def get_analysis(self, doc_id: str) -> dict:
        if self.use_firestore:
            doc = self.db.collection("analyses").document(doc_id).get()
            return doc.to_dict() if doc.exists else {}
        else:
            conn = database.get_connection()
            c = conn.cursor()
            c.execute("SELECT * FROM urls WHERE id = ?", (doc_id,))
            row = c.fetchone()
            conn.close()
            return dict(row) if row else {}

    def get_all_analyses(self) -> list[dict]:
        if self.use_firestore:
            docs = self.db.collection("analyses").stream()
            return [doc.to_dict() for doc in docs]
        else:
            conn = database.get_connection()
            c = conn.cursor()
            c.execute("SELECT * FROM urls ORDER BY analyzed_at DESC")
            rows = [dict(r) for r in c.fetchall()]
            conn.close()
            return rows

    def get_all_families(self) -> list[dict]:
        if self.use_firestore:
            docs = self.db.collection("campaign_families").stream()
            return [doc.to_dict() for doc in docs]
        else:
            return database.get_all_families()

    def save_family(self, data: dict) -> str:
        if self.use_firestore:
            doc_ref = self.db.collection("campaign_families").document()
            doc_ref.set(data)
            return doc_ref.id
        else:
            conn = database.get_connection()
            c = conn.cursor()
            try:
                c.execute('''
                    INSERT INTO campaign_families (family_name, reference_genome, description)
                    VALUES (?, ?, ?)
                ''', (data.get("family_name", ""), data.get("reference_genome", ""), data.get("description", "")))
                conn.commit()
                last_id = c.lastrowid
            except Exception as e:
                print(f"Error saving family to SQLite: {e}")
                last_id = -1
            finally:
                conn.close()
            return str(last_id)

    def get_blocklist(self) -> list[str]:
        if self.use_firestore:
            docs = self.db.collection("blocklist").stream()
            return [doc.to_dict().get("url_pattern", "") for doc in docs]
        else:
            conn = database.get_connection()
            c = conn.cursor()
            c.execute("SELECT url_pattern FROM blocklist")
            patterns = [r["url_pattern"] for r in c.fetchall()]
            conn.close()
            return patterns

    def add_to_blocklist(self, url: str) -> bool:
        if self.use_firestore:
            doc_ref = self.db.collection("blocklist").document()
            doc_ref.set({
                "url_pattern": url,
                "reason": "Predicted malicious variant",
                "source_family": "PhishEvo Auto-Blocklist"
            })
            return True
        else:
            try:
                database.add_to_blocklist(url, "Predicted malicious variant", "PhishEvo Auto-Blocklist")
                return True
            except Exception:
                return False

    def get_genome_history(self, family_name: str) -> list[str]:
        """Fetch chronologically ordered genome history for predictor"""
        if self.use_firestore:
            try:
                docs = self.db.collection("analyses").where("campaign_match", "==", family_name).stream()
                items = [doc.to_dict() for doc in docs]
                # Default order by timestamp field (fallback 0)
                items.sort(key=lambda x: x.get("timestamp", 0) if x.get("timestamp") else 0)
                return [data.get("genome", "") for data in items if data.get("genome")]
            except Exception as e:
                print(f"History fetch error: {e}")
                return []
        else:
            conn = database.get_connection()
            c = conn.cursor()
            try:
                # database schema uses 'family_name'
                c.execute("SELECT genome_string FROM urls WHERE family_name = ? ORDER BY analyzed_at ASC", (family_name,))
                rows = c.fetchall()
            except Exception as e:
                print(f"SQLite History fetch error: {e}")
                rows = []
            finally:
                conn.close()
            return [r["genome_string"] for r in rows if r["genome_string"]]
