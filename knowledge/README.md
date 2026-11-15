---
type: moc
tags: [moc, index]
created: 2026-06-28
status: active
---

# AgentWritingBase. MOC

> База знаний о методах написания и **редактуры** текстов, свободных от типичных AI-паттернов. Используется как источник истины при разработке skill'ов и prompt-шаблонов для opencode и pi.

## Зачем это нужно

Агенты регулярно пишут и правят тексты: документация, README, посты, письма, отчёты. Проблема в том, что результат звучит «как из ChatGPT»: одинаковая ритмика, предсказуемая лексика, «прилизанная» структура с буллетами там, где нужен связный текст.

Но вторая, более опасная проблема: правка, которая меняет слова и при этом меняет смысл: ослабляет условие, усиливает уверенность, выдумывает число. Текст читается лучше и говорит другое.

Цель базы: собрать проверенные методы и превратить их в работающие skills. Это **литературный редактор, а не обход детекторов**: мы помогаем писать и править так, чтобы текст оставался живым и при этом говорил ровно то же, что и до правки. Подробнее в [[05-References/limits-and-self-critique]].

## Структура

**41 заметка** (без `06-Sources/` и `templates/`):

```
00-Inbox             : сырые идеи
01-Patterns/         : 15 заметок: каталог AI-паттернов (43 шт. из Aboudjem + RU-спецификация)
   ├─ lexical/        : словари AI-клише (RU + EN)
   ├─ structural/     : структурные паттерны
   ├─ rhetorical/     : риторика и стиль
   └─ 43-patterns-catalogue.md : полный каталог P1–P43
02-Techniques/       : 15 заметок: приёмы и техники замены + смысловой контракт v7
03-Detection/        : 3 заметки: детекторы (как работают + публичные + русские)
04-Examples/         : 6 заметок: до/после (RU + EN)
05-References/       : 1 заметка: внешние источники и самокритика
06-Sources/          : скачанные файлы-первоисточники
templates/           : шаблоны заметок
README.md            : этот MOC
```

## Ключевые заметки

### Паттерны: что именно выдаёт AI

- [[01-Patterns/43-patterns-catalogue]]: полный каталог 43 паттернов, основа всего
- [[01-Patterns/catalogue-update]]: **NEW**: P-NEW-13…P-NEW-20, 8 паттернов вне исходных 43 (false agency, argument residue, mini-aphorism closers и др.)
- [[01-Patterns/lexical/lexicon-ru-v2]]: расширенный словарь русских AI-клише, v2 с правками после Wikipedia RU
- [[01-Patterns/lexical/lexicon-ru]]: базовая версия словаря
- [[01-Patterns/lexical/lexicon-en]]: словарь AI-клише в английском
- [[01-Patterns/structural/three-part-lists]]: rule of three
- [[01-Patterns/structural/parallelism]]: симметрия и параллелизм
- [[01-Patterns/structural/parallel-clauses]]: парные синонимы в русском («цели и задачи»)
- [[01-Patterns/structural/em-dash]]: em-dash как главный AI-маркер пунктуации
- [[01-Patterns/structural/format-and-rlhf-bias]]: **NEW**: P-NEW-8…P-NEW-12, format bias и RLHF-артефакты
- [[01-Patterns/rhetorical/hedging-language]]: хеджирование
- [[01-Patterns/rhetorical/impersonality]]: потеря автора
- [[01-Patterns/rhetorical/deeprichastnye-oboroty]]: деепричастия в русском
- [[01-Patterns/rhetorical/negative-parallelisms]]: конструкции «это не X, а Y», главный AI-маркер по Washington Post 2024

### Ядро v7: правка сохраняет смысл

