---
type: pattern
tags: [pattern, catalogue, comprehensive, bilingual]
created: 2026-06-28
status: active
sources: [Aboudjem-humanizer, harshaneel-humanize, wikipedia-en, wikipedia-ru]
related: [lexicon-ru-v2, deeprichastnye-oboroty, em-dash, parallel-clauses]
---

# Полный каталог: 43 паттерна AI-текста

> [!warning] Про методологию и ограничения
> Каталог собран из `Aboudjem/humanizer-skill` (43 паттерна, MIT, 98 ★), `harshaneel/humanize`, Wikipedia EN/RU, академической литературы.
>
> Паттерны помогают читателю-человеку не считать текст AI-генерацией. Они не гарантируют прохождение обученных детекторов (Pangram, GPTZero, Grammarly). Против них статические правила имеют ceiling. MASH (ACL 2026) показал, что лучший hybrid подход даёт максимум 92% ASR на старых детекторах, и почти не работает на новых.
>
> Применяйте для собственного текста в повседневном стиле. Не применяйте для академического, юридического, политического/дипломатического текста или переводов.
>
> См. `05-References/limits-and-self-critique.md` для полной самокритики.

## P1 — Significance Inflation (Раздувание значимости)

**EN:** "pivotal moment", "is a testament to", "serves as a reminder"
**RU:** «служит напоминанием», «является свидетельством», «ключевой поворотный момент», «неизгладимый след»

## P2 — Notability Name-Dropping (Имена ради значимости)

**EN:** "featured in", "active social media presence"
**RU:** «освещалось в Forbes», «активно ведёт соцсети», «упоминалось в СМИ»

## P3 — Superficial -ing Phrases (Поверхностные -ing/-ание/-ение)

**EN:** "highlighting", "ensuring", "fostering"
**RU:** «обеспечивая», «способствуя», «формируя», «подчёркивая»

→ Подробнее: [[deeprichastnye-oboroty]]

## P4 — Promotional Language (Рекламный язык)

**EN:** "cutting-edge", "seamless", "world-class", "nestled"
**RU:** «богатый», «яркий», «расположенный в самом сердце», «вековое наследие»

## P5 — Vague Attributions (Размытые атрибуции)

**EN:** "Experts argue", "Research suggests" (no citation)
**RU:** «Эксперты считают», «Исследования показывают» (без ссылки)

## P6 — Formulaic Challenges (Шаблонные вызовы)

**EN:** "Despite challenges, continues to thrive"
**RU:** «Несмотря на трудности, продолжает развиваться»

## P7 — AI Vocabulary (Словарь AI)

**EN:** "delve", "leverage", "multifaceted", "tapestry"
**RU:** углубляться, использовать, многогранный, гобелен

→ Полный список: [[lexicon-ru-v2]]

## P8 — Copula Avoidance (Избегание связки «is/are»)

**EN:** "serves as" instead of "is", "functions as" instead of "acts as"
**RU:** «представляет собой» вместо «является», «выступает в качестве» вместо «— это»

## P9 — Negative Parallelisms (Негативные параллелизмы)

**EN:** "It's not just X, it's Y", "It's not X, but Y"
**RU:** «Это не просто X, а Y», «Не X, а скорее Y»

> [!danger] Самый сильный AI-маркер
> Washington Post (2024): **#1 маркер** среди 328 744 сообщений ChatGPT. Появляется в **43%** AI-текстов, в **3%** человеческих. Плотность у LLM: 5–15 на 1000 слов, у человека: 0–1.
>
> **Пример:** «MathCodingFractal — это не „ещё одна методология". Это инфраструктура...» — катастрофический AI-сигнал (AP = 83).
>
> → Подробная методичка и алгоритм замены: [[../rhetorical/negative-parallelisms]]

## P10 — Rule of Three (Правило трёх)

**EN:** "innovation, inspiration, and insights"
**RU:** «быстро, надёжно, безопасно»

→ Подробнее: [[../structural/three-part-lists]]

## P11 — Synonym Cycling (Синоним-цикл)

**EN:** protagonist → main character → central figure
**RU:** герой → главный персонаж → протагонист

## P12 — False Ranges (Ложные диапазоны)

**EN:** "From X to Y" on non-spectrums
**RU:** «От X до Y» на несравнимых вещах

## P13 — Em Dash Ban / Overuse (Злоупотребление em-dash)

**EN/RU:** 3–5× выше нормы. **Главный маркер LLM.**

→ Подробнее: [[em-dash]]

## P14 — Boldface Overuse (Чрезмерный жирный шрифт)

**EN/RU:** выделение каждого ключевого слова в markdown

## P15 — Structured List Syndrome (Синдром структурированных списков)

**EN/RU:** превращение любого текста в bullet-список

## P16 — Title Case Headings (Заголовки в Title Case)

**EN:** "Strategic Negotiations And Global Partnerships"
**RU:** «Стратегические Партнёрства И Глобальное Расширение» (в русском это особенно неестественно)

## P17 — Typographic Tells (Типографические маркеры)

**EN/RU:** curly quotes, consistent Oxford comma

## P18 — Formal Register Overuse (Канцелярит)

**EN:** "it should be noted that", "it is essential to"
**RU:** «стоит отметить», «следует учитывать», «необходимо подчеркнуть»

→ Подробнее: [[lexicon-ru-v2]]

## P19 — Chatbot Artifacts (Артефакты чатбота)

**EN:** "I hope this helps!", "Certainly!"
**RU:** «С удовольствием помогу!», «Конечно!», «Надеюсь, это пригодится!»

## P20 — Knowledge-Cutoff Disclaimers (Дисклеймеры о дате обучения)

**EN:** "As of [date]", "based on available information"
**RU:** «По данным на [дата]», «Согласно доступной информации»

