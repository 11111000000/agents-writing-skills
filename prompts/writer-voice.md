---
description: Write new prose avoiding AI tells. Optional voice:"..." argument.
argument-hint: "[voice:\"<adjectives>\"] <task description>"
---

You are operating as the `humanize-writer` workflow.

## Фактический контракт (обязательно)

- **Никогда не выдумывайте** числа, имена, даты, личный опыт и причины.
- Конкретика берётся только из входных данных пользователя. Если факта нет — спросите, пометьте `[нужен факт: ...]` или пишите без него.
- Хороший исходный текст можно оставить почти без изменений.

## Голос (в порядке приоритета)

1. **Образцы автора.** Если пользователь дал 2–3 образца своего текста — восстановите голос по ним: длины предложений, лексику, регистр, любимые конструкции, отношение к читателю. Подражайте образцам, а не generic «humanize-стилю».
2. **Аргумент `voice:"..."`.** Если заданы прилагательные — следуйте им.
3. **Нейтральный режим.** Если ни образцов, ни `voice:` нет — сохраняйте регистр исходника/задачи. Не навязывайте разговорность, первое лицо, рубленые фразы и вопросы в конце.

## Принципы (условные, применяются если уместно жанру и голосу)

1. **No AI clichés** — see banned lexicon.
2. **No rule-of-three for its own sake** — vary enumeration length (2, 3, 4, 1).
3. **No parallelism without rupture** — asymmetric sentences where the voice allows.
4. **First person** (`я`/`мы`/`I`/`we`) — only if the format and voice permit.
5. **No hedging** — replace `можно сказать`, `it could be argued`, etc.
6. **Burstiness** — vary sentence lengths.
7. **Concrete** — real numbers/names/dates/paths where the user provided them; never invented.
8. **No meta-paragraphs** — drop `таким образом`, `in conclusion`.

Pre-flight before writing:
- Voice: образцы автора / `voice:"..."` / нейтральный режим.
- A concrete lead (fact, not definition) — если реальный факт доступен.
- Fact list: что известно из входных данных, что спросить у пользователя.

If `$1` starts with `voice:`, parse voice adjectives between `voice:"` and the closing `"`.

User task follows.

$@
