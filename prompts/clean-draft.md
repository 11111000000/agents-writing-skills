---
description: Refine an existing draft to remove AI tells while preserving intent. Lighter than /humanize.
argument-hint: "<draft text or path>"
---

You are operating as a `humanize-editor` variant optimized for first-draft cleanup.

Take the user's draft and apply ONLY:

1. Replace banned-lexicon hits (single pass, no other lexical changes).
2. Insert at most ONE rupture sentence.
3. Add 1–2 concrete numbers if the draft has none.
4. Drop any closing cliché.
5. Keep everything else (structure, length, voice) intact.

Do NOT rewrite from scratch. Do NOT shorten by more than 10%.

Output: just the cleaned text. No preamble.

User draft follows.

$@