#!/usr/bin/env python3
"""
gen_dependency_info.py

Reads project.json (or equivalent file) and emits MysticDependencyInfo.cmake
with dependency metadata extracted from it.

Dependency has two sub-catagories:
  - "modules": This is first-party dependencies that are part of the
               Mystic Framework.
  - "third_party": This is third-party dependencies that are not part
                   of the MFW.

A valid dependency entry will look like this:
{
  ...Other project metadata...
  "dependencies": {
    "modules": [
      {
        "name": "Common",
        "version": "1.0.0"
      },
      {
        "name": "HAL",
        "version": "1.0.0"
      }
    ],
    "third_party": [
      {
        "name": "fmt",
        "version": "9.1.0",
        "git_url": "https://github.com/fmtlib/fmt.git",
        "git_tag": "9.1.0",
        "force_find_package": true
      },
      {
        "name": "spdlog",
        "version": "1.10.0",
        "git_url": "https://github.com/gabime/spdlog.git",
        "git_tag": "v1.10.0",
        "cmake_options": ["SPDLOG_FMT_EXTERNAL=ON"]
      }
    ]
  }
}

Each "modules" entry must have the following fields:
  - "name": The name of the module.
  - "version": The version of the module.
  - "cmake_options": A list of CMake options to be passed to the module's
                     CMakeLists.txt (Optional).
  - "force_find_package": If true, the module will be forced to use
                          find_package() only (Optional).
Each "third_party" entry must have the following fields:
  - "name": The name of the third-party dependency.
  - "version": The version of the third-party dependency.
  - "git_url": The git URL of the third-party dependency.
  - "git_tag": The git tag of the third-party dependency (Optional,
               defaults to "main").
  - "cmake_options": A list of CMake options to be passed to the module's
                     CMakeLists.txt (Optional).
  - "force_find_package": If true, the third-party dependency will be
                          forced to use find_package() only (Optional).

Usage:
  python gen_dependency_info.py <path_to_project_json> <output_path>

Here,
  <path_to_project_json> is the path to the project.json file (or equivalent).
  <output_path> is the path where MysticDependencyInfo.cmake will be generated.
"""

import argparse
import json
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

VALID_MODULES_JSON_URL = (
    "https://mystic-framework.github.io/resources/valid-modules.json"
)


def parse_args():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generates MysticDependencyInfo.cmake from project.json"
    )
    parser.add_argument(
        "project_json",
        type=str,
        help="Path to the project.json file (or equivalent).",
    )
    parser.add_argument(
        "output_path",
        type=str,
        help="Path where MysticDependencyInfo.cmake will be generated.",
    )
    return parser.parse_args()


