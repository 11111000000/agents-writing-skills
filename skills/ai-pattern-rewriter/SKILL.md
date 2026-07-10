---
name: ai-pattern-rewriter
description: Surgical, line-level rewriting of specific AI-pattern phrases. Use when the user identifies a small number of specific phrases or sentences that read "too AI" or "too long" and wants targeted fixes, not a full rewrite. Different from humanize-editor: this preserves structure and only changes flagged spans.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: surgical-edit
  version: 2
---

# AI-Pattern Rewriter (v2)

Surgical, span-level rewriting. **Only** rewrite the specific phrases the user flagged (or that you can clearly identify as AI-pattern spans). Preserve everything else. v2 adds spans for over-generation patterns (Lever 10/11).

## When to load

- User says "перепиши только это предложение" / "fix just this paragraph"
- User has marked specific spans with `>>` or `!!!` in the text
- User is editing themselves and just wants targeted suggestions
- User wants to keep the rest exactly as is
- **User asks "сократи вот это" / "это слишком длинно"** (new in v2)

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
6. **NEW in v2**: When applying over-generation rewrites, it's OK to **delete** rather than rewrite — that's often the right answer.

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

## Over-generation spans (NEW in v2)

> [!info] Для каждого паттерна: часто правильный ответ — **удалить**, а не переписать.

### Vacuum-filling opener (P-NEW-1)
> Before: "У нас в команде возник вопрос по дедлайну. После обсуждения мы пришли к выводу, что дедлайн нужно перенести."
> After: "Дедлайн нереальный. Сдвигаем."

или просто удалить первое предложение, если второе самостоятельно.

### Restatement chain (P-NEW-2)
> Before: "API стал работать быстрее. Оптимизация позволила сократить время отклика. Производительность улучшилась значительно."
> After: "API стал отвечать за 14 мс вместо 380."

### Bridging phrase (P-NEW-3)
> Before: "Как упоминалось выше, кеш важен. Это подводит нас к следующей теме — инвалидации кеша."
> After: "Кеш важен. Инвалидация — TTL 60 сек, плюс ручной `cache.del(key)`."

### Over-explanation (P-NEW-4)
> Before: "Чтобы установить библиотеку, вам нужно выполнить команду pip install. Команда pip install — это стандартный способ установки Python-пакетов."
> After: "`pip install foo`"

или удалить объяснение «команды pip install».

### Anticipatory hedging (P-NEW-5)
> Before: "Возможно, в некоторых случаях может быть полезно рассмотреть использование кеширования, хотя это зависит от конкретной ситуации."
> After: "Нужен кеш. Без него каждый запрос лезет в Postgres."

### Balanced framing (P-NEW-6)
> Before: "У PostgreSQL есть преимущества и недостатки. С одной стороны, он зрелый и проверенный. С другой стороны, его сложнее масштабировать горизонтально. Каждый проект индивидуален."
> After: "PostgreSQL хорош, пока не упрётесь в single-writer. У нас упёрлись при 8k req/s."

### Antithetical recap (P-NEW-7)
> Before: "Итак, мы рассмотрели три подхода: A, B, C. Каждый имеет свои плюсы и минусы. Выбор зависит от контекста проекта."
> After: (cut entirely)

или заменить на действие/вопрос: «Из трёх я бы выбрал B — но A проще, если у вас уже есть Redis.»

### Bridging closer
> Before: "В заключение хотелось бы отметить, что мы достигли значительных результатов. Команда проделала большую работу. Мы готовы к следующему этапу."
> After: (cut entirely. Точка.)

### Удаление restated-примеров
> Before: "Stripe, Datadog и PlanetScale используют этот подход."
> After: "Stripe использует этот подход." (если Stripe — канонический пример)

### Удаление obvious-следствия
> Before: "Мы переписали кеш. Теперь API отвечает быстрее."
> After: "Мы переписали кеш." (или добавить число: «API отвечает за 14 мс»)

### Williams 6 операций (финальный проход)

Применяйте к любому span:

1. **Delete words that mean little or nothing:** «in order to» → «to», «the fact that» → удалить
2. **Delete words that repeat the meaning of other words:** «they are both alike» → «they are alike»
3. **Delete words implied by other words:** удалить «absolutely» перед «essential»
4. **Replace a phrase with a word:** «is able to» → «can», «has the ability to» → «can»
5. **Change negatives to affirmatives:** «did not remember» → «forgot»
6. **Delete useless adjectives and adverbs:** «absolutely essential», «completely unanimous»

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

For over-generation rewrites, indicate if the span was deleted rather than rewritten:

```
Original: "..."
Action: deleted
```

If the user asked for alternatives (they will say so), provide 2–3 options.

## Constraints to honor

- **Length** — don't expand unless asked. Default: keep new span within ±20% of old span's length. **NEW in v2**: for over-generation rewrites, **deletion is preferred over compression** — if 50% of the span can be cut, cut it.
- **Tone** — match neighbors. If surrounding text is formal, rewrite formally. If informal, match.
- **Domain vocabulary** — keep domain terms. Don't `Python` → `язык Python` or similar.

## Companion skills

- `humanize-writer` — for greenfield.
- `humanize-editor` — for full rewrites.
- `anti-ai-auditor` — if user is unsure what to flag.

## See also

- Obsidian: `~/Desktop/AgentWritingBase/04-Examples/before-after.md`
- Obsidian: `~/Desktop/AgentWritingBase/02-Techniques/sufficiency-and-underspecification.md` (NEW)
- Obsidian: `~/Desktop/AgentWritingBase/01-Patterns/structural/over-generation.md` (NEW)