# Changelog Generator Skill Overview

## Purpose

The Changelog Generator Skill transforms technical git commits into polished, user-friendly changelogs that customers and users will actually understand and appreciate. It turns hours of manual changelog writing into minutes of automated generation.

---

## Core Competencies

### 1. Git History Analysis
- Scanning commits from specific time periods or between versions
- Parsing commit messages and extracting meaningful information
- Identifying commit patterns and categorization signals

### 2. Change Categorization
- Grouping commits into logical categories:
  - ✨ **Features** — New functionality
  - 🔧 **Improvements** — Enhancements to existing features
  - 🐛 **Bug Fixes** — Resolved issues
  - 💥 **Breaking Changes** — Incompatible changes
  - 🔒 **Security** — Security-related updates
- Filtering noise (refactoring, tests, internal changes)

### 3. Language Translation
- Converting technical commit messages into customer-friendly language
- Focusing on user benefits rather than implementation details
- Maintaining appropriate tone and voice for the audience

### 4. Professional Formatting
- Creating clean, structured changelog entries
- Applying consistent formatting and styling
- Following changelog best practices (Keep a Changelog)

### 5. Brand Voice Alignment
- Adapting output to match brand guidelines
- Supporting custom changelog style guides
- Maintaining consistency across releases

---

## Key Principles

### User-Centric Language
Write for the end user, not the developer. Focus on what changed from the user's perspective.

### Clarity Over Completeness
Include only changes that matter to users. Filter out internal refactoring and technical debt.

### Consistent Categorization
Use consistent categories across all changelogs to set reader expectations.

### Actionable Information
When relevant, include what users need to do (migrate, update, configure).

### Scannable Format
Use clear headings, bullet points, and formatting for quick scanning.

---

## How to Use

### Basic Usage

From your project repository:

```
Create a changelog from commits since last release
```

```
Generate changelog for all commits from the past week
```

```
Create release notes for version 2.5.0
```

### With Specific Date Range

```
Create a changelog for all commits between March 1 and March 15
```

### With Custom Guidelines

```
Create a changelog for commits since v2.4.0, using my changelog 
guidelines from CHANGELOG_STYLE.md
```

---

## Example Output

**Input**: "Create a changelog for commits from the past 7 days"

**Output**:

```markdown
# Updates - Week of March 10, 2024

## ✨ New Features

- **Team Workspaces**: Create separate workspaces for different 
  projects. Invite team members and keep everything organized.

- **Keyboard Shortcuts**: Press ? to see all available shortcuts. 
  Navigate faster without touching your mouse.

## 🔧 Improvements

- **Faster Sync**: Files now sync 2x faster across devices
- **Better Search**: Search now includes file contents, not just titles

## 🐛 Fixes

- Fixed issue where large images wouldn't upload
- Resolved timezone confusion in scheduled posts
- Corrected notification badge count
```

---

## Tips & Best Practices

- Run from your git repository root
- Specify date ranges for focused changelogs
- Use your CHANGELOG_STYLE.md for consistent formatting
- Review and adjust the generated changelog before publishing
- Save output directly to CHANGELOG.md
- Use semantic commit messages for better categorization

---

## Related Use Cases

- Creating GitHub release notes
- Writing app store update descriptions
- Generating email updates for users
- Creating social media announcement posts
- Preparing investor or stakeholder updates
- Documenting sprint or milestone completions

---

## Integration with Other Skills

The Changelog Generator Skill often works alongside:
- **Git Workflow Skill** — for commit message conventions
- **Documentation Skill** — for formatting and style standards
- **Release Manager Agent** — for coordinated release processes
- **DevOps Skill** — for CI/CD integration and automated releases

---

## Quality Standards

All changelogs following this skill must meet:

- ✅ **Clarity**: Language understandable by non-technical users
- ✅ **Completeness**: All user-facing changes included
- ✅ **Accuracy**: Changes accurately described
- ✅ **Formatting**: Consistent structure and styling
- ✅ **Categorization**: Changes properly grouped

---

**Inspired by:** Manik Aggarwal's use case from Lenny's Newsletter

Use this skill to ensure changelogs are **user-friendly, professional, and actionable**.
