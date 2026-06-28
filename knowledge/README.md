---
type: moc
tags: [moc, index]
created: 2026-06-28
status: active
---

# AgentWritingBase. MOC

> База знаний о методах написания текстов, свободных от типичных AI-паттернов. Используется как источник истины при разработке skill'ов и prompt-шаблонов для [[opencode]] и [[pi]].

## Зачем это нужно

Агенты регулярно пишут тексты: документация, README, посты, письма, отчёты. Проблема в том, что результат звучит «как из ChatGPT»: одинаковая ритмика, предсказуемая лексика, «прилизанная» структура с буллетами там, где нужен связный текст. Читатель это чувствует, а детекторы вроде [[GPTZero]], [[ZeroGPT]], [[Originality.ai]] и [[GigaCheck]] это подтверждают числом.

Цель базы — собрать проверенные методы и превратить их в работающие [[skills]]. Не для обмана детекторов, а для написания текстов, которые звучат живо. Подробнее в [[05-References/limits-and-self-critique]].

## Структура

```
00-Inbox              — сырые идеи
01-Patterns/          — каталог AI-паттернов (43 шт. из Aboudjem + RU-специфика)
   ├─ lexical/         — словари AI-клише (RU + EN)
   ├─ structural/      — структурные паттерны
   ├─ rhetorical/      — риторика и стиль
   └─ 43-patterns-catalogue.md  — полный каталог P1–P43
02-Techniques/        — приёмы и техники замены
03-Detection/         — детекторы (как работают + публичные + русские)
04-Examples/          — до/после (RU + EN)
05-References/        — внешние источники и самокритика
06-Sources/           — скачанные файлы-первоисточники
templates/            — шаблоны заметок
```

## Ключевые заметки

### Паттерны — что именно выдаёт AI

- [[01-Patterns/43-patterns-catalogue]] — полный каталог 43 паттернов, основа всего
- [[01-Patterns/lexical/lexicon-ru-v2]] — расширенный словарь русских AI-клише, v2 с правками после Wikipedia RU
- [[01-Patterns/lexical/lexicon-ru]] — базовая версия словаря
- [[01-Patterns/lexical/lexicon-en]] — словарь AI-клише в английском
- [[01-Patterns/structural/three-part-lists]] — rule of three
- [[01-Patterns/structural/parallelism]] — симметрия и параллелизм
- [[01-Patterns/structural/parallel-clauses]] — парные синонимы в русском («цели и задачи»)
- [[01-Patterns/structural/em-dash]] — em-dash как главный AI-маркер пунктуации
- [[01-Patterns/rhetorical/hedging-language]] — хеджирование
- [[01-Patterns/rhetorical/impersonality]] — потеря автора
- [[01-Patterns/rhetorical/deeprichastnye-oboroty]] — деепричастия в русском
- [[01-Patterns/rhetorical/negative-parallelisms]] — конструкции «это не X, а Y», главный AI-маркер по Washington Post 2024

### Техники — что делать вместо AI-паттернов

- [[02-Techniques/perplexity-and-burstiness]] — фундамент: perplexity и burstiness
- [[02-Techniques/voice-and-tone]] — как найти голос
- [[02-Techniques/voice-russian-specifics]] — особенности голоса в русском
- [[02-Techniques/show-dont-tell]] — конкретика вместо абстракций
- [[02-Techniques/agent-writing-workflow]] — алгоритм Pre-flight → Write → Audit

### Детекторы

- [[03-Detection/how-detectors-work]] — как работают детекторы
- [[03-Detection/public-detectors]] — публичные инструменты (EN)
- [[03-Detection/russian-detectors]] — детекторы для русского

### Примеры

- [[04-Examples/before-after]] — базовые примеры RU и EN
- [[04-Examples/before-after-ru-advanced]] — расширенные примеры для русского, 7 кейсов

### Рефлексия и границы

- [[05-References/limits-and-self-critique]] — эпистемический анализ: что мы знаем, что нет, где skill'ы работают. Обязательно прочитать.

### Источники

- [[06-Sources/README]] — реестр скачанных первоисточников
- `06-Sources/fabric/` — паттерны Daniel Miessler, MIT
- `06-Sources/anthropic-skills_*` — примеры skill'ов Anthropic
- `06-Sources/pi-skills_*` — примеры skill'ов для pi
- `06-Sources/github-humanizers/` — Aboudjem/humanizer-skill (43 паттерна), harshaneel/humanize (9 levers)
- `06-Sources/ru-wikipedia-ai-signs.txt` — полный текст ВП:ПРГЕН

## Конвенции

Имена файлов пишем в `kebab-case`. Каждая заметка начинается с YAML frontmatter (`type`, `tags`, `created`, `status`). Связи между заметками через `[[wikilinks]]` (стандарт Obsidian). Теги плоские: `moc`, `pattern`, `technique`, `lexical`, `structural`, `rhetorical`, `example`, `reference`, `detection`, `ru`, `en`, `bilingual`, `catalogue`. Для длинных заметок используем `## Heading` и callout'ы `> [!note]`, `> [!warning]`, `> [!example]`. Шаблон новой заметки лежит в `templates/note-template.md`.

## Статус базы

- Структура создана
- MOC и индекс на месте
- Лексические паттерны заполнены (RU + EN, v1 + v2)
- Структурные паттерны заполнены (rule of three, parallelism, em-dash, parallel-clauses)
- Риторические паттерны заполнены (hedging, impersonality, deeprichastnye)
- Каталог 43 паттернов готов (P1–P43)
- Техники замены описаны (voice, perplexity, show-dont-tell)
- Примеры до/после собраны (RU базовые + расширенные, EN)
- Первоисточники скачаны и описаны (Fabric, Anthropic, Pi skills, Aboudjem, harshaneel, lynote-ai, Wikipedia RU)
- Skill'и для opencode установлены
- Skill'и и prompt-templates для pi установлены
- Регулярный аудит при обновлении upstream (Aboudjem и harshaneel активно развиваются)

## Ключевые выводы исследования

> [!important] Самокритика
> Skill'ы, которые лежат в `~/.config/opencode/skills/` и `~/.pi/agent/skills/`, это **литературный редактор**, а не детектор-обходчик. Они помогают писать лучше, а не скрывать происхождение AI-генерации. Подробнее в [[05-References/limits-and-self-critique]].

### Из Aboudjem (43 паттерна)

Главные маркеры: em-dash в 3–5 раз выше нормы, rule of three, hedging, copula avoidance, поверхностный анализ через деепричастия. Детекторы ловят статистическое распределение, а не отдельные слова. Burstiness и конкретика — единственные надёжные методы.

### Из harshaneel (9 levers)

Lever 9 (Strip RLHF voice) — самое важное открытие 2025–2026. Детекторы ловят не «AI-ness» в тексте, а RLHF-артефакты: политкорректность, балансы, структурные перечисления. Iterative paraphrase даёт лучшие результаты для high-stakes. Base-model paraphraser превосходит rule-based approaches по последним данным.

### Из Wikipedia RU

Поверхностный анализ с деепричастиями особенно остро стоит в русском. Парные синонимы через «и» («цели и задачи») — паттерн, для которого нет английского аналога. Канцелярит и отглагольные существительные остаются главными стилистическими маркерами.

### Из академии

Binoculars (arXiv 2401.12070) — лучший zero-shot детектор (90%+ accuracy). Watermarking (arXiv 2301.10226) даёт >99% AUROC, но требует доступа к модели. MASH (arXiv 2601.08564, ACL 2026) показал ceiling 92% ASR на старых детекторах через static surface rewriting, против новых почти не работает.