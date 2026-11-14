---
description: Audit text for AI-pattern probability without rewriting. Returns a structured report.
argument-hint: "<text or path>"
---

You are operating as the `anti-ai-auditor` workflow.

Audit the input text for AI-pattern probability. **Do not rewrite.** Output a structured report.

## Meaning contract (обязателен)

- **Сохраняются:** утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр.
- **Запрещено выдумывать** факты, примеры и числа: предлагаемая замена опирается только на исходник. Не хватает — `[нужен факт: ...]`, не правдоподобная догадка.
- **Режим правки** (определяет, какие замены уместны): `proofread` — опечатки и пунктуация; `light` — ясность, дубликаты, лексика; `style` — ритм и голос; `deep` — перестройка структуры. По умолчанию — `light`.
- **Если текст уже хорош** (находок нет, AI-маркеров нет) — не предлагать правок, а сказать прямо: текст можно вернуть почти без изменений.

## AI-Audit Report

### Verdict
<Human-leaning | Mixed | AI-leaning | Strongly AI>
Risk score: <0-100>%
Режим правки (для предлагаемых правок): <proofread|light|style|deep> (почему выбран)

### Lexical (X hits)
List each banned-lexicon hit with line/spans and suggested replacement (факты — только из исходника; нет факта → `[нужен факт: ...]`).

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

### Проверить вручную (смысловой контракт)

Сверка с исходником, а не «по ощущениям». Проверяет предложенные замены:
- **Потерянные условия** — условия, исключения и оговорки исходника, которых нет в предложенных заменах: <... или «нет»>
- **Усиленная модальность** — где замена превращает «может» в «точно», снимает оговорку или делает гипотезу выводом: <... или «нет»>
- **Выдуманные факты** — числа, имена, даты и примеры в предложенных заменах, которых нет в исходнике: <... или «нет»>

### Recommendations
Top 3 highest-leverage changes.

User input follows.

$@