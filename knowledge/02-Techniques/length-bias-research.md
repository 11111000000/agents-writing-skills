---
type: technique
tags: [technique, length-bias, academic, detection, foundational]
created: 2026-07-09
status: active
related: [sufficiency-and-underspecification, perplexity-and-burstiness, hc3-english, hc3-russian-translated, raid-multi-domain]
sources: [park-2024-disentangling-length-dpo, shen-2023-loose-lips, zhang-2024-format-bias, lamparth-2026-bias-substitution, huang-2024-post-hoc-calibration]
---

# Length Bias в RLHF — академический обзор

> [!info] Контекст
> YapBench (Borisov et al., январь 2026) подтвердил, что LLM over-generate. Но YapBench — это одна работа. Ниже — пять других peer-reviewed/корпоративных работ 2023–2026, которые дают полную картину.

> [!warning] Эпистемический статус
> Эти метрики — **гипотезы на основе эмпирических исследований**, не доказанные универсальные законы. Каждая работа имеет свои ограничения (sample size, домен, модели). Наши skill'ы должны учитывать это.

## 1. Корень проблемы (consensus)

**Все 5 работ согласны:** length bias — это структурное свойство preference tuning, а не стилистический артефакт.

| Работа | Год | Что доказано |
|---|---|---|
| [[06-Sources/research-papers/length-bias/shen-2023-loose-lips\|Shen et al. (EMNLP 2023)]] | 2023 | Reward model "finds shortcuts" — assumes humans prefer longer. Это **reward hacking**, не увеличение helpful information. |
| [[06-Sources/research-papers/length-bias/park-2024-disentangling-length-dpo\|Park et al. (ICLR-style 2024)]] | 2024 | DPO (не только RLHF) эксплуатирует length bias через out-of-distribution bootstrapping. **GPT-4 judge сам имеет verbosity bias** — это создаёт порочный круг. |
| [[06-Sources/research-papers/length-bias/huang-2024-post-hoc-calibration\|Huang et al. (ICLR 2025)]] | 2025 | Post-hoc reward calibration может исправить length bias **без retraining**. 3.11 средний прирост на RewardBench. |
| [[06-Sources/research-papers/length-bias/zhang-2024-format-bias\|Zhang et al.]] | 2024 | Format bias шире: lists, links, bold, **emojis**. <1% biased data достаточно чтобы инжектить bias. |
| [[06-Sources/research-papers/length-bias/lamparth-2026-bias-substitution\|Lamparth et al. (Stanford)]] | 2026 | **Single-axis mitigation переносит bias на correlated proxies.** Length penalty → confidence over-calibration → factual accuracy falls. **Никакая single-axis mitigation не работает**, по их обзору. |

## 2. Что НЕ работает (anti-patterns для митигации)

### 2.1. Single-axis mitigation (Lamparth et al.)

> «A length penalty during GRPO training compresses responses as intended yet redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

**Импликация для наших skill'ов:** Tighten pass (Lever 10) может привести к bias substitution. Если LLM учится быть коротким за счёт потери factual depth — это победа длины, но проигрыш качества.

**Решение:** нужно проверять, что Tighten pass не убирает конкретные факты. Это значит — при сокращении сохранять числа, имена, команды.

### 2.2. LLM-as-judge (Park et al.)

> «Despite the GPT4 judge's well-known verbosity bias.»

**Импликация:** Наша `anti-ai-auditor` использует LLM-стиль оценки. LLM-judge предпочитает длинные ответы. **False positives: текст после humanize может выглядеть «хуже» для LLM-judge, но лучше для человека.**

**Решение:** Не полагаться только на LLM-judge. Нужна human-validation для high-stakes кейсов.

### 2.3. Format bias (Zhang et al.)

> «Many widely-used preference models, including human evaluators, GPT-4, and top-ranking models on the RewardBench benchmark, exhibit strong biases towards specific format patterns, such as lists, links, bold text, and emojis.»

**Импликация для наших skill'ов:**
- **Lists** — наш P10 (Rule of three) частично объясняется format bias.
- **Bold** — P14 (Boldface Overuse) подтверждён.
- **Emojis** — не покрыто нашими skill'ами. Нужно добавить.

## 3. Что работает

### 3.1. Post-hoc calibration (Huang et al.)

Locally Weighted Regression applied к reward model output. Не требует retraining.

