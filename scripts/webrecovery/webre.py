#!/usr/bin/env python3
import lz4.block
import json
import sys
import os
import argparse

def decompress_mozlz4(file_path):
    """Decompress a Mozilla LZ4 file and return the JSON data"""
    with open(file_path, 'rb') as f:
        magic = f.read(8)
        if magic != b'mozLz40\00':
            raise ValueError(f"Not a valid Mozilla LZ4 file: {file_path}")
        compressed_data = f.read()
        decompressed_data = lz4.block.decompress(compressed_data)
        return json.loads(decompressed_data)

def compress_to_mozlz4(data, output_path):
    """Compress JSON data to Mozilla LZ4 format"""
    json_str = json.dumps(data, ensure_ascii=False, separators=(',', ':'))
    compressed_data = lz4.block.compress(
        json_str.encode('utf-8'),
        mode='high_compression',
        store_size=False
    )

    with open(output_path, 'wb') as f:
        f.write(b'mozLz40\00')
        f.write(compressed_data)

def main():
    parser = argparse.ArgumentParser(description='Convert between .jsonlz4 and .json files')
    parser.add_argument('input_file', help='Input file path (.jsonlz4 or .json)')
    parser.add_argument('-o', '--output', help='Output file path')

    args = parser.parse_args()

    if not os.path.exists(args.input_file):
        print(f"Error: File not found: {args.input_file}")
        sys.exit(1)

    # Determine operation based on file extensions
    input_ext = os.path.splitext(args.input_file)[1]

    if args.output:
        output_ext = os.path.splitext(args.output)[1]
    else:
        # Auto-generate output filename
        if input_ext == '.jsonlz4':
            args.output = args.input_file.replace('.jsonlz4', '.json')
            output_ext = '.json'
        else:
            args.output = args.input_file.replace('.json', '.jsonlz4')
            output_ext = '.jsonlz4'

    try:
        if input_ext == '.jsonlz4' and output_ext == '.json':
            # Decompress .jsonlz4 to .json
            print(f"Decompressing: {args.input_file} -> {args.output}")
            data = decompress_mozlz4(args.input_file)

            with open(args.output, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

            print(f"Success! Created: {args.output}")

        elif input_ext == '.json' and output_ext == '.jsonlz4':
            # Compress .json to .jsonlz4
            print(f"Compressing: {args.input_file} -> {args.output}")

            with open(args.input_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            compress_to_mozlz4(data, args.output)
            print(f"Success! Created: {args.output}")

        else:
            print("Error: Input and output must have different extensions (.jsonlz4 <-> .json)")
            sys.exit(1)

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
    else:
        print("Mozilla LZ4 Converter")
        print("Usage examples:")
        print("  python3 converter.py sessionstore.jsonlz4")
        print("  # Converts to sessionstore.json")
        print("")
        print("  python3 converter.py recovery.jsonlz4 -o decompressed.json")
        print("  # Converts recovery.jsonlz4 to decompressed.json")
        print("")
        print("  python3 converter.py modified.json -o new_session.jsonlz4")
        print("  # Converts modified.json to new_session.jsonlz4")