- [[02-Techniques/meaning-preservation]]: **NEW v7**: meaning_map и двусторонняя сверка смысла; нулевая потеря утверждений, запрет выдуманных фактов
- [[02-Techniques/editing-modes]]: **NEW v7**: режимы proofread / light / style / deep и границы применения фаз STRIP/TIGHTEN/RELY/REBUILD
- [[02-Techniques/russian-copyediting]]: **NEW v7**: этап COPYEDIT для русского: грамматика, управление, модальность, 24 пары ошибка→исправление
- [[02-Techniques/genre-profiles]]: **NEW v7**: пять жанровых профилей (academic, legal, marketing, support, technical-docs) с перечнем того, что в каждом жанре можно и нельзя трогать
- [[02-Techniques/ru-corpus-collection]]: **NEW v7**: как собрать настоящий RU-корпус LLM-генераций (сейчас 8 human / 12 синтетических) и что после этого изменится в метриках
- [[02-Techniques/metric-validation]]: **NEW v7**: калибровка порогов на 145 размеченных текстах, языково-зависимые пороги, Cohen's d, смещение синтетической RU-выборки

### Техники: базовый слой

- [[02-Techniques/perplexity-and-burstiness]]: фундамент: perplexity и burstiness
- [[02-Techniques/voice-and-tone]]: как найти голос
- [[02-Techniques/voice-russian-specifics]]: особенности голоса в русском
- [[02-Techniques/show-dont-tell]]: конкретика вместо абстракций
- [[02-Techniques/sufficiency-and-underspecification]]: **NEW**: когда сказать меньше, чем знаешь (Grice, Hemingway, Chekhov, Williams), и когда недосказанность применять нельзя
- [[02-Techniques/length-bias-research]]: **NEW**: академический обзор length bias в RLHF (Park, Shen, Zhang, Lamparth, Huang)
- [[02-Techniques/russian-brevity-grammar]]: **NEW**: парцелляция, эллипсис, литота как русские грамматические инструменты краткости
- [[02-Techniques/laconic-prose-models]]: **NEW**: Толстой, Довлатов, Шкловский, Бунин как эталонные модели русской краткости
- [[02-Techniques/agent-writing-workflow]]: алгоритм Pre-flight → Write → Audit

### Структурные паттерны

- [[01-Patterns/structural/three-part-lists]]: rule of three
- [[01-Patterns/structural/parallelism]]: симметрия и параллелизм
- [[01-Patterns/structural/parallel-clauses]]: парные синонимы в русском
- [[01-Patterns/structural/em-dash]]: em-dash как главный AI-маркер пунктуации
- [[01-Patterns/structural/over-generation]]: **NEW**: пере-говорение (P-NEW-1…P-NEW-7), vacuum-filling, restatement chains, bridging, over-explanation, anticipatory hedging, balanced framing, antithetical recap

### Детекторы

- [[03-Detection/how-detectors-work]]: как работают детекторы
- [[03-Detection/public-detectors]]: публичные инструменты (EN)
- [[03-Detection/russian-detectors]]: детекторы для русского

### Примеры

- [[04-Examples/before-after]]: базовые примеры RU и EN
- [[04-Examples/before-after-ru-advanced]]: расширенные примеры для русского, 7 кейсов
- [[04-Examples/tightening/README]]: 5 кейсов Lever 10 (TIGHTEN) с замерами
- [[04-Examples/iceberg/README]]: 3 кейса Lever 11 (RELY / iceberg)
- [[04-Examples/russian-grammar/README]]: 6 кейсов Lever 12 (REBUILD)

### Рефлексия и границы

- [[05-References/limits-and-self-critique]]: эпистемологический анализ: что мы знаем, что нет, где skill'ы работают. Обязательно прочитать.

### Источники

- [[06-Sources/README]]: реестр скачанных первоисточников
- `06-Sources/fabric/`: паттерны Daniel Miessler, MIT
- `06-Sources/anthropic-skills_*`: примеры skill'ов Anthropic
- `06-Sources/pi-skills_*`: примеры skill'ов для pi
- `06-Sources/github-humanizers/`: Aboudjem/humanizer-skill (43 паттерна), harshaneel/humanize (9 базовых levers)
- `06-Sources/web-fetches/laconic-prose/`: Шкловский, Лотман, Гаспаров, Аверинцев для Lever 12
- `06-Sources/ru-wikipedia-ai-signs.txt`: полный текст ВП:ПРГЕН

