#!/usr/bin/env python3
"""
strip_modmaps.py

This script strips `@...modmap` lines from a given `compile_commands.json`
file.

Usage:
    python strip_modmaps.py <path_to_compile_commands.json> <output_path>
"""

import argparse
import json
import os
import shlex
import sys


def parse_args():
    parser = argparse.ArgumentParser(
        description="Strip @...modmap lines from compile_commands.json"
    )
    parser.add_argument(
        "input_path", help="Path to the input compile_commands.json file"
    )
    parser.add_argument(
        "output_path", help="Path to the output stripped compile_commands.json file"
    )
    return parser.parse_args()


def strip_modmaps(input_path, output_path):
    """
    Strips `@...modmap` lines from the compile_commands.json file.

    Args:
        input_path (str): Path to the input compile_commands.json file.
        output_path (str): Path to the output stripped compile_commands.json file.
    """
    if not os.path.isfile(input_path):
        print(f"Error: The file {input_path} does not exist.")
        sys.exit(1)

    with open(input_path, "r") as infile:
        try:
            data = json.load(infile)
        except json.JSONDecodeError as e:
            print(f"Error: Failed to parse JSON from {input_path}: {e}")
            sys.exit(1)

    def is_modmap(token: str) -> bool:
        return token.startswith("@") and token.endswith(".modmap")

    for entry in data:
        if "arguments" in entry:
            entry["arguments"] = [
                arg for arg in entry["arguments"] if not is_modmap(arg)
            ]
        elif "command" in entry:
            tokens = [
                token for token in shlex.split(entry["command"]) if not is_modmap(token)
            ]
            entry["command"] = shlex.join(tokens)

    with open(output_path, "w") as outfile:
        json.dump(data, outfile, indent=2)


if __name__ == "__main__":
    args = parse_args()
    strip_modmaps(args.input_path, args.output_path)
