---
type: pattern
tags: [pattern, structural, rhetorical, new, format-bias, rlhf-voice, biasedhedge]
created: 2026-07-10
status: active
related: [over-generation, deeprichastnye-oboroty, hedging-language, three-part-lists, lexicon-ru-v2, negative-parallelisms]
sources: [zhang-2024-format-bias, shen-2023-loose-lips, huang-2024-post-hoc-calibration, park-2024-disentangling-length-dpo]
---

# P-NEW-8…P-NEW-12 — Format, RLHF-voice, biased hedge (2026-07)

> [!info] Контекст
> После введения P-NEW-1…P-NEW-7 (структурного over-generation) обнаружился слой паттернов, который не лечится ни отказом от лишнего, ни увеличением burstiness. Это **формат-bias** и **RLHF-fingerprint**. Источники — Zhang et al. 2024, Shen et al. 2023, Huang et al. 2024, Park et al. 2024. Каталог P43 закрыт; P-NEW остаётся открытым классом.

## P-NEW-8. List-bloat (format bias)

**Что это:** лишние маркеры списков и bold ради ощущения «полноты».

**Маркеры:**
- Длинные bullet-списки из 8-15 элементов, где 3 последних — вариации уже сказанного.
- Каждый эмпирический факт выделен жирным или кодом внутри одного предложения.
- Emoji или заголовок-делитель на каждый смысловой блок.

**Пример:**

> ❌ «The system is **fast** (p99 < 50 ms), **reliable** (99.99% uptime), **scalable** (handles 10k req/s), **safe** (audited), and **easy to deploy** (single binary).»
>
> ✅ «p99 14 ms. 99.99% uptime. Single binary.»

**Связь:** Zhang et al. (2024) показали, что <1% затравки list/bold-разметки достаточно, чтобы индуцировать bias в SFT.

## P-NEW-9. Polite-hedge bleed (RLHF overlay)

**Что это:** вежливые хеджирующие фразы, которые читатель по привычке пропускает, но детекторы и bias-тесты учитывают.

**Маркеры:**
- «Of course,» «Certainly,» «I hope this helps,» «Sure!» в начале ответа.
- «This is a great question» перед любым содержательным блоком.
- «I'd be happy to assist with that» в начале и в конце.

**Пример:**

> ❌ «Great question! I'd be happy to help with that. Let's dive in. … Sure thing, hope this helps!»
>
> ✅ (без вступительного реверанса; сразу содержание)

**Связь:** Levers 9 (RLHF strip, harshaneel/humanize). Плотность считается в `anti-ai-auditor` через grep (см. `references/lexicon.md` Chatbot artifacts).

## P-NEW-10. Biased hedge (anticipatory рassurance)

**Что это:** хедж, прикрывающий слабый факт, чтобы не выглядеть ошибочным.

**Маркеры:**
- «It is generally considered that …» без ссылки.
- «Some sources suggest» при единственном слабом источнике.
- «It might be worth considering …» вместо конкретной рекомендации.

**Пример:**

> ❌ «Most experts suggest that PostgreSQL might be worth considering for production use.»
>
> ✅ «PostgreSQL. Мы держим 14 ТБ и p99 14 мс.»

**Связь:** Shen et al. (2023) показали, что RL reward model ужесточает уверенность независимо от фактической точности, а Park et al. (2024) — что DPO эксплуатирует именно эту асимметрию.

## P-NEW-11. Format-uniformity block (heading gravity)

**Что это:** LLM приводит любой текст к одной структуре — 1 H2, 3 H3, 1 список.

**Маркеры:**
- Каждый email заканчивается «Best regards, Team» (EN) или «С уважением, Команда» (RU) при других ролях автора.
- Документация разного жанра (incident post, design doc, release notes) одинаково начинается с «Overview → Context → Decision».

**Связь:** Huang et al. (2024) — calibration без изменения формата не решает этот сигнал.

## P-NEW-12. Mixed-language bleed

**Что это:** LLM вставляет английские термины в русский без необходимости.

**Маркеры:**
- «Сделаем rollback», «Возьмём baseline», «Сходим в release notes».
- «Используем tail latency», вместо «хвостовая задержка».

**Решение:** Лексические решения есть в `lexicon-ru-v2.md`. Плотность поддаётся простому grep `awk 'BEGIN{count=0} /(\b(rollback|baseline|deploy|merge|commit|pipeline|cluster|node|chart|chart\-only|backlog|fix|shift|shift\-left)\b)/{count++} END{print count}'` по тексту; целевая плотность 0 на текст средней длины.

## Сводная таблица

| ID | Название | Главный маркер | Решение |
|---|---|---|---|
| P-NEW-8 | List-bloat | 8-15 bullets в каждом разделе | Сократить до 3-5; перенести детали в текст |
| P-NEW-9 | Polite-hedge bleed | «Great question!» / «Happy to help» | Удалить все вступительные и заключительные реверансы |
| P-NEW-10 | Biased hedge | «might be worth considering» без конкретики | Заменить на действие/команду |
| P-NEW-11 | Format-uniformity block | Каждое письмо/док одинаковой структуры | Выбирать формат под жанр (RFC по Аверінцеву) |
| P-NEW-12 | Mixed-language bleed | Английские заимствования в RU | Лексикат через `lexicon-ru-v2.md` |

## Связь с предыдущими

- **P-NEW-1…7**: структурный over-generation (длина, restatement, bridging, hedging, framing, recap).
- **P-NEW-8…12**: поверхность и RLHF-голос. Эти две подкатегории независимы: лечить надо по-разному.

## Источники

- Zhang et al. «Format Bias» — arXiv 2409.11704 (2024).
- Shen et al. «Loose Lips Sink Ships» — arXiv 2310.05199 (EMNLP Findings, 2023).
- Huang et al. «Post-hoc Reward Calibration» — arXiv 2409.17407 (ICLR 2025).
- Park et al. «Disentangling Length Bias» — arXiv 2403.19159 (2024).
- Lamparth et al. «Reward Bias Substitution» — arXiv 2605.27996 (2026).
- harshaneel/humanize Lever 9 — RLHF strip.
