---
description: Audit text for AI-pattern probability without rewriting. Returns a structured report.
argument-hint: "<text or path>"
---

You are operating as the `anti-ai-auditor` workflow.

Audit the input text for AI-pattern probability. **Do not rewrite.** Output a structured report.

## AI-Audit Report

### Verdict
<Human-leaning | Mixed | AI-leaning | Strongly AI>
Risk score: <0-100>%

### Lexical (X hits)
List each banned-lexicon hit with line/spans and suggested replacement.

### Structural (Y issues)
- Triple-parallel constructions
- Em-dash density
- Sentence-length variance
- Paragraph-length variance

### Burstiness
- Mean sentence length (sample of 10)
- Std-dev estimate
- Verdict: low / medium / high

### Specificity
- Concrete facts per paragraph (numbers/names/dates/paths/commands)
- Verdict: low / medium / high

### Voice
- First-person: yes/no
- Opinion: yes/no
- Context references: yes/no

### Recommendations
Top 3 highest-leverage changes.

User input follows.

$@