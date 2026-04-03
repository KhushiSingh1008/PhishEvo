import os
import csv
import requests

def download_openphish():
    url = "https://openphish.com/feed.txt"
    print(f"Fetching OpenPhish feed from {url}...")
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        urls = response.text.strip().split('\n')
        urls = [u for u in urls if u.strip()]
        print(f"Successfully downloaded {len(urls)} URLs from OpenPhish.")
        return urls
    except Exception as e:
        print(f"Failed to download OpenPhish feed: {e}")
        return []

def download_phishtank():
    url = "https://data.phishtank.com/data/online-valid.csv"
    print(f"Fetching PhishTank feed from {url}...")
    try:
        # Some feeds require a user agent
        headers = {'User-Agent': 'PhishEvo/1.0'}
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
        
        urls = []
        lines = response.text.strip().split('\n')
        reader = csv.DictReader(lines)
        for row in reader:
            if 'url' in row:
                urls.append(row['url'])
                
        print(f"Successfully downloaded {len(urls)} URLs from PhishTank.")
        return urls
    except Exception as e:
        print(f"Failed to download PhishTank feed: {e}")
        return []

def load_local_sample():
    print("Loading local sample URLs for offline testing...")
    return [
        # PayPal (6 URLs)
        "http://paypal-update-account-info.com/login",
        "https://secure-paypal-resolution-center.net/",
        "http://www.paypal.com.customer-support-verify.info/",
        "https://verification-paypal-service.com/auth",
        "http://paypal-account-secured.net/sign-in",
        "https://update-paypal-billing.com/",
        
        # Amazon (6 URLs)
        "http://amazon-order-cancelled.com/refund",
        "https://amazon-prime-billing-update.net/",
        "http://www.amazon.com.customer-support-verify.info/",
        "https://amazon-security-alert-center.com/login",
        "http://amazon-account-locked-verify.net/",
        "https://amazon-rewards-claim-now.com/",
        
        # Banking (6 URLs)
        "http://chase-bank-security-alert.com/verify",
        "https://wells-fargo-urgent-update.net/",
        "http://www.bofa.com.customer-support-verify.info/",
        "https://citi-bank-account-locked.com/login",
        "http://hsbc-security-auth-check.net/",
        "https://barclays-urgent-security-notice.com/",
        
        # Crypto (6 URLs)
        "http://coinbase-wallet-verify.com/seed",
        "https://binance-security-update.net/",
        "http://www.metamask.io.wallet-restore.info/",
        "https://trust-wallet-connect-dapp.com/",
        "http://ledger-live-update-firmware.net/",
        "https://trezor-wallet-security.com/",
        
        # Netflix (6 URLs)
        "http://netflix-billing-update-now.com/payment",
        "https://netflix-account-suspended.net/",
        "http://www.netflix.com.customer-support-verify.info/",
        "https://netflix-payment-declined-update.com/login",
        "http://netflix-membership-expired.net/",
        "https://netflix-reward-claim.com/"
    ]

def save_urls_to_file(urls, filepath):
    print(f"Saving {len(urls)} URLs to {filepath}...")
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        for url in urls:
            f.write(f"{url}\n")
    print("Save complete.")

def main():
    print("Starting PhishEvo downloader...")
    
    openphish_urls = download_openphish()
    phishtank_urls = download_phishtank()
    
    # Combine and remove duplicates
    all_urls = list(set(openphish_urls + phishtank_urls))
    
    if not all_urls:
        print("Online sources failed. Falling back to local sample...")
        all_urls = load_local_sample()
        
    print(f"Total unique URLs gathered: {len(all_urls)}")
    
    # Save the URLs
    output_file = os.path.join(os.path.dirname(__file__), 'data', 'phishing_urls.txt')
    save_urls_to_file(all_urls, output_file)

if __name__ == '__main__':
    main()
