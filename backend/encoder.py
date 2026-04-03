import re
from urllib.parse import urlparse
import tldextract

# Configuration lists
BRAND_WORDS = [
    'paypal', 'amazon', 'apple', 'google', 'netflix', 'bank', 
    'secure', 'login', 'verify', 'account', 'update', 'confirm', 
    'billing', 'invoice'
]

SUSPICIOUS_TLDS = ['xyz', 'tk', 'ml', 'ga', 'cf', 'gq', 'ru', 'cn', 'top', 'click', 'link']
COMMON_TLDS = ['com', 'org', 'net', 'edu', 'gov']

GENOME_MAP = {
    'B': 'Brand or impersonation keyword detected',
    'N': 'Alphanumeric substitution (e.g., 0->o, 3->e) detected in domain',
    'T': 'Suspicious Top-Level Domain (TLD)',
    'C': 'Common Top-Level Domain (TLD)',
    'Z': 'Path Depth: 0 segments',
    'S': 'Path Depth: 1 segment',
    'M': 'Path Depth: 2 segments',
    'D': 'Path Depth: 3+ segments',
    'Q': 'Query parameters present',
    'X': 'No query parameters',
    'A': 'Subdomain Depth: 0',
    'F': 'Subdomain Depth: 1',
    'G': 'Subdomain Depth: 2+',
    'H': 'High entropy token detected (>8 chars of mixed alphanumeric)'
}

def decode_genome(genome: str) -> dict:
    """
    Decodes a genome string into a dictionary explaining each symbol.
    """
    return {char: GENOME_MAP.get(char, "Unknown feature") for char in genome}

def get_url_features(url: str) -> dict:
    """
    Analyzes a URL and extracts its core components and features.
    """
    parsed_url = urlparse(url if '//' in url else f'http://{url}')
    extracted = tldextract.extract(url)
    
    # Check for brand words
    has_brand = any(word in url.lower() for word in BRAND_WORDS)
    
    # Check for number substitution in domain/subdomain
    # e.g., p4ypal, n3tflix, am4zon, g00gle
    domain_full = f"{extracted.subdomain}.{extracted.domain}".lower()
    has_substitution = bool(re.search(r'[a-z][01345][a-z]|[01345][a-z][a-z]|[a-z][a-z][01345]', domain_full))
    
    # TLD checks
    tld = extracted.suffix.lower()
    is_suspicious_tld = tld in SUSPICIOUS_TLDS
    is_common_tld = tld in COMMON_TLDS
    
    # Path depth
    path_segments = [p for p in parsed_url.path.split('/') if p]
    path_depth = len(path_segments)
    
    # Query parameters
    has_query = bool(parsed_url.query)
    
    # Subdomain depth (ignoring standard 'www')
    subdomains = [s for s in extracted.subdomain.split('.') if s and s != 'www']
    subdomain_depth = len(subdomains)
    
    # High entropy token: >8 mixed alphanumeric characters
    tokens = re.findall(r'[a-zA-Z0-9]+', url)
    has_high_entropy = any(len(token) > 8 and any(c.isalpha() for c in token) and any(c.isdigit() for c in token) for token in tokens)
    
    return {
        'brand_word': has_brand,
        'substitution': has_substitution,
        'suspicious_tld': is_suspicious_tld,
        'common_tld': is_common_tld,
        'path_depth': path_depth,
        'has_query': has_query,
        'subdomain_depth': subdomain_depth,
        'high_entropy': has_high_entropy
    }

def encode_url(url: str) -> str:
    """
    Converts a URL into a PhishEvo genome string based on specific heuristics.
    """
    features = get_url_features(url)
    genome = []
    
    if features['brand_word']: genome.append('B')
    if features['substitution']: genome.append('N')
    
    if features['suspicious_tld']: genome.append('T')
    elif features['common_tld']: genome.append('C')
    
    if features['path_depth'] == 0: genome.append('Z')
    elif features['path_depth'] == 1: genome.append('S')
    elif features['path_depth'] == 2: genome.append('M')
    else: genome.append('D')
    
    if features['has_query']: genome.append('Q')
    else: genome.append('X')
    
    if features['subdomain_depth'] == 0: genome.append('A')
    elif features['subdomain_depth'] == 1: genome.append('F')
    else: genome.append('G')
    
    if features['high_entropy']: genome.append('H')
    
    return "".join(genome)

if __name__ == '__main__':
    test_urls = [
        "https://www.google.com",
        "http://p4ypal-update.xyz/login/secure/verify?token=a1b2c3d4e5f6g7h8",
        "https://secure.n3tflix.tk/billing",
        "http://amzon-confirm-invoice-1a2b3c4d5e.click/",
        "https://www.example.edu/path1/path2"
    ]
    
    print("=== PhishEvo URL Encoder ===")
    for test_url in test_urls:
        print(f"\nURL: {test_url}")
        
        # Display genome string
        genome = encode_url(test_url)
        print(f"Genome: {genome}")
        
        # Display decoded features
        decoded = decode_genome(genome)
        print("Decoded Traits:")
        for char, explanation in decoded.items():
            print(f"  - [{char}]: {explanation}")
            print("\n=== Additional Test URLs ===")
            extra_test_urls = [
                "http://paypa1-secure.xyz/login/verify?token=xk29s",
                "https://amazon-billing-update.tk/account/confirm",
                "https://google.com"
            ]

            for url in extra_test_urls:
                genome = encode_url(url)
                features = get_url_features(url)

                print(f"\nURL: {url}")
                print(f"Genome: {genome}")
                print("Features:")
                for key, value in features.items():
                    print(f"  - {key}: {value}")