## Конвенции

Имена файлов пишем в `kebab-case`. Каждая заметка начинается с YAML frontmatter (`type`, `tags`, `created`, `status`). Связи между заметками через `wikilinks` (стандарт Obsidian). Теги плоские: `moc`, `pattern`, `technique`, `lexical`, `structural`, `rhetorical`, `example`, `reference`, `detection`, `ru`, `en`, `bilingual`, `catalogue`. Для длинных заметок используем `## Heading` и callout'ы `> [!note]`, `> [!warning]`, `> [!example]`. Шаблон новой заметки лежит в `templates/note-template.md`.

## Статус базы

- Структура создана; MOC и индекс на месте
- **41 заметка**: 01-Patterns: 15, 02-Techniques: 15, 03-Detection: 3, 04-Examples: 6, 05-References: 1, README.md: 1
- Лексические паттерны заполнены (RU + EN, v1 + v2)
- Структурные паттерны заполнены (rule of three, parallelism, em-dash, parallel-clauses, **over-generation 2026-07**, **format-and-rlhf-bias 2026-07**)
- Риторические паттерны заполнены (hedging, impersonality, deeprichastnye)
- Каталог 43 паттернов готов (P1–P43) + класс P-NEW 1–20 (over-generation + format/RLHF + 8 паттернов из catalogue-update)
- Ядро v7 описано: [[02-Techniques/meaning-preservation]], [[02-Techniques/editing-modes]], [[02-Techniques/russian-copyediting]], [[02-Techniques/genre-profiles]], [[02-Techniques/ru-corpus-collection]]
- Базовый слой техник описан (voice, perplexity, show-dont-tell, sufficiency/underspecification, length bias, Russian brevity grammar, laconic prose models, metric validation)
- Source notes для Шкловского, Лотмана, Гаспарова, Аверинцева получили дословные цитаты из оригиналов (Phase 3 закрыт на уровне ключевых работ; дальше выписки)
- Примеры до/после собраны (tightening, iceberg, Russian grammar, Kholstomer example)
- Первоисточники скачаны и описаны (Fabric, Anthropic, Pi skills, Aboudjem, harshaneel, lynote-ai, Wikipedia RU, arXiv length-bias, Шкловский/Лотман/Гаспаров/Аверинцев)
- **Skill'ы синхронизированы до v7.0.0** (4 штуки: humanize-writer, humanize-editor, anti-ai-auditor, ai-pattern-rewriter) и 9 prompt-шаблонов; смысловой контракт: нулевая потеря утверждений, запрет выдуманных фактов, режимы proofread/light/style/deep, RELY только в style/deep, возврат хорошего текста без правок
- **Поведенческий корпус редактуры** `tests/fixtures/editing/`: 24 кейса (ловушки на модальность, условия, выдумки + 3 кейса «уже хорошего текста»), проверка: `scripts/test-editing-fixtures.sh`
- **Валидаторы**: `scripts/check-editing-output.sh` (9 инвариантов смыслового контракта + `--selftest`), `scripts/check-examples-facts.sh`, `scripts/check-examples-coverage.sh`, `scripts/check-no-stale-contract.sh`
- **Слой доказательств math-coding**: `spec.json` (schema v5), **12 claims** с negative controls, `mathc run`: green
- Метрики откалиброваны на 145 размеченных текстах (HC3/RAID/Wikisource + синтетика), пороги стали языково-зависимыми; **RU-корпус мал**: 8 human / 12 AI, RU-пороги пока гипотеза
- Skill'ы и prompt-templates для pi установлены
- Регулярный аудит при обновлении upstream (Aboudjem и harshaneel активно развиваются)

## Ключевые выводы исследования

