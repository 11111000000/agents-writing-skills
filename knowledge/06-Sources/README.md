---
type: reference
tags: [sources, registry, comprehensive]
created: 2026-06-28
status: active
---

# Реестр источников / Sources

> Все материалы, которые мы используем как первоисточники для skill'ов и промптов. Файлы скачаны в папку `06-Sources/`.

## Официальные источники skill-формата

| Источник | URL | Что взяли |
|---|---|---|
| Anthropic Skills | https://github.com/anthropics/skills | Шаблон SKILL.md, `doc-coauthoring`, `internal-comms`, `skill-creator` |
| Agent Skills spec | https://agentskills.io/specification | Спецификация frontmatter |
| OpenCode skills docs | https://opencode.ai/docs/skills/ | Специфика opencode |
| Pi skills docs | https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md | Специфика pi |
| Pi prompt-templates docs | https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/prompt-templates.md | Формат промпт-шаблонов |

## Локальные файлы (скачано в `06-Sources/`)

### Anthropic skills

- `anthropic-skills_doc-coauthoring-SKILL.md` — пример workflow-скилла
- `anthropic-skills_internal-comms-SKILL.md` — пример skill-каталога с подтипами
- `anthropic-skills_skill-creator-SKILL.md` — meta-skill для создания skill'ов
- `anthropic-skills_brand-guidelines-SKILL.md` — пример стилевого skill'а

### Fabric (Daniel Miessler)

- `fabric/extract_wisdom-system.md` — структурированный анализ текста
- `fabric/summarize-system.md` — суммаризация
- `fabric/create_micro_summary-system.md` — микро-резюме
- `fabric/create_newsletter_entry-system.md` — newsletter в стиле «внешнего наблюдателя»
- `fabric/improve_writing-system.md` — improve_writing (grammar/style)

### Pi-skills (badlogic)

- `pi-skills_youtube-transcript-SKILL.md` — пример skill'а для pi
- `pi-skills_transcribe-SKILL.md` — пример skill'а с внешним API

### GitHub humanizers (Новое!)

- `github-humanizers/Aboudjem_humanizer-skill.md` — **43 паттерна AI-текста, 5 voice profiles, MIT, 98 ★**. Каталог P1–P43 — наша основа для распознавания.
- `github-humanizers/harshaneel_humanize.md` — **9 humanization levers из detection-литературы, MIT, 56 ★**. Бенчмарк: 25 входов, средний score 5.24/27.
- `github-humanizers/harshaneel_ai-check.md` — forensic AI-detection skill (9 категорий сигналов, evidence-quoted flags).
- `github-humanizers/diaiq_claude-skill-humanizer.md` — humanizer через DiaIQ API (менее интересно, так как полагается на внешний сервис).
- `github-humanizers/lynote-ai_humanize-text.md` — основной опенсорс-проект humanizer (1424 ★).

### Wikipedia (русский + английский)

- `ru-wikipedia-ai-signs.txt` — **полный текст ВП:ПРГЕН**. Основа для всех русскоязычных паттернов.
- Wikipedia EN: https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing — основа для 70% паттернов P1–P30 в Aboudjem.

## Академические статьи

| arXiv ID | Название | Применение |
|---|---|---|
| 2301.10226 | A Watermark for Large Language Models (Kirchenbauer et al., 2023, ICML) | watermarking; нужна для контекста, но не помогает обнаруживать «человеческий» текст |
| 2401.12070 | Spotting LLMs With Binoculars (Hans et al., 2024, ICML) | **zero-shot detector, 90%+ accuracy at 0.01% FPR**. Используется harshaneel/humanize как baseline. |
| 2412.12710 | Disfluency Insertion (Hassan et al., 2024) | «запинки» в речи делают LLM-текст более человечным. Lever 9 в harshaneel/humanize. |
| 2601.08564 | MASH: Evading Black-Box AI Detectors (Gu et al., 2026, ACL Findings) | SOTA-метод обхода детекторов через style transfer (92% ASR). Говорит о том, что статические поверхностные правки имеют ceiling. |

