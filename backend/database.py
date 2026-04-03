import sqlite3
import json
from datetime import datetime
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'data', 'phishevo.db')

def get_connection():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_connection()
    c = conn.cursor()
    
    # urls table
    c.execute('''
        CREATE TABLE IF NOT EXISTS urls (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            raw_url TEXT NOT NULL,
            genome_string TEXT NOT NULL,
            family_name TEXT,
            similarity_score REAL,
            mutation_map TEXT,
            analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # campaign_families table
    c.execute('''
        CREATE TABLE IF NOT EXISTS campaign_families (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            family_name TEXT UNIQUE NOT NULL,
            reference_genome TEXT NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # predictions table
    c.execute('''
        CREATE TABLE IF NOT EXISTS predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            family_name TEXT NOT NULL,
            predicted_genome TEXT NOT NULL,
            predicted_url_pattern TEXT NOT NULL,
            confidence_score REAL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # blocklist table
    c.execute('''
        CREATE TABLE IF NOT EXISTS blocklist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url_pattern TEXT NOT NULL,
            reason TEXT,
            source_family TEXT,
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()
    print("Database initialized successfully.")

def insert_url(raw_url, genome, family, score, mutations):
    conn = get_connection()
    c = conn.cursor()
    c.execute('''
        INSERT INTO urls (raw_url, genome_string, family_name, similarity_score, mutation_map)
        VALUES (?, ?, ?, ?, ?)
    ''', (raw_url, genome, family, score, json.dumps(mutations) if mutations else '{}'))
    
    url_id = c.lastrowid
    conn.commit()
    conn.close()
    return url_id

def get_all_families():
    conn = get_connection()
    c = conn.cursor()
    c.execute('SELECT * FROM campaign_families')
    families = [dict(row) for row in c.fetchall()]
    conn.close()
    return families

def add_to_blocklist(pattern, reason, family):
    conn = get_connection()
    c = conn.cursor()
    c.execute('''
        INSERT INTO blocklist (url_pattern, reason, source_family)
        VALUES (?, ?, ?)
    ''', (pattern, reason, family))
    blocklist_id = c.lastrowid
    conn.commit()
    conn.close()
    return blocklist_id

def get_recent_analyses(limit=20):
    conn = get_connection()
    c = conn.cursor()
    c.execute('''
        SELECT id, raw_url, genome_string, family_name, similarity_score, mutation_map, analyzed_at
        FROM urls
        ORDER BY analyzed_at DESC
        LIMIT ?
    ''', (limit,))
    recent_urls = [dict(row) for row in c.fetchall()]
    conn.close()
    return recent_urls

if __name__ == '__main__':
    init_db()
    
    # Seed 5 campaign families
    seed_families = [
        ('PayPal-Impersonation', 'PP-REF-001', 'Standard PayPal login credential harvester'),
        ('Amazon-Scam', 'AMZN-REF-001', 'Amazon order cancellation phishing theme'),
        ('Banking-Fraud', 'BANK-REF-001', 'Generic online banking security alert'),
        ('Crypto-Theft', 'CRYP-REF-001', 'Cryptocurrency wallet recovery seed phrase theft'),
        ('Netflix-Phish', 'NFLX-REF-001', 'Netflix billing update scam')
    ]
    
    conn = get_connection()
    c = conn.cursor()
    
    for family in seed_families:
        try:
            c.execute('''
                INSERT INTO campaign_families (family_name, reference_genome, description)
                VALUES (?, ?, ?)
            ''', family)
            print(f"Seeded campaign family: {family[0]}")
        except sqlite3.IntegrityError:
            print(f"Campaign family {family[0]} already exists, skipping.")
            
    conn.commit()
    conn.close()