> [!important] Самокритика
> Skill'ы, которые лежат в `~/.config/opencode/skills/` и `~/.pi/agent/skills/`, это **литературный редактор**, а не детектор-обходчик. Они помогают писать лучше, а не скрывать происхождение AI-генерации. Подробнее в [[05-References/limits-and-self-critique]].

### Главный вывод v7: правка сохраняет смысл

Каждый приём, который делает текст «живее», таит в себе искажение. Конкретизация соблазняет выдумать число, iceberg-удаление — выбросить условие, перефразирование — заменить «может снижать» на «снижает». Поэтому v7 строит правку вокруг одного инварианта:

- **Сохраняются** утверждения, числа и их отношения, условия, исключения, отрицания, модальность, терминология, цитаты, регистр.
- **Запрещено** выдумывать факты, опыт, уверенность и причины. Не хватает данных → `[нужен факт: ...]`.
- **Ошибка**: потеря любого утверждения, выдумка или снятая модальность. Порога «10% фактов» больше нет: по умолчанию ноль.
- **Глубина** задаётся режимом: `proofread` / `light` / `style` / `deep`; RELY (iceberg): только в `style`/`deep` и только для художественного или разговорного регистра.
- **Хороший текст можно вернуть почти без изменений**, это допустимый результат, а не недостаток работы.
- **Метрики дают диагностику**, а не вердикт «AI / не AI».

Механическое ядро этого контракта: [[02-Techniques/meaning-preservation]] и [[02-Techniques/editing-modes]].

### Из Aboudjem (43 паттерна)

Главные маркеры: em-dash в 3–5 раз выше нормы, rule of three, hedging, copula avoidance, поверхностный анализ через деепричастия. Детекторы ловят статистическое распределение, а не отдельные слова. Burstiness и конкретика остаются единственными надёжными методами.

### Из harshaneel (9 levers)

Lever 9 (Strip RLHF voice): самое важное открытие 2025–2026. Детекторы ловят не «AI-ness» в тексте, а RLHF-артефакты: политкорректность, балансы, структурные перечисления. Iterative paraphrase даёт лучшие результаты для high-stakes. Base-model paraphraser превосходит rule-based approaches по последним данным.

### Из Wikipedia RU

Поверхностный анализ с деепричастиями особенно остро стоит в русском. Парные синонимы через «и» («цели и задачи»): паттерн, для которого нет английского аналога. Канцелярит и отглагольные существительные остаются главными стилистическими маркерами. **Литота**: русская традиция преуменьшения, отсутствующая в LLM.

### Из академии

Binoculars (arXiv 2401.12070): лучший zero-shot детектор (90%+ accuracy). Watermarking (arXiv 2301.10226) даёт >99% AUROC, но требует доступа к модели. MASH (arXiv 2601.08564, ACL 2026) показал ceiling 92% ASR на старых детекторах через static surface rewriting, против новых почти не работает. **YapBench** (arXiv 2601.00624, январь 2026): эмпирически подтвердил length bias в 76 LLM. Не лечится списком запрещённых слов, требует положительного принципа суффицентности.

### Из литературной теории и стилистики

Суффицентность задаёт минимум: сказать ровно столько, сколько нужно. Gricean Maxim of Quantity submaxim 2: «Do not make your contribution more informative than is required». Hemingway's iceberg оставляет читателю работу. Chekhov's gun и Strunk & White режут лишнее. Williams даёт 6 операций сокращения.

Русский слой v6 добавляет форму: Шкловский: остранение, Лотман: информационная плотность формы, Гаспаров: измеримость ритма, Аверинцев: жанровые границы. Подробнее: [[02-Techniques/sufficiency-and-underspecification]], [[02-Techniques/russian-brevity-grammar]], [[02-Techniques/laconic-prose-models]].

Слой v7 добавляет **правило**: суффицентность не отменяет сохранения смысла. Недосказанность допустима только там, где её разрешает режим, жанр и двусторонняя сверка `meaning_map`.
