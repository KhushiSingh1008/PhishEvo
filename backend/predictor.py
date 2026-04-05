"""
PhishEvo — Markov Chain Mutation Predictor

Learns from historical genome sequences and predicts the most likely next mutation.
"""

def build_transition_matrix(genome_history: list[str]) -> dict:
    """
    Builds a character transition probability matrix from a list of historical genome strings.
    """
    matrix = {}
    if len(genome_history) < 2:
        return matrix
        
    counts = {}
    for genome in genome_history:
        for i in range(len(genome) - 1):
            c1 = genome[i]
            c2 = genome[i+1]
            if c1 not in counts:
                counts[c1] = {}
            counts[c1][c2] = counts[c1].get(c2, 0) + 1
            
    for c1, transitions in counts.items():
        total = sum(transitions.values())
        matrix[c1] = {c2: count / total for c2, count in transitions.items()}
        
    return matrix


def predict_next_variants(current_genome: str, matrix: dict, top_n: int = 3) -> list[str]:
    """
    Generates the top N most probable next genome mutations (additions/substitutions).
    """
    if not matrix or not current_genome:
        return ["Insufficient data for prediction"]
        
    variants = []
    
    # 1. Additions (from last char)
    last_char = current_genome[-1]
    if last_char in matrix:
        sorted_adds = sorted(matrix[last_char].items(), key=lambda x: x[1], reverse=True)
        for char, prob in sorted_adds:
            variants.append(current_genome + char)
            
    # 2. Substitutions (from second to last char)
    if len(current_genome) >= 2:
        prev_char = current_genome[-2]
        if prev_char in matrix:
            sorted_subs = sorted(matrix[prev_char].items(), key=lambda x: x[1], reverse=True)
            for char, prob in sorted_subs:
                if char != last_char:
                    variants.append(current_genome[:-1] + char)
                    
    # If still no variants
    if not variants:
        return ["Insufficient data for prediction"]
        
    # Return unique variants preserving order up to top_n
    seen = set()
    result = []
    for v in variants:
        if v not in seen:
            seen.add(v)
            result.append(v)
            if len(result) == top_n:
                break
                
    return result

# Legacy shim to avoid breaking before Step 5
def predict_mutations(family: str, genome: str) -> dict:
    return {
        "predicted_variants": []
    }
