#!/usr/bin/env python3
"""
gen_project_info.py

Reads project.json (or equivalent file) and emits MysticProjectInfo.cmake
with project metadata extracted from it.

Project metadata includes:
  - "name":         The name of the project.
  - "version":      The version of the project.
  - "description":  A brief description of the project.
  - "homepage":     The homepage URL of the project.
  - "languages":    A list of programming languages used in the
                    project.
  - "cxx_standard": The C++ standard version used in the project
                    (when applicable).
  - "license":      A SPDX license identifier for the project.

Project metadata can also include dependency information but it is
handled separately in `gen_dependencies.py`.

The generated CMake file will define the following variables:
  - "<PREFIX>_PROJECT_NAME":        The name of the project.
  - "<PREFIX>_PROJECT_VERSION":     The version of the project.
  - "<PREFIX>_PROJECT_DESCRIPTION": The description of the project.
  - "<PREFIX>_PROJECT_HOMEPAGE":    The homepage URL of the project.
  - "<PREFIX>_PROJECT_LANGUAGES":   A semicolon-separated list of
                                    programming languages used in the
                                    project.
  - "<PREFIX>_PROJECT_CXX_STANDARD": The C++ standard version used in
                                     the project (when applicable).
  - "<PREFIX>_PROJECT_LICENSE":      The SPDX license identifier for
                                     the project.

Here, <PREFIX> is "name" field in the project.json file, converted to
uppercase and spaces replaced with underscores.

Example: If the project name is "My Project", the generated CMake
variables will be:
  - "MY_PROJECT_PROJECT_NAME",
  - "MY_PROJECT_PROJECT_VERSION", etc.

This also defines `<PREFIX>_PROJECT_ARGUMENTS` variable containing args
for CMake's `project()` command, which can be used in the CMakeLists.txt
file.

Usage:
    gen_project_info.py <project.json> <output.cmake>

Here,
  - <project.json> is the path to the input JSON file containing project
    metadata.
  - <output.cmake> is the path to the output CMake file that will be
    generated.
"""

import argparse
import json
import os
import re
import subprocess
import sys


def parse_arguments():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate project-info.cmake from project.json"
    )
    parser.add_argument(
        "input_json", help="Path to the input JSON file containing project metadata."
    )
    parser.add_argument(
        "output_cmake", help="Path to the output CMake file that will be generated."
    )
    return parser.parse_args()


def get_installed_cmake_version():
    try:
        output = subprocess.check_output(
            ["cmake", "--version"], universal_newlines=True
        )
        match = re.search(r"(\d+)\.(\d+)\.(\d+)", output.splitlines()[0])
        if not match:
            raise ValueError(f"Unrecognized version line: {output.splitlines()[0]!r}")
        return tuple(int(p) for p in match.groups())
    except (
        subprocess.CalledProcessError,
        FileNotFoundError,
        IndexError,
        ValueError,
    ) as e:
        print(f"Error: Failed to get installed CMake version: {e}", file=sys.stderr)
        sys.exit(1)


def read_json_file(file_path):
    """Reads a JSON file and returns its content as a dictionary."""
    if not os.path.isfile(file_path):
        print(f"Error: File '{file_path}' does not exist.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse JSON file '{file_path}': {e}", file=sys.stderr)
        sys.exit(1)


def generate_cmake_content(project_info):
    """Generates the content of the CMake file based on project metadata."""
    if "name" not in project_info:
        print(
            "Error: 'name' field is required in the project metadata.", file=sys.stderr
        )
        sys.exit(1)

    prefix = re.sub(r"[^A-Za-z0-9]+", "_", project_info["name"]).strip("_").upper()

    def escape_string(value):
        """Escapes special characters in a string for CMake."""
        return (
            str(value)
            .replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("$", "\\$")
        )

    def write_variable(var_name, value):
        if value:
            return f'set({prefix}_{var_name} "{escape_string(value)}" PARENT_SCOPE)\n'
        else:
            return ""

    def write_argument(arg_name, value):
        if value:
            return f'  {arg_name} "{escape_string(value)}"\n'
        else:
            return ""

    cmake_content = ""
    cmake_content += "# Auto-generated CMake file containing project metadata.\n"
    cmake_content += (
        "# Do not edit manually. Instead edit project.json (or equivalent).\n\n"
    )
    cmake_content += write_variable("PROJECT_NAME", project_info.get("name"))
    cmake_content += write_variable("PROJECT_VERSION", project_info.get("version"))
    cmake_content += write_variable(
        "PROJECT_DESCRIPTION", project_info.get("description")
    )
    cmake_content += write_variable("PROJECT_HOMEPAGE", project_info.get("homepage"))
    cmake_content += write_variable(
        "PROJECT_LANGUAGES", ";".join(project_info.get("languages", []))
    )
    cmake_content += write_variable(
        "PROJECT_CXX_STANDARD", project_info.get("cxx_standard")
    )
    cmake_content += write_variable("PROJECT_LICENSE", project_info.get("license"))

    # Generate the project arguments for CMake's project() command
    cmake_content += "\n# Define project arguments for CMake's project() command.\n"
    cmake_content += f"set({prefix}_PROJECT_ARGUMENTS\n"
    cmake_content += f'  "{escape_string(project_info.get("name"))}"\n'
    cmake_content += write_argument("VERSION", project_info.get("version"))
    cmake_content += write_argument("DESCRIPTION", project_info.get("description"))
    cmake_content += write_argument("HOMEPAGE_URL", project_info.get("homepage"))
    cmake_content += write_argument(
        "LANGUAGES", ";".join(project_info.get("languages", []))
    )
    # License as an argument was added in CMake v4.3
    cmake_version = get_installed_cmake_version()
    if cmake_version >= (4, 3):
        cmake_content += write_argument("SPDX_LICENSE", project_info.get("license"))
    # Add PARENT_SCOPE to make the variable available in the parent scope
    cmake_content += "  PARENT_SCOPE\n"
    cmake_content += ")\n"

    # If languages contains C++, set the CXX_STANDARD variable
    if (
        "CXX" in project_info.get("languages", [])
        and project_info.get("cxx_standard") is not None
    ):
        cmake_content += "\n# Set C++ standard.\n"
        cmake_content += (
            f"set(CMAKE_CXX_STANDARD {project_info.get('cxx_standard')} PARENT_SCOPE)\n"
        )
        cmake_content += "set(CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE)\n"
        cmake_content += "set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)\n"

    # Write current project prefix
    cmake_content += "\n# Define current project prefix.\n"
    cmake_content += (
        "# This variable changes with each mystic_project() call / for each project.\n"
    )
    cmake_content += f'set(_MYSTIC_CURRENT_PROJECT_PREFIX "{prefix}")\n'

    return cmake_content


if __name__ == "__main__":
    args = parse_arguments()
    project_info = read_json_file(args.input_json)
    cmake_content = generate_cmake_content(project_info)

    try:
        with open(args.output_cmake, "w", encoding="utf-8") as f:
            f.write(cmake_content)
    except OSError as e:
        print(
            f"Error: Failed to write to output file '{args.output_cmake}': {e}",
            file=sys.stderr,
        )
        sys.exit(1)
