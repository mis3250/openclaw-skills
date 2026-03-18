---
name: pptagent
description: Generate professional PowerPoint presentations from text descriptions or documents (PDF, XLSX) using the PPTAgent framework. Use when the user asks to create a PPT, slides, or a presentation.
---

# PPTAgent Skill

This skill enables OpenClaw to generate high-quality, reflective PowerPoint presentations using the [PPTAgent](https://github.com/icip-cas/PPTAgent) framework. It automates the entire process from content research to visual design and PPTX export.

## Prerequisites

- **uv**: The `uv` package manager must be installed.
- **Python**: A stable version of Python (e.g., 3.12) is required.
- **Onboarding**: Before the first run, the user may need to configure LLM providers (OpenAI, Gemini, etc.) and optional tools like Tavily (search) or MinerU (PDF parsing).

## Usage

The skill primarily uses the `pptagent` CLI via `uvx` for zero-install execution.

### 1. Basic Generation
Generate a presentation based on a text prompt:
```bash
uvx pptagent generate "A presentation about the future of AI in 2030" -o future_ai.pptx
```

### 2. Generation with Documents
Create a PPT based on specific local files (Excel, PDF, etc.):
```bash
uvx pptagent generate "Q4 Financial Report Analysis" \
  -f data/q4_metrics.xlsx \
  -f documents/market_trends.pdf \
  -o q4_report.pptx
```

### 3. Setup and Configuration
If first-time configuration is needed:
```bash
uvx pptagent onboard
```
*Note: This command is interactive and should be run in a terminal (PTY).*

## Key Features

- **Reflective Generation**: The agent drafts, reviews, and refines slides for better coherence.
- **Deep Research**: Integrates web search (via Tavily) for comprehensive content.
- **Flexible Templates**: Supports both free-form and template-based designs.
- **Autonomous Asset Creation**: Generates images and charts as needed.

## Troubleshooting

- **Build Errors (fasttext)**: If `uvx` fails to build `fasttext`, ensure `python3-dev` and a C++17 compiler are installed.
- **Missing API Keys**: Ensure `mcp.json` or environment variables contain the necessary keys for your chosen LLM provider.
- **Windows Support**: `PPTAgent` does not support native Windows; use **WSL2** for all operations.
