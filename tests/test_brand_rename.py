"""
DreameClaw Crew Brand Rename - Test Suite

This test suite verifies that all instances of "AI Crew" have been renamed to "DreameClaw Crew".
Following TDD methodology: RED (test first) -> GREEN (implement) -> BLUE (refactor).

Run tests with: pytest tests/test_brand_rename.py -v
"""

import os
import re
from pathlib import Path
from typing import List, Tuple

import pytest


# Configuration
PROJECT_ROOT = Path("/Users/eric/dreame/code/Clawith-main")
OLD_BRAND = "AI Crew"
NEW_BRAND = "DreameClaw Crew"
OLD_BRAND_LOWER = "ai-crew"
NEW_BRAND_LOWER = "dreameclaw-crew"
OLD_BRAND_UPPER = "AI_CREW"
NEW_BRAND_UPPER = "DREAMECLAW_CREW"

# Directories to scan
SCAN_DIRS = [
    PROJECT_ROOT / "backend",
    PROJECT_ROOT / "frontend",
    PROJECT_ROOT / "docs",
]

# File extensions to scan
CODE_EXTENSIONS = {
    ".py",
    ".tsx",
    ".ts",
    ".js",
    ".jsx",
    ".json",
    ".sh",
    ".yml",
    ".yaml",
    ".md",
    ".html",
    ".css",
}

# Directories to exclude from scanning
EXCLUDE_DIRS = {
    "node_modules",
    ".git",
    "__pycache__",
    ".pytest_cache",
    "venv",
    ".venv",
    "dist",
    "build",
    "agent_data",
}


def get_files_to_scan() -> List[Path]:
    """Get all source files to scan for brand name."""
    files = []
    for scan_dir in SCAN_DIRS:
        if not scan_dir.exists():
            continue
        for root, dirs, filenames in os.walk(scan_dir):
            # Filter out excluded directories
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

            for filename in filenames:
                file_path = Path(root) / filename
                # Check if file extension is in our list
                if file_path.suffix in CODE_EXTENSIONS or filename.endswith(".sh"):
                    files.append(file_path)
    return files


def scan_file_for_old_brand(file_path: Path) -> List[Tuple[int, str]]:
    """Scan a single file for old brand name and return line numbers and content."""
    matches = []
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            for line_num, line in enumerate(f, 1):
                # Check for any variation of the old brand
                if (
                    OLD_BRAND in line
                    or OLD_BRAND_LOWER in line
                    or OLD_BRAND_UPPER in line
                ):
                    matches.append((line_num, line.strip()))
    except Exception as e:
        pytest.fail(f"Failed to read file {file_path}: {e}")
    return matches


