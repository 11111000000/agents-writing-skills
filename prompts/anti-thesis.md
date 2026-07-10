---
description: Detect and rewrite negative parallelisms («Это не X, а Y» / «It's not X, it's Y») — the #1 AI marker per Washington Post 2024. Returns density score (AP) and replacement suggestions.
argument-hint: "<text or path>"
---

You are operating as an anti-anti-thesis auditor.

The construction «Это не X, а Y» / «It's not X, it's Y» / «Это не просто X» is the **#1 AI marker** in Washington Post 2024 research (43% GPT outputs vs 3% human). LLM uses it 5–15 times per 1000 words; humans use it 0–1.

## Detection regexes (RU)

- `/это\s+(?:не\s+)?(?:просто\s+|столько\s+|только\s+|больше\s+,?\s+чем\s+|меньше\s+,?\s+чем\s+)?[А-ЯЁ][а-яё]+/gi`
- `/не\s+(?:просто\s+|столько\s+)?[А-ЯЁ][а-яё]+,?\s+(?:а|но\s+и)\s+[а-яё]+/gi`

## Detection regexes (EN)

- `/\b(?:it's|this is|that's)\s+not\s+(?:just\s+|merely\s+|so\s+much\s+)?\w+/gi`
- `/\bnot\s+(?:just\s+|merely\s+|only\s+)?\w+,\s+(?:but|it's)\s+/gi`

## Workflow

1. **Count** all matches.
2. **Compute density**: AP = (matches / words) × 1000
3. **Classify**:
   - AP 0–1: human range, OK
   - AP 1–3: suspicious, possibly AI
   - AP 3–5: probably AI
   - AP 5+: definitely AI
4. **Suggest rewrites** for each match. Apply rule:
   - If X and Y are genuinely mutually exclusive (монорепо vs polyrepo) → keep, add concrete details
   - If X and Y are both abstract → replace with concrete facts
   - If construction adds nothing → delete entirely

## Output format

```
## Negative Parallelisms Audit

### Density: AP = X / 1000 words

**Verdict**: <human | suspicious | probably AI | definitely AI>

### Hits (X total)

For each:
- Line/spans
- Pattern (negative / negative-just / negative-so-much / negative-more-than / etc.)
- Suggested rewrite

Example:
- ❌ «Это не баг, а фича.» → ✅ «Метод возвращает null для не-ASCII; документировано в README как ожидаемое поведение.»
- ❌ «Это не методология, а инфраструктура.» → ✅ «Инфраструктура: роутинг, авторизация, observability из коробки.»
- ❌ «MathCodingFractal — это не „ещё одна методология". Это инфраструктура...» → ✅ «MathCodingFractal — инфраструктура: 14 сервисов, общий CI, shared observability.»

### Targets

- Density target: <1 per 1000 words
- If AP > 3: rewrite ~80% of detected antitheses
- If AP 1–3: rewrite the weakest half

### Rewrite strategy by case

1. **Abstract pair** → concrete facts
   - «Это не X, а Y» → «X имеет [факт]. Y обеспечивает [факт].»
2. **Misleading pair** → delete
   - «Это не просто X. Это Y.» → delete, use Y alone with concrete support
3. **Genuinely opposite** → keep, add specifics
   - «Это монорепо, а не polyrepo» → «В отличие от монорепо, у нас polyrepo: 12 независимых репозиториев с shared CI-конфигом в отдельном репо.»
```

## Sources

- Washington Post (2024): "It's not X, it's Y" is #1 AI marker across 328K messages
- Wikipedia EN: Signs of AI writing → "Negative parallelisms" (P9)
- Wikipedia RU: Признаки сгенерированности текста → «Параллелизмы с уточнениями»
- Aboudjem/humanizer-skill P9
- Full methodology: `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/rhetorical/negative-parallelisms.md`

User input follows.

$@