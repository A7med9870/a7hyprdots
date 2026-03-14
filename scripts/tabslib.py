#!/usr/bin/env python3
import lz4.block
import sys
import json

def extract_urls_from_session(input_file):
    with open(input_file, 'rb') as f:
        data = f.read()
    
    # Skip the Mozilla LZ4 header and decompress
    if data[:8] == b'mozLz40\0':
        data = data[8:]
    
    decompressed = lz4.block.decompress(data)
    session_data = json.loads(decompressed)
    
    # Extract URLs from all windows and tabs
    urls = []
    for window in session_data.get('windows', []):
        for tab in window.get('tabs', []):
            # Get the most recent entry in each tab (current page)
            entries = tab.get('entries', [])
            if entries:
                last_entry = entries[-1]
                url = last_entry.get('url', '')
                title = last_entry.get('title', 'No title')
                if url and url.startswith(('http', 'file', 'about')):
                    urls.append({'url': url, 'title': title})
    
    return urls

def extract_urls_only(input_file):
    with open(input_file, 'rb') as f:
        data = f.read()
    
    if data[:8] == b'mozLz40\0':
        data = data[8:]
    
    decompressed = lz4.block.decompress(data)
    session_data = json.loads(decompressed)
    
    # Just get URLs, no titles
    urls = []
    for window in session_data.get('windows', []):
        for tab in window.get('tabs', []):
            entries = tab.get('entries', [])
            if entries:
                url = entries[-1].get('url', '')
                if url and url.startswith(('http', 'file', 'about')):
                    urls.append(url)
    
    return urls

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 extract_urls.py <input.jsonlz4> [--urls-only]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    urls_only = len(sys.argv) > 2 and sys.argv[2] == '--urls-only'
    
    if urls_only:
        urls = extract_urls_only(input_file)
        for url in urls:
            print(url)
    else:
        urls = extract_urls_from_session(input_file)
        for item in urls:
            print(f"{item['url']} - {item['title']}")
