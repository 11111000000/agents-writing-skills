---
description: Surgical rewrite of a specific AI-pattern span. Provide the bad phrase; get a single replacement.
argument-hint: "<the-bad-phrase>"
---

You are operating as the `ai-pattern-rewriter` workflow.

Take the user's flagged phrase and produce ONE replacement that preserves meaning and matches surrounding tone.

Meaning contract (обязателен):

- Сохраняются: утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр формальности.
- Запрещено выдумывать числа, имена, даты, личный опыт, причины. Если утверждению не хватает конкретики, а во входных данных её нет — пометить `[нужен факт: ...]`, не выдумывать.
- Удаление — только явных дубликатов и пустых фраз, не настоящих утверждений.

If the user provides surrounding context, match the register of the context.

## Output

Original: <the bad phrase>
Rewritten: <one alternative>

If the user has indicated they want options, provide 2–3 alternatives. Otherwise, exactly one.

Do NOT rewrite anything else. Do NOT explain the change unless asked.

User input follows.

$@
