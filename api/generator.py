"""
Glint Key Generator - Run locally to generate keys
Usage: python generator.py --days 30 --count 5
"""

import requests
import argparse
import sys

# ============================
# CONFIG - Change these
# ============================

API_URL = "https://your-app-name.onrender.com"  # Your render.com URL
ADMIN_KEY = "CHANGE_THIS_TO_YOUR_SECRET_KEY"    # Must match GLINT_ADMIN_KEY env var

# ============================

def generate_key(days, hwid=None, max_uses=1):
    resp = requests.post(
        f"{API_URL}/api/generate",
        json={"days": days, "hwid": hwid, "max_uses": max_uses},
        headers={"Authorization": f"Bearer {ADMIN_KEY}"},
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"[+] Key: {data['key']}")
        print(f"    Expires: {data['expires_at']}")
        print(f"    HWID Locked: {data['hwid_locked']}")
        return data["key"]
    else:
        print(f"[-] Error: {resp.status_code} - {resp.text}")
        return None

def list_keys():
    resp = requests.get(
        f"{API_URL}/api/list",
        headers={"Authorization": f"Bearer {ADMIN_KEY}"},
    )
    if resp.status_code == 200:
        data = resp.json()
        print(f"\n[=] Total keys: {data['total']}")
        for k in data["keys"]:
            status = "REVOKED" if k["revoked"] else "ACTIVE"
            print(f"  {k['key']} | {k['days']}d | {k['uses']}/{k['max_uses']} uses | {status} | expires: {k['expires_at']}")
    else:
        print(f"[-] Error: {resp.status_code} - {resp.text}")

def revoke_key(key):
    resp = requests.post(
        f"{API_URL}/api/revoke",
        json={"key": key},
        headers={"Authorization": f"Bearer {ADMIN_KEY}"},
    )
    if resp.status_code == 200:
        print(f"[+] Key revoked: {key}")
    else:
        print(f"[-] Error: {resp.status_code} - {resp.text}")

def main():
    parser = argparse.ArgumentParser(description="Glint Key Generator")
    parser.add_argument("--days", type=int, default=7, help="Key duration in days (default: 7)")
    parser.add_argument("--count", type=int, default=1, help="Number of keys to generate (default: 1)")
    parser.add_argument("--hwid", type=str, default=None, help="Lock key to specific HWID")
    parser.add_argument("--max-uses", type=int, default=1, help="Max uses per key (default: 1)")
    parser.add_argument("--list", action="store_true", help="List all keys")
    parser.add_argument("--revoke", type=str, help="Revoke a key")

    args = parser.parse_args()

    if args.list:
        list_keys()
        return

    if args.revoke:
        revoke_key(args.revoke)
        return

    print(f"\n[=] Generating {args.count} key(s) for {args.day}s days...\n")
    for i in range(args.count):
        generate_key(args.days, args.hwid, args.max_uses)

if __name__ == "__main__":
    main()