## Использованные внешние ресурсы

| Категория | Источник | Зачем |
|---|---|---|
| Prompt engineering | https://github.com/dair-ai/Prompt-Engineering-Guide | Общие принципы |
| Fabric patterns | https://github.com/danielmiessler/Fabric/tree/main/data/patterns | Эталонные промпты |
| Anthropic skills | https://github.com/anthropics/skills | Эталонные skill'ы |
| Pi skills | https://github.com/badlogic/pi-skills | Эталонные skill'ы для pi |
| Humanizer-skill | https://github.com/Aboudjem/humanizer-skill | 43 паттерна, 5 voice profiles |
| Humanize (research) | https://github.com/harshaneel/humanize | 9 base levers, академические источники |
| Russian laconic prose | `web-fetches/laconic-prose/` | Шкловский, Лотман, Гаспаров, Аверинцев для Lever 12 |
| MASH paper | https://github.com/githigher/MASH | ACL 2026, SOTA-обход |
| Binoculars | https://github.com/ahans30/Binoculars | zero-shot detector |
| Lynote-ai | https://github.com/lynote-ai/humanize-text | humanizer с большой базой |

## Что НЕ использовали (и почему)

- **ZeroGPT, GPTZero как «источник правды»** — точность спорная, полагаемся на описание, а не на их результаты
- **Reddit/форумы** — нестабильные ссылки, использовали только как контекст
- **Блоги постов по SEO** — много пересказа, мало оригинального
- **habr.com / vc.ru** — без авторизации не отдают результаты поиска

## Лицензии

- Anthropic Skills — Apache 2.0 / source-available (для skills/doc*,skills/pdf*,skills/pptx*,skills/xlsx* — source-available, нельзя использовать в своих публичных продуктах; для остальных — Apache 2.0)
- Fabric patterns — MIT
- Pi-skills — MIT
- OpenCode / Pi — собственный код, MIT
- Aboudjem/humanizer-skill — MIT
- harshaneel/humanize — MIT
- diaiq/claude-skill-humanizer — MIT
- lynote-ai/humanize-text — проверьте LICENSE перед использованием
- githigher/MASH — research only
- Wikipedia content — CC BY-SA
- arXiv papers — non-exclusive distribution

> [!warning] Использование в продакшне
> Если планируете публиковать свои skill'ы — проверьте, что в них нет заимствованного кода из source-available skills Anthropic. Apache 2.0 и MIT — OK с указанием авторства.

## Ключевые тезисы из исследования

### Из Aboudjem (43 паттерна)

1. Главные маркеры: **em-dash (3–5× нормы), rule of three, hedging, copula avoidance, surface analysis (-ing/-ание)**.
2. Детекторы ловят не слова, а **статистическое распределение** — замены синонимами не помогают.
3. Burstiness и конкретика — единственные надёжные методы защиты.

### Из harshaneel (9 levers)

1. **Lever 9 (Strip RLHF voice)** — самый важный из обнаружённых в 2025–2026. Детекторы ловят не «AI-ness», а **RLHF-артефакты** (политкорректность, баланс, структурные перечисления).
2. **Iterative paraphrase** — лучшая техника для high-stakes.
3. Base-model paraphraser превосходит rule-based approaches по последним данным.

### Из Wikipedia RU

1. **Поверхностный анализ с деепричастиями** — особенно острая проблема в русском.
2. **Парные синонимы через «и»** — русский AI-паттерн без английского аналога.
3. **Канцелярит и отглагольные существительные** — главные стилистические маркеры.

### Из академии

1. **Binoculars** — самый надёжный zero-shot детектор (90%+ accuracy).
2. **Watermarking** — даёт >99% AUROC, но требует доступа к модели.
3. **RLHF-fingerprint** — самый современный механизм обнаружения (arXiv 2605.19516).