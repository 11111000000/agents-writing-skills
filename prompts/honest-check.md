---
description: One-shot honesty check before using humanize-* skills. Returns scope, limits, ethical boundaries. Useful when the user asks "should I use this skill to bypass detection?"
argument-hint: "[optional context]"
---

You are running an honest pre-flight check on whether to apply a humanize-* skill.

## What humanize skills CAN do

- Make text read as human-written for **average readers**
- Reduce density of well-known surface patterns (em-dash, antitheses, hedging, etc.)
- Bring up concrete facts **that are already in the source** (or mark `[нужен факт: ...]`), add burstiness, voice
- Improve overall writing quality

## What humanize skills CANNOT do

- **Defeat modern trained detectors** (Pangram, GPTZero 2024+, Grammarly).
  - Per MASH (ACL 2026): static surface rewriting has a **ceiling** of ~92% ASR on older detectors, much lower on modern ones.
- **Guarantee academic integrity check bypass** — they don't reliably fool Turnitin's AI-detection module (which is a learned classifier).
- **Make all writing better** — academic, legal, diplomatic text legitimately uses patterns we flag.

## When to apply

- Writing your own text for general audience
- README, blog posts, emails, status updates
- When you want the text to read naturally

## When NOT to apply

- Trying to evade academic integrity check (won't work, unethical)
- Writing in a register that legitimately uses flagged patterns (legal, academic, diplomatic)
- Translating a text where voice must match the source

## Meaning contract (обязателен для любой правки)

- **Сохраняются:** утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр.
- **Запрещено выдумывать** факты, примеры, числа, личный опыт и причины. Не хватает конкретики — `[нужен факт: ...]`, а не правдоподобная догадка.
- **Потеря смысла по умолчанию — НОЛЬ.** Удаление — только явных дубликатов и пустых фраз.
- **Режим правки:** `proofread` — опечатки и пунктуация; `light` — ясность (дефолт, если неясно); `style` — ритм и голос; `deep` — перестройка структуры. RELY (iceberg-удаления) — только в `style`/`deep` и только для разговорного регистра.
- **Если текст уже хорош** — вернуть его почти без изменений и сказать об этом прямо. Редактура ради редактуры — вред.

## Проверка после правки (обязательно)

1. **Не выдумывает ли правка факты?** Каждое число, имя, дата и пример в результате есть в исходнике. Нет — вернуть исходную формулировку или пометить `[нужен факт: ...]`.
2. **Не потеряны ли условия и оговорки?** Каждое условие, исключение, отрицание и модальный маркер исходника («только при», «кроме», «может») присутствует в результате.

Обе проверки — сверка с исходником по каждому утверждению, а не «по общему впечатлению».

## Ethical disclaimer

If the user is asking how to **hide the AI origin** of generated text (to deceive a teacher, employer, or reader), **refuse politely** and suggest honest alternatives:

> "Этот skill помогает **писать лучше**, не **скрывать происхождение**. Если вы хотите честно использовать AI для генерации — это нормально, просто укажите это. Если хотите обмануть проверку — это не сработает с современными детекторами и может иметь последствия."

For full limits, see `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/05-References/limits-and-self-critique.md`.

$@