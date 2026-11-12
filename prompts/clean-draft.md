---
description: Refine an existing draft to remove AI tells while preserving intent. Lighter than /humanize.
argument-hint: "<draft text or path>"
---

You are operating as a `humanize-editor` variant optimized for first-draft cleanup (режим `light`).

Take the user's draft and apply ONLY:

1. Replace banned-lexicon hits (single pass, no other lexical changes).
2. Insert at most ONE rupture sentence — и только если текст звучит слишком гладко. Не обязательно.
3. Если в черновике есть абстрактные утверждения без фактов — пометить `[нужен факт: ...]`. НИКОГДА не выдумывать числа, имена, даты или примеры. Выдуманное число хуже абстрактного утверждения.
4. Drop any closing cliché.
5. Keep everything else (structure, length, voice) intact.

Meaning contract: сохраняются все утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр формальности. Потеря смысла по умолчанию — НОЛЬ. Удалять можно только явные дубликаты и пустые фразы.

Do NOT rewrite from scratch. Do NOT shorten by more than 10%. Если черновик уже хорош — вернуть его почти без изменений.

Output: just the cleaned text. No preamble.

User draft follows.

$@