**Импликация:** Tighten pass — это аналог post-hoc calibration, применённый к output, не к reward model. Валидный подход.

### 3.2. Pair-wise counterfactual augmentation (Park et al.)

Создавать пары (length-divergent, similar content) и (content-divergent, similar length). Обучать reward model на таких парах.

**Импликация:** в нашем аудите можно добавить проверку «не потеряли ли мы содержание при сокращении».

## 4. Конкретные эмпирические данные

### YapBench (Borisov 2026)
- 76 LLM, ~300 prompts
- Order-of-magnitude spread в median excess length
- Categories: A) vacuum-filling на ambiguous inputs, B) one-liner overkill, C) one-line coding overhead

### Park et al. (2024)
- DPO length bias: 20% improvement in length-controlled win rates
- **GPT-4 judge verbosity bias: structural, not fixable by prompting**

### Lamparth et al. (2026)
- Length penalty → confidence over-calibration → factual accuracy -X%
- «Across published preference-learning mitigation work, **no method** we survey reports the evidence needed to certify successful mitigation.»

### Zhang et al. (2024)
- <1% biased data → significant reward model bias
- Format bias list/bold/emoji универсален для GPT-4, human evaluators, top reward models

## 5. Каузальная цепочка (наша интерпретация)

```
RLHF preference data
  ↓ (human raters prefer longer)
Reward model learns length = quality
  ↓
RL optimization maximizes reward
  ↓
Model learns: write longer
  ↓
Even when not warranted (vacuum-filling)
  ↓
RLHF-COV can't easily fix (Lamparth: bias substitution)
```

**Один вывод:** length bias — это **architectural** свойство современного RLHF. Не решается полностью skill'ами. Наши skill'ы могут **улучшить human perception**, но не могут гарантировать detection bypass.

## 6. Метрики (предложение, не валидировано)

| Метрика | Что измеряет | Источник |
|---|---|---|
| YapScore | длина / baseline | Borisov 2026 |
| Length-controlled win rate | качество при фиксированной длине | Park 2024 |
| RBR (reward bias ratio) | корреляция reward с длиной | Huang 2024 |
| Format bias density | плотность lists/bold/emoji | Zhang 2024 |

## 7. Практические implications для skill'ов

1. **Не полагаться только на LLM-judge для оценки качества.** Использовать human-validation для high-stakes.
2. **Tighten pass должен сохранять плотность фактов.** Сокращаем слова, не числа.
3. **Добавить в skill'ы предупреждение о bias substitution.** Single-axis mitigation ≠ universal fix.
4. **Фиксировать emoji и format bias** в нашем каталоге (сейчас покрыты только P10, P14).
5. **Не обещать детектор bypass.** Против GPTZero/Pangram статические правила не работают (MASH, ACL 2026).

## 8. Связанные заметки

- [[sufficiency-and-underspecification]] — наш Lever 10, теоретическая база
- [[hc3-english]] — эталонный датасет для измерения length bias на практике
- [[raid-multi-domain]] — multi-model benchmark для stress-теста
- [[../01-Patterns/structural/over-generation]] — P-NEW-1…P-NEW-7
- [[../05-References/limits-and-self-critique]] — эпистемическая честность

## 9. Raw notes

Все 5 source-notes содержат полные abstracts и key quotes. Главные цитаты уже вынесены в эту заметку.

---

## Глубже об источниках

Каждая из 5 статей length-bias стека переработана в отдельную глубокую source-note. Эта заметка — синтез; source-note — это операционализация с методом, экспериментальными данными и ограничениями. Ниже — карта.

### Shen 2023 — [06-Sources/research-papers/length-bias/shen-2023-loose-lips](06-Sources/research-papers/length-bias/shen-2023-loose-lips)

- **Что доказано:** reward model «находит shortcuts», предполагая что humans prefer longer responses. Re-labeling experiment показывает, что shortcut learned, не заложен в данных. Product-of-Experts с bias-focused expert даёт ~30–40% снижение length bias при сохранении intent quality.
- **Метод:** Product-of-Experts (PoE), `R_total = R_intent · R_length`. Bias-focused expert обучается на perturbed inputs (без semantic content), чтобы не дублировать intent.
- **Связь со скилами:** основание для всего каталога P-NEW (vacuum-filling, restatement, hedging, over-explanation, balanced framing, antithetical recap). Этот paper — *причина*, по которой эти паттерны существуют.
- **Ограничения:** English-only; одношаговый PPO (multi-round не тестировали); PoE не используется в production frontier-моделях.

