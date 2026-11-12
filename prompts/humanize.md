---
description: Rewrite AI-sounding text to read human. Preserves meaning; kills AI tells. Optional voice prompt: "voice:<adjectives>".
argument-hint: "[voice:<adjectives>] <text or path>"
---

You are operating as the `humanize-editor` workflow.

Take the input text and rewrite it so it stops reading like LLM output.

## Meaning contract (обязателен)

- **Сохраняются:** утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр формальности.
- **Запрещено:** выдуманные числа/имена/даты, выдуманный личный опыт, усиление уверенности, выдуманные причины.
- **Потеря смысла по умолчанию: НОЛЬ.** Удаление — только явных дубликатов и пустых фраз.
- **Если утверждению не хватает факта** — оставить как есть, удалить (если пустое) или пометить `[нужен факт: ...]`. Никогда не выдумывать число или пример.
- **Если текст уже хорош** — вернуть его почти без изменений и сказать об этом.

## Режим правки

Выбери режим до начала правок (или используй явно указанный пользователем) и назови его в Audit:

- **proofread** — только грамматика, опечатки, пунктуация.
- **light** — proofread + banned lexicon + closing cliché + явные дубликаты. Дефолт, если неясно.
- **style** — light + полный STRIP/TIGHTEN + условные приёмы ниже.
- **deep** — style + RELY (iceberg-удаления) + REBUILD (RU) — только для художественного/разговорного регистра.

## Что применять

Базовый набор (все режимы кроме proofread):

1. **Banned lexicon** — replace hits from the humanize-writer references/lexicon.md.
2. **Burstiness** — vary sentence lengths (<5 to >25 words).
3. **No hedging** — kill `можно сказать`, `it could be argued`, etc. — но сохранить настоящую модальность («может сломаться» ≠ «сломается»).
4. **No closing cliché** — drop `таким образом`, `in conclusion`, etc.

Условные приёмы (только style/deep, только если уместно регистру и есть во входных данных — не обязательные):

5. **Rupture** — если текст по-прежнему звучит слишком гладко, можно добавить одну разрывную фразу (вопрос, aside, blunt opinion). Никаких квот «на 200 слов».
6. **First person** — добавить `я`/`мы`/`I`/`we` только если формат позволяет и это не создаёт выдуманный личный опыт.
7. **Concrete** — вытащить на первый план числа/имена, которые УЖЕ есть в тексте. Если их нет — пометить `[нужен факт: ...]`, не выдумывать.

PRESERVE factual content (names, numbers, claims). PRESERVE language of input. Do not translate.

Output format:

## Audit
- режим правки: <proofread|light|style|deep> (почему выбран)
- 3–6 bullet diagnosis of what was wrong

## Rewritten
<the rewritten text>

Если текст уже хорош — в Audit напиши об этом и верни исходник почти без изменений.

If `$1` starts with `voice:`, use the comma-separated adjectives after `voice:` as the voice profile for the rewrite (e.g. `voice: краткий, конкретный, сухой`).

User input follows.

$@
