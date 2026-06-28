---
version: 1.0.0
name: ai-pattern-rewriter
description: Surgical, line-level rewriting of specific AI-pattern phrases. Use when the user identifies a small number of specific phrases or sentences that read "too AI" and wants targeted fixes, not a full rewrite. Different from humanize-editor: this preserves structure and only changes flagged spans.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: surgical-edit
---
version: 1.0.0

# AI-Pattern Rewriter

Surgical, span-level rewriting. **Only** rewrite the specific phrases the user flagged (or that you can clearly identify as AI-pattern spans). Preserve everything else.

## When to load

- User says "перепиши только это предложение" / "fix just this paragraph"
- User has marked specific spans with `>>` or `!!!` in the text
- User is editing themselves and just wants targeted suggestions
- User wants to keep the rest exactly as is

## When NOT to load

- User wants a full rewrite → use `humanize-editor`
- User wants only diagnosis → use `anti-ai-auditor`
- User wants greenfield writing → use `humanize-writer`

## Hard rules

1. **Touch only the flagged spans.** If the user said "only line 7", do not edit line 12 even if it has issues.
2. **Preserve meaning** of the rewritten span exactly.
3. **Preserve surrounding tone** — don't make the rewritten span either more or less formal than its neighbors.
4. **Single rewrite per span** — show one alternative, not three. If the user wants options, they will ask.
5. **No commentary outside the rewrite** unless asked. Don't explain the change unless asked.

## Common spans and how to rewrite them

### "X is important" / "стоит отметить"
> Before: "It's important to note that the API has rate limits."
> After: "The API has rate limits — 100 req/min on the free tier."

### "Delve into"
> Before: "Let's delve into the architecture."
> After: "Architecture: 3 services, Kafka between them."

### "Более того"
> Before: "Система быстрая. Более того, она масштабируемая."
> After: "Система быстрая — p99 14 мс. И масштабируется: гоняли на 5k RPS, не упала."

### Triple-parallel list
> Before: "- Fast\n- Reliable\n- Secure"
> After: "- 14 мс p99.\n- 99.99% uptime за квартал.\n- Тесты на каждом merge."

### Abstract adjective + noun
> Before: "Это эффективное решение."
> After: "Это решение сократило время обработки с 4 сек до 200 мс."

### Hedging
> Before: "Возможно, стоит рассмотреть использование кеширования."
> After: "Нужен кеш — без него каждый запрос лезет в Postgres, и под нагрузкой мы получим 2k req/s вместо 5k."

### Closing cliché
> Before: "Таким образом, мы рассмотрели три подхода."
> After: (cut entirely, or "Из всех трёх я бы выбрал B — но A проще, если у вас уже есть Redis.")

### Impersonal "считается"
> Before: "Считается, что TDD улучшает качество кода."
> After: "Я за TDD — у нас в команде покрытие тестами выросло с 30% до 80% за полгода, багов стало заметно меньше."

## Output format

**Default (surgical):**

```
<rewritten span, in place>
```

If context makes this unclear, return:

```
Original: <span>
Rewritten: <span>
```

If the user asked for alternatives (they will say so), provide 2–3 options.

## Constraints to honor

- **Length** — don't expand unless asked. Default: keep new span within ±20% of old span's length.
- **Tone** — match neighbors. If surrounding text is formal, rewrite formally. If informal, match.
- **Domain vocabulary** — keep domain terms. Don't `Python` → `язык Python` or similar.

## Companion skills

- `humanize-writer` — for greenfield.
- `humanize-editor` — for full rewrites.
- `anti-ai-auditor` — if user is unsure what to flag.

## See also

- Obsidian: `~/Desktop/AgentWritingBase/04-Examples/before-after.md`