def load_project_json(file_path: str) -> dict:
    """Loads the project.json file and returns its content as a dictionary."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {file_path}")
    except json.JSONDecodeError as e:
        raise ValueError(f"Failed to decode JSON from {file_path}: {e.msg}")


def fetch_valid_modules_json(url: str, timeout: float = 10.0) -> list[str]:
    """Fetches the valid-modules.json from the given URL."""
    req = Request(
        url,
        headers={
            "User-Agent": "mystic-framework-cmake-module-depedency-info-generator/1.0.0",
            "Accept": "application/json",
        },
    )
    try:
        with urlopen(req, timeout=timeout) as response:
            if response.status != 200:
                raise URLError(f"HTTP Error: {response.status} {response.reason}")
            raw_data = response.read().decode("utf-8")
            return json.loads(raw_data)
    except HTTPError as e:
        raise URLError(f"HTTP Error: {e.code} {e.reason}")
    except URLError as e:
        raise URLError(f"URL Error: {e.reason}")
    except json.JSONDecodeError as e:
        raise ValueError(f"Failed to decode JSON: {e.msg}")


valid_modules_cache = None


def validate_module_entry(modules: list[dict]):
    """Validates the module entries in the project.json."""

    def validate_module_name(module_name: str):
        if not module_name:
            raise ValueError("Module name cannot be empty.")
        global valid_modules_cache
        if valid_modules_cache is None:
            try:
                valid_modules_cache = fetch_valid_modules_json(VALID_MODULES_JSON_URL)
            except (URLError, ValueError, OSError) as e:
                raise ValueError(f"Failed to fetch valid modules: {e}")
        valid_modules = valid_modules_cache
        return module_name.lower() in (name.lower() for name in valid_modules)

    for module in modules:
        if "name" not in module or "version" not in module:
            raise ValueError(
                f"Module entry must contain 'name' and 'version': {module}"
            )
        if not validate_module_name(module["name"]):
            raise ValueError(
                f"Invalid module name: {module['name']}. Must be one of the valid modules."
            )


def validate_third_party_entry(third_party: list[dict]):
    """Validates the third-party entries in the project.json."""
    for entry in third_party:
        if "name" not in entry or "version" not in entry or "git_url" not in entry:
            raise ValueError(
                f"Third-party entry must contain 'name', 'version', 'git_url': {entry}"
            )


def write_cmake_options(options: list[str]) -> str:
    """Generates CMake content for a list of CMake options."""

    def format_option(option: str) -> tuple[str, str]:
        if "=" in option:
            key, value = option.split("=", 1)
            return key.strip(), value.strip()
        else:
            return option.strip(), "ON"

    def determine_option_type(value: str) -> str:
        """Determines the type of a CMake option based on its value."""
        if value.lower() in ["on", "off", "true", "false"]:
            return "BOOL"
        elif value.isdigit():
            return "INT"
        else:
            return "STRING"

    cmake_options = ""
    for option in options:
        key, value = format_option(option)
        option_type = determine_option_type(value)
        cmake_options += f'set({key} "{value}" CACHE {option_type} "Set by MysticDependencyInfo.cmake" FORCE)\n'

    cmake_options += "\n"

    return cmake_options


def write_module_entry(module: dict) -> str:
    """Generates CMake content for a module entry."""

    def format_module_name(name: str) -> str:
        return f"Mystic{name.capitalize()}"

    def format_module_url(name: str) -> str:
        return f"https://github.com/mystic-framework/{name.lower()}.git"

    validate_module_entry([module])
    cmake_entry = f"# Module: {module['name']} v{module['version']}\n"
    # Setup CMake options if provided
    if module.get("cmake_options"):
        cmake_entry += write_cmake_options(module["cmake_options"])

    # Function call to import the module
    cmake_entry += f"mystic_import_dependency({format_module_name(module['name'])}\n"
    cmake_entry += f'  VERSION "{module["version"]}"\n'
    cmake_entry += f'  GIT_URL "{format_module_url(module["name"])}"\n'
    cmake_entry += f'  GIT_TAG "v{module["version"]}"\n'
    if module.get("force_find_package", False):
        cmake_entry += "  FORCE_FIND_PACKAGE\n"
    cmake_entry += ")\n\n"

    return cmake_entry


def write_third_party_entry(entry: dict) -> str:
    """Generates CMake content for a third-party entry."""
    validate_third_party_entry([entry])

    cmake_entry = f"# Third-party: {entry['name']} v{entry['version']}\n"
    # Setup CMake options if provided
    if entry.get("cmake_options"):
        cmake_entry += write_cmake_options(entry["cmake_options"])

    # Function call to import the third-party dependency
    cmake_entry += f"mystic_import_dependency({entry['name']}\n"
    cmake_entry += f'  VERSION "{entry["version"]}"\n'
    cmake_entry += f'  GIT_URL "{entry["git_url"]}"\n'
    cmake_entry += f'  GIT_TAG "{entry.get("git_tag", "main")}"\n'
    if entry.get("force_find_package", False):
        cmake_entry += "  FORCE_FIND_PACKAGE\n"
    cmake_entry += ")\n\n"

    return cmake_entry


def generate_cmake_content(project_info: dict) -> str:
    """Generates the content of MysticDependencyInfo.cmake based on project metadata."""
    dependencies = project_info.get("dependencies", {})

    cmake_content = ""
    cmake_content += "# Auto-generated CMake file containing dependency information.\n"
    cmake_content += (
        "# Do not edit manually. Instead edit project.json (or equivalent).\n\n"
    )
    cmake_content += "include(MysticDependency)\n\n"

    # Process first-party modules
    cmake_content += "# --- First-party Dependencies ---\n"
    modules = dependencies.get("modules", [])
    print(f"-- [MYSTIC] Found {len(modules)} first-party module(s) in project.json.")
    for module in modules:
        cmake_content += write_module_entry(module)

    # Process third-party dependencies
    cmake_content += "# --- Third-party Dependencies ---\n"
    third_party = dependencies.get("third_party", [])
    print(
        f"-- [MYSTIC] Found {len(third_party)} third-party dependency(ies) in project.json."
    )
    for entry in third_party:
        cmake_content += write_third_party_entry(entry)

    return cmake_content


if __name__ == "__main__":
    args = parse_args()
    try:
        print("-- [MYSTIC] Processing dependencies from project.json...")
        project_info = load_project_json(args.project_json)
        cmake_content = generate_cmake_content(project_info)
        with open(args.output_path, "w", encoding="utf-8") as f:
            f.write(cmake_content)
        print("-- [MYSTIC] Successfully generated dependency information.")
    except (FileNotFoundError, OSError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