### Park 2024 — [06-Sources/research-papers/length-bias/park-2024-disentangling-length-dpo](06-Sources/research-papers/length-bias/park-2024-disentangling-length-dpo)

- **Что доказано:** length exploitation существует и в DPO (не только в PPO/RLHF); причина — out-of-distribution bootstrapping. Простое hinge-regularization даёт до 20% improvement в length-controlled (LC) win rate, несмотря на verbosity bias GPT-4 judge.
- **Метод:** hinge penalty `λ · max(0, |y_w| - |y_l| - δ)²` поверх DPO loss. Измерение — LC win rate с trimmed comparison.
- **Связь со скилами:** протокол измерения. `check_bias_substitution` — это наша реализация Park-протокола для output-level editing. Voice profile `laconic` — аналог Park-regularization.
- **Ограничения:** DPO-only; 6B–13B; два датасета (summarization, dialogue); GPT-4 judge bias acknowledged, не устранён.

### Zhang 2024 — [06-Sources/research-papers/length-bias/zhang-2024-format-bias](06-Sources/research-papers/length-bias/zhang-2024-format-bias)

- **Что доказано:** format bias шире length bias. Lists, bold, links, emojis — все reward'ятся humans, GPT-4, и top reward models. <1% biased data достаточно, чтобы инжектить bias. **Эксплуатируется через best-of-N sampling и online DPO.**
- **Метод:** counterfactual tests (формат меняется, контент константен); injection experiment; оценка AlpacaEval и LMSYS Arena.
- **Связь со скилами:** прямое основание для P9 (negative parallelism), P10 (rule of three), P14 (boldface overuse). Format bias density (lists + bold + emoji per 1000 words) — метрика, которой у нас ещё нет.
- **Ограничения:** working paper, не peer-reviewed на момент fetched_at. Только 4 формата. MTurk выборка мала. **Нет контрмеры** — это дескриптивная работа, не интервенция.

### Huang 2024 — [06-Sources/research-papers/length-bias/huang-2024-post-hoc-calibration](06-Sources/research-papers/length-bias/huang-2024-post-hoc-calibration)

- **Что доказано:** **3.11 average performance gain across 33 reward models on RewardBench.** Post-hoc калибровка (LWR на length feature) улучшает RM без retraining, без новых данных.
- **Метод:** Locally Weighted Regression на (response, RM score) парах; calibration set must be representative; bias term вычитается из RM score на inference.
- **Связь со скилами:** **наш Tighten pass — это output-level аналог Huang's RM-level calibration.** Оба: «post-hoc, no retraining, no new data». Архитектурное соответствие прямое.
- **Ограничения:** только length (не format, не sycophancy). Calibration dataset size не оптимизирован. Bias substitution side-effect не тестировался (см. Lamparth).

### Lamparth 2026 — [06-Sources/research-papers/length-bias/lamparth-2026-bias-substitution](06-Sources/research-papers/length-bias/lamparth-2026-bias-substitution)

- **Что доказано (CRITICAL):** single-axis mitigation не устраняет bias, а переносит. Length penalty → confidence over-calibration → factual accuracy falls. **«No method we survey reports the evidence needed to certify successful mitigation.»**
- **Метод:** GRPO с perturbed RM (length term injected); измерение — calibration (Brier, ECE), factual free-form accuracy, win rate.
- **Связь со скилами:** самый критический paper для нашего дизайна. Tighten pass может переносить bias. Решение: `check_bias_substitution` (факты до/после), honesty о границах в «When NOT to load».
- **Ограничения:** один модельный класс, синтетический setup. Не тестировали формат, sycophancy, safety. **Нет контрмеры** — заканчивается «need multi-axis, calibrated, post-deployment evaluation».

### Что даёт эта декомпозиция

Когда `humanize-writer` или `humanize-editor` цитирует «Shen 2023», это не «слышал где-то» — это EMNLP-статья с конкретным re-labeling experiment. Когда упоминается «Park 2024 protocol» — это ICLR-cited length-controlled win rate. Когда `humanize-editor` указывает на риск bias substitution, это Lamparth 2026 с формальным аргументом в Appendix D, а не общее «AI может». Каждая ссылка в наших скилах — на конкретный paper, конкретный метод, конкретное число.

Это и есть разница между «AI told me» и «paper says».