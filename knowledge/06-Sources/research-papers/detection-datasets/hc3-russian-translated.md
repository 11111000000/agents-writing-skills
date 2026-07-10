---
type: source
fetched_at: 2026-07-09
url: https://huggingface.co/datasets/d0rj/HC3-ru
author: d0rj (translator)
year: 2023
source_type: dataset
applicability: medium
tags: [source, dataset, ai-vs-human, russian, translation]
status: draft
related: [[hc3-english]]
---

# HC3-ru — переведённая версия HC3 на русский

d0rj. License: CC-BY-SA-4.0. arXiv:2301.07597.

## TL;DR

Russian translation of HC3 via Google Translate. 24,322 rows, 62.7 MB. Same structure as English original.

## Caveats

> [!warning] Google Translate — это не human-written RU
> Translation через Google Translate привносит свои паттерны:
> - машинный перевод часто **длиннее** оригинала (по аналогии с over-generation у LLM)
> - может содержать англицизмы, кальки, неестественные конструкции
> - **«human_answers» здесь — это переведённые человеческие ответы**, а не свежие RU-ответы

**Implication:** использовать HC3-ru можно для сравнения переведённой человеческой прозы с переведённой ChatGPT-прозой. Это НЕ то же самое, что сравнение оригинальной русской прозы с оригинальной русской AI-прозой.

## Что есть

- 24,322 question-answer pairs
- 5 source domains: reddit_eli5, open_qa, wiki_csai, finance, medicine
- question + human_answers + chatgpt_answers
- License: CC-BY-SA-4.0 — можно использовать с указанием авторства

## Альтернативы для оригинального русского

Для подлинного RU-corpus нужно собирать вручную:
- **Habr статьи** (creativecommons-licensed, помеченные как авторские)
- **Telegram-каналы** известных авторов (с разрешения)
- **Живой Журнал** (русскоязычный, открытые блоги)
- **vc.ru / habr.com** комментарии и статьи

vs

- Свежие генерации GPT-4o / Claude 3.5 / YandexGPT / GigaChat на те же темы.

Это Phase 1.5 нашего плана (сбор собственного RU-корпуса).

## Connection to our work

- **Lower priority чем English HC3**, но всё же полезно:
  - Базовое сравнение "переведённый human vs переведённый ChatGPT".
  - Можно измерить, насколько перевод машинный/Google добавляет length bias.
- **Не использовать для ground-truth** наших метрик на русском.

## Raw notes

- 38 downloads last month — небольшая база, нишевая.
- Входит в коллекции `d0rj`: Instruct datasets in Russian, Instruct preference datasets in Russian.
- Citation: оригинальная статья Guo et al. 2023.