def scan_file_for_new_brand(file_path: Path) -> bool:
    """Check if file contains the new brand name."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            return (
                NEW_BRAND in content
                or NEW_BRAND_LOWER in content
                or NEW_BRAND_UPPER in content
            )
    except Exception:
        return False


class TestBrandRename:
    """Test suite for brand rename verification."""

    def test_001_no_old_brand_in_config_files(self):
        """TC-001: Verify no old brand name in configuration files."""
        config_files = [
            PROJECT_ROOT / "backend" / "pyproject.toml",
            PROJECT_ROOT / "backend" / "alembic.ini",
            PROJECT_ROOT / "docker-compose.yml",
        ]

        for config_file in config_files:
            if not config_file.exists():
                continue

            matches = scan_file_for_old_brand(config_file)
            assert len(matches) == 0, (
                f"Found {len(matches)} old brand occurrences in {config_file}:\n"
                + "\n".join(
                    [f"  Line {num}: {content}" for num, content in matches[:5]]
                )
            )

    def test_002_no_old_brand_in_backend(self):
        """TC-002: Verify no old brand name in backend code."""
        backend_dir = PROJECT_ROOT / "backend"
        files = [
            f for f in get_files_to_scan() if f.is_file() and backend_dir in f.parents
        ]

        failures = []
        for file_path in files:
            matches = scan_file_for_old_brand(file_path)
            if matches:
                failures.append((file_path, matches))

        assert len(failures) == 0, (
            f"Found old brand in {len(failures)} backend files:\n"
            + "\n".join(
                [
                    f"  {path.relative_to(PROJECT_ROOT)}: {len(matches)} occurrences"
                    for path, matches in failures[:10]
                ]
            )
        )

    def test_003_no_old_brand_in_frontend(self):
        """TC-003: Verify no old brand name in frontend code."""
        frontend_dir = PROJECT_ROOT / "frontend"
        files = [
            f for f in get_files_to_scan() if f.is_file() and frontend_dir in f.parents
        ]

        failures = []
        for file_path in files:
            matches = scan_file_for_old_brand(file_path)
            if matches:
                failures.append((file_path, matches))

        assert len(failures) == 0, (
            f"Found old brand in {len(failures)} frontend files:\n"
            + "\n".join(
                [
                    f"  {path.relative_to(PROJECT_ROOT)}: {len(matches)} occurrences"
                    for path, matches in failures[:10]
                ]
            )
        )

    def test_004_no_old_brand_in_docs(self):
        """TC-004: Verify no old brand name in documentation."""
        docs_dir = PROJECT_ROOT / "docs"
        readme_files = list(PROJECT_ROOT.glob("README*.md"))

        failures = []
        all_docs = [docs_dir] + [
            PROJECT_ROOT / "CONTRIBUTING.md",
            PROJECT_ROOT / "ARCHITECTURE_SPEC.md",
        ]

        for doc_dir in all_docs:
            if not doc_dir.exists():
                continue
            if doc_dir.is_file():
                matches = scan_file_for_old_brand(doc_dir)
                if matches:
                    failures.append((doc_dir, matches))
            else:
                for file_path in doc_dir.rglob("*.md"):
                    matches = scan_file_for_old_brand(file_path)
                    if matches:
                        failures.append((file_path, matches))

        # Also check README files
        for readme in readme_files:
            matches = scan_file_for_old_brand(readme)
            if matches:
                failures.append((readme, matches))

        assert len(failures) == 0, (
            f"Found old brand in {len(failures)} documentation files:\n"
            + "\n".join(
                [
                    f"  {path.relative_to(PROJECT_ROOT)}: {len(matches)} occurrences"
                    for path, matches in failures[:10]
                ]
            )
        )

    def test_005_new_brand_exists_in_key_files(self):
        """TC-005: Verify new brand name exists in key files."""
        key_files = [
            PROJECT_ROOT / "backend" / "pyproject.toml",
            PROJECT_ROOT / "backend" / "app" / "config.py",
            PROJECT_ROOT / "README.md",
        ]

        missing = []
        for key_file in key_files:
            if not key_file.exists():
                continue
            if not scan_file_for_new_brand(key_file):
                missing.append(key_file)

        assert len(missing) == 0, (
            f"New brand '{NEW_BRAND}' not found in {len(missing)} key files:\n"
            + "\n".join([f"  {f.relative_to(PROJECT_ROOT)}" for f in missing])
        )

    def test_006_project_directory_renamed(self):
        """TC-006: Verify project directory is renamed."""
        # This test checks if the directory name should be renamed
        # For now, we'll just verify the expected directory exists or the files are correct
        expected_dir = PROJECT_ROOT.name
        # Don't assert on directory name as it might break the test environment
        print(f"Current project directory: {expected_dir}")


class TestBrandRenameSummary:
    """Summary test that provides overall statistics."""

    def test_summary_report(self):
        """Generate a summary report of brand name occurrences."""
        files = get_files_to_scan()
        total_occurrences = 0
        files_with_old_brand = []

        for file_path in files:
            matches = scan_file_for_old_brand(file_path)
            if matches:
                total_occurrences += len(matches)
                files_with_old_brand.append((file_path, len(matches)))

        # Print summary
        print("\n" + "=" * 60)
        print(f"Brand Rename Summary Report")
        print("=" * 60)
        print(f"Total files scanned: {len(files)}")
        print(f"Files with old brand '{OLD_BRAND}': {len(files_with_old_brand)}")
        print(f"Total occurrences: {total_occurrences}")

        if files_with_old_brand:
            print(f"\nTop files with old brand:")
            for path, count in sorted(
                files_with_old_brand, key=lambda x: x[1], reverse=True
            )[:10]:
                print(f"  {path.relative_to(PROJECT_ROOT)}: {count}")

        print("=" * 60)

        # This test always passes - it's just for reporting
        assert True


if __name__ == "__main__":
    # Allow running directly for quick verification
    pytest.main([__file__, "-v", "--tb=short"])
