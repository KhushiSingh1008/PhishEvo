"""
PhishEvo — Smith-Waterman Sequence Alignment Module

Implements local sequence alignment to compare a query genome string
(e.g. "BNTMQ") against known campaign reference genomes stored in the DB.

Scoring: Match = +2, Mismatch = -1, Gap penalty = -1
"""


# ── Scoring constants ──────────────────────────────────────────────────
MATCH_SCORE = 2
MISMATCH_SCORE = -1
GAP_PENALTY = -1


def calculate_similarity(score: float, seq1: str, seq2: str) -> float:
    # Use length of shorter sequence for normalization
    min_len = min(len(seq1), len(seq2))
    max_len = max(len(seq1), len(seq2))
    
    # Max possible score = match score * shorter length
    max_possible = min_len * MATCH_SCORE
    
    if max_possible == 0:
        return 0.0
    
    # Base similarity from alignment
    base_similarity = min(score / max_possible, 1.0)
    
    # Bonus for length similarity (penalize very different lengths)
    length_ratio = min_len / max_len
    
    # Weighted final score (scaled to 0.0 - 1.0 to match original output range)
    final = (base_similarity * 0.8) + (length_ratio * 0.2)
    
    return round(min(final, 1.0), 4)

def smith_waterman(seq1: str, seq2: str) -> float:
    """
    Perform Smith-Waterman local sequence alignment between two genome strings.

    Returns a normalized similarity score between 0.0 and 1.0.
    The score is normalized against the theoretical maximum: the shorter
    sequence perfectly matching within the longer one.
    """
    if not seq1 or not seq2:
        return 0.0

    m = len(seq1)
    n = len(seq2)

    # Build the scoring matrix (m+1 x n+1), initialized to 0
    H = [[0] * (n + 1) for _ in range(m + 1)]

    max_score = 0

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            # Diagonal: match or mismatch
            if seq1[i - 1] == seq2[j - 1]:
                diag = H[i - 1][j - 1] + MATCH_SCORE
            else:
                diag = H[i - 1][j - 1] + MISMATCH_SCORE

            # Gap in seq2 (deletion)
            up = H[i - 1][j] + GAP_PENALTY

            # Gap in seq1 (insertion)
            left = H[i][j - 1] + GAP_PENALTY

            # Smith-Waterman: no negative scores
            H[i][j] = max(0, diag, up, left)

            if H[i][j] > max_score:
                max_score = H[i][j]

    return calculate_similarity(max_score, seq1, seq2)


def align_to_campaigns(genome: str, campaigns: list) -> dict:
    """
    Compare *genome* against every campaign's reference_genome and return
    a ranked result dict.

    Parameters
    ----------
    genome : str
        The query genome string (e.g. "BNTMQ").
    campaigns : list[dict]
        Each dict must have at least:
            - "family_name" (str)   — campaign identifier
            - "reference_genome" (str) — the reference genome to align against

    Returns
    -------
    dict with keys:
        best_match  : str   — name of the highest-scoring campaign
        confidence  : float — similarity score of the best match (0.0 – 1.0)
        all_scores  : list[dict] — [{"campaign": ..., "score": ...}, ...]
    """
    if not campaigns or not genome:
        return {
            "best_match": "Unknown",
            "confidence": 0.0,
            "all_scores": [],
        }

    all_scores = []

    for campaign in campaigns:
        name = campaign.get("family_name", campaign.get("name", "Unknown"))
        ref_genome = campaign.get("reference_genome", "")

        score = smith_waterman(genome, ref_genome)
        all_scores.append({"campaign": name, "score": score})

    # Sort descending by score
    all_scores.sort(key=lambda x: x["score"], reverse=True)

    best = all_scores[0]

    return {
        "best_match": best["campaign"],
        "confidence": best["score"],
        "all_scores": all_scores,
    }


# ── Legacy wrapper (keeps old main.py calls working until Step 5) ──────
def align_url(genome: str) -> dict:
    """
    Backward-compatible shim so the old main.py import still works.
    Without DB access here, it returns the 'Unknown' default.
    """
    return {
        "family": "Unknown",
        "similarity": 0.0,
        "mutations": {},
    }


# ── Quick self-test ────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== Smith-Waterman self-test ===")

    # Identical sequences
    s = smith_waterman("BNTMQ", "BNTMQ")
    print(f"BNTMQ vs BNTMQ → {s}  (expect 1.0)")

    # Partial match
    s = smith_waterman("BNTMQ", "BNTHQ")
    print(f"BNTMQ vs BNTHQ → {s}  (expect ~0.6–0.8)")

    # No overlap
    s = smith_waterman("BNTMQ", "ZZZZZ")
    print(f"BNTMQ vs ZZZZZ → {s}  (expect 0.0)")

    # Different lengths
    s = smith_waterman("BNTMQ", "BN")
    print(f"BNTMQ vs BN    → {s}  (expect 1.0 — perfect local match)")

    # Campaign ranking
    mock_campaigns = [
        {"family_name": "PayPal-Impersonation", "reference_genome": "BNTHQ"},
        {"family_name": "Google-Phish", "reference_genome": "BSMQ"},
        {"family_name": "Generic-Credential-Harvest", "reference_genome": "TMQH"},
    ]
    result = align_to_campaigns("BNTMQ", mock_campaigns)
    print(f"\nBest match for BNTMQ: {result['best_match']} "
          f"(confidence {result['confidence']})")
    for entry in result["all_scores"]:
        print(f"  {entry['campaign']:30s} → {entry['score']}")