## P21 — Sycophantic Tone (Заискивающий тон)

**EN:** "Great question!", "That's an excellent point!"
**RU:** «Прекрасный вопрос!», «Отличное замечание!»

## P22 — Filler Phrases (Фразы-наполнители)

**EN:** "In order to", "Due to the fact that"
**RU:** «Для того чтобы» (вместо «чтобы»), «В связи с тем что» (вместо «потому что»)

## P23 — Excessive Hedging (Избыточное хеджирование)

**EN:** "could potentially possibly"
**RU:** «мог бы, возможно, потенциально»

→ Подробнее: [[../../01-Patterns/rhetorical/hedging-language]]

## P24 — Generic Conclusions (Шаблонные заключения)

**EN:** "The future looks bright", "poised for growth"
**RU:** «Будущее выглядит светлым», «Готов к росту»

## P25 — Hallucination Markers (Маркеры галлюцинаций)

**EN:** fabricated dates, phantom citations
**RU:** выдуманные даты, фантомные ISBN/DOI

## P26 — Perfect/Error Alternation (Чередование идеальности и ошибок)

**EN:** текст местами безупречен, местами странный — признак частичной AI-правки

## P27 — Question-Format Titles (Заголовки-вопросы)

**EN:** "What makes X unique?", "Why is Y important?"
**RU:** «Что делает X уникальным?», «Почему Y важен?»

## P28 — Markdown Bleeding (Утечка Markdown)

**EN/RU:** `**жирный**` в email, Word, обычных сообщениях

## P29 — "Comprehensive Overview" («Полный обзор»)

**EN:** "This guide delves into..."
**RU:** «В этом обзоре мы рассмотрим...»

## P30 — Uniform Sentence Length (Однородная длина предложений)

**EN/RU:** все предложения 15–20 слов, нет разнообразия

→ Подробнее: [[../../02-Techniques/perplexity-and-burstiness]]

## P31 — Elegant Variation (Изящное варьирование)

**EN:** "the artist" → "the visionary creator" → "the non-conformist painter"
**RU:** «художник» → «мастер» → «творец»

## P32 — Collaborative Communication Leaking (Утечка чат-коммуникации)

**EN:** "In this article, we will explore"
**RU:** «В этой статье мы рассмотрим», «Давайте разберёмся»

## P33 — Placeholder Text / Mad Libs (Заполнители)

**EN:** `[Your Name]`, `[INSERT SOURCE URL]`
**RU:** `[Ваше имя]`, `[ВСТАВИТЬ ССЫЛКУ]`

## P34 — Chatbot Reference Markup Leaking (Утечка разметки чатбота)

**EN:** `citeturn0search0`, `oai_citation`, broken footnote refs
**RU:** редко, но бывает в переводах с английского

## P35 — UTM Source Parameters (UTM-метки)

**EN:** `utm_source=chatgpt.com`
**RU:** нерелевантно

## P36 — Sudden Style/Register Shift (Резкий сдвиг стиля)

**EN/RU:** формальный текст резко переходит в разговорный (или наоборот)

## P37 — Overattribution (Избыточная атрибуция)

**EN:** "Featured in Wired, Refinery29, and other outlets"
**RU:** «Освещалось в Forbes, Bloomberg и Fortune» (без конкретики что)

## P38 — Paragraph-Reshuffling Immunity (Устойчивость к перестановке)

**EN/RU:** абзацы можно менять местами без потери смысла — нет сквозной логики

## P39 — "Whether" Paragraph Closers («Является ли X или Y, ответ — Z»)

**EN:** "Whether you prefer X or Y, the answer is..."
**RU:** «Независимо от того, X это или Y, ответ — Z»

## P40 — Symbolic Gloss / Meaning-Telling (Символическое объяснение)

**EN:** "represents", "symbolizes", "speaks to broader"
**RU:** «символизирует», «олицетворяет», «говорит о более широком»

## P41 — Infomercial Engagement Hooks (Рекламные крючки)

**EN:** "The catch?", "The kicker?", "Here's the thing."
**RU:** «Ловушка?», «Фишка?», «В чём суть?»

## P42 — Erratic Inline Bolding (Хаотичный inline-bold)

**EN/RU:** случайные выделения жирным в середине предложений без логики

## P43 — The Treadmill Effect (Эффект беговой дорожки)

**EN:** "In other words", "Put simply", "Essentially" — повтор одной мысли разными словами
**RU:** «Другими словами», «Проще говоря», «По сути»

## Категории по группам

| Группа | Паттерны |
|---|---|
| Content (содержание) | P1, P2, P3, P4, P5, P6, P7, P8 |
| Language (язык) | P9, P10, P11, P12, P13, P14, P15, P16, P17, P18 |
| Communication (коммуникация) | P19, P20, P21 |
| Filler (наполнители) | P22, P23, P24, P25, P26, P27, P28, P29, P30 |
| Emerging (новые, 2025–2026) | P31, P32, P33, P34, P35, P36, P37, P38, P39, P40, P41, P42, P43 |

## Метрика

> **P = (число активных паттернов / 43) × 100**

- 0–3 паттерна: вероятно, человек
- 4–8: смешанный
- 9–15: скорее всего AI
- 16+: точно AI

## Связанные заметки

- [[lexicon-ru-v2]]
- [[deeprichastnye-oboroty]]
- [[em-dash]]
- [[parallel-clauses]]
- [[../structural/three-part-lists]]
- [[../rhetorical/hedging-language]]
- [[../rhetorical/negative-parallelisms]] — **главный AI-маркер**
- [[../../02-Techniques/perplexity-and-burstiness]]
- [[../../02-Techniques/voice-and-tone]]
- [[../../02-Techniques/show-dont-tell]]