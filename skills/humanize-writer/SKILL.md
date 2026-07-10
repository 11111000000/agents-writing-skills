---
name: humanize-writer
description: Write new prose that avoids typical LLM patterns (lexical clichés, uniform sentence length, rule-of-three, impersonality, hedging, RLHF artifacts, over-generation). Use this skill whenever the user asks for any non-trivial narrative text — documentation, README sections, blog posts, emails, status updates, announcements. Do NOT use for short code comments, log messages, or technical reference where uniformity is desired.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-generation
  version: 4
---

# Humanize-Writer (v4)

Write text that reads like a human wrote it. Bundles the operating instructions from `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/` (v4: adds Lever 12 Russian brevity grammar + length bias research integration). Apply by default for non-trivial prose.

> [!info] Knowledge base access
> All references in this skill are GitHub URLs to the public repo [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). They resolve via the GitHub web UI / API. **No local file dependencies** — works on any machine with internet access.
>
> For **offline use**, clone the knowledge base locally:
> ```bash
> ./scripts/install-knowledge.sh           # clones to ~/.cache/agents-writing-skills-knowledge
> export KNOWLEDGE_PATH="$HOME/.cache/agents-writing-skills-knowledge/knowledge"
> ```
> Then replace `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/` with `$KNOWLEDGE_PATH/` in this file.

> [!warning] Что этот skill МОЖЕТ и чего НЕ МОЖЕТ
> **Может:** сделать текст, который читается как человеческий для среднестатистического читателя.
> **Не может:** гарантировать прохождение GPTZero, Pangram, Grammarly. Против обученных детекторов **статические правила имеют ceiling** (MASH, ACL 2026).
> **Не предназначен для:** обхода академической проверки, сдачи AI-текста как своего. Используйте, чтобы **писать лучше**, не чтобы **скрывать**.
> См. `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/05-References/limits-and-self-critique.md`.

> [!warning] Length bias caveat (v4)
> YapBench (Borisov et al., 2026) и Park et al. (2024) показали, что length bias — структурное свойство RLHF preference tuning. **Tighten pass может привести к bias substitution** (Lamparth et al., 2026): сокращение длины → перенос bias на другие proxies (confidence, factual depth). Tighten pass должен сохранять плотность фактов, не только сокращать слова.

> [!info] Major changes in v4
> - **Lever 12: Russian brevity grammar** — парцелляция, эллипсис, литота как русские грамматические инструменты краткости
> - **Length bias academic integration** — 5 source-notes (Park, Shen, Zhang, Lamparth, Huang) в `length-bias-research.md`
> - **YapBench validation** — 76 LLM, 10× spread, vacuum-filling on ambiguous inputs
> - **Bias substitution warning** — single-axis mitigation ≠ universal fix
> - **HC3 + RAID datasets** — для эмпирической валидации наших метрик
> - **Strunk cut-test + Williams 6 operations** в Tighten pass

> [!info] Major changes in v3 (предыдущая версия)
> - **Lever 10: Sufficiency (Grice submaxim 2)** — positive principle: сказать ровно столько, сколько нужно
> - **Lever 11: Trust the reader (iceberg)** — оставлять пробелы, которые читатель заполнит сам
> - **Antipatterns P-NEW-1…P-NEW-7** — vacuum-filling, restatement chains, bridging, over-explanation, anticipatory hedging, balanced framing, antithetical recap
> - **Section «Когда молчать»** — explicit guidance on underspecification
> - **Strunk cut-test, YapScore check, Grice test** — mechanical checklists
> - **Russian litota tradition** — литота как положительная модель
> - **Updated Step 3 (Audit)** и Step 4 (Rupture) — добавлен pass «Tighten»

> [!info] Major changes in v2
> - Added **9 levers from harshaneel/humanize** (RLHF voice strip, disfluency)
> - Added **full 43-pattern catalogue from Aboudjem/humanizer-skill**
> - Added **Russian-specific patterns** from Wikipedia RU (deeprichastnye, parallel-clauses, em-dash, парные синонимы)
> - References to academic sources (Binoculars, MASH, watermarking)
> - Added output quality audit checklist
> - Added **scope & ethics disclaimer** (per epistemological self-audit)

## When to load

Load automatically when the user asks for any of:
- README / docs sections (other than API reference tables)
- blog posts, articles, essays
- emails, announcements, status updates
- PR/issue descriptions longer than ~5 lines
- marketing copy, landing pages, social posts
- Wikipedia-style encyclopedic content

Do **not** load for:
- Code comments, log strings, JSON/YAML schemas
- Short error messages, machine-generated reference
- Academic papers, legal documents (different register — see Scope below)
- Translations (double set of patterns; needs different approach)

## Scope: where this skill works and where it doesn't

### Optimizes well for

- Technical documentation (README, API docs, how-tos)
- Blog posts for general/dev audience
- Email to colleagues
- Status updates, release notes
- Marketing copy for **mainstream** audiences

### Weak zone (skill works but lower gains)

- Academic text (expected scientific register shares many patterns with AI)
- Legal text (expected канцелярит IS the same patterns we flag)
- Highly formal official documents

### Don't use this skill when

- Writing in a register that **legitimately** uses em-dashes, деепричастия, or канцелярит as **standard style** (e.g., Russian политические тексты, дипломатические ноты)
- Trying to evade academic integrity check (won't work, and is unethical)
- Need to fool a trained commercial detector (won't work — see MASH)

## 9 Humanization Levers (from harshaneel/humanize)

These are the highest-leverage rules. Each lever corresponds to a category of statistical signal that detectors use.

### Lever 1: Perplexity injection (word-level)

Replace predictable vocabulary with words a real person would actually choose in this context. One or two genuinely surprising but accurate word choices per paragraph.

**Banned EN:** `delve`, `leverage (verb)`, `robust`, `streamline`, `comprehensive`, `notably`, `it is worth noting`, `significant (overused)`, `pivotal`, `foster`, `facilitate`, `myriad`, `realm`, `tapestry`, `navigate (abstract)`, `underscore`.

**Banned RU:** `более того`, `кроме того`, `стоит отметить`, `следует отметить`, `важно подчеркнуть`, `таким образом`, `в заключение`, `в современном мире`, `обеспечивает`, `представляет собой`, `способствует`, `впечатляющий`, `инновационный`, `уникальный`.

Full list: `~/.config/opencode/skills/humanize-writer/references/lexicon.md`

### Lever 2: Burstiness enforcement (sentence-level)

**Heuristic**, not absolute rule.

Rules:
- Aim for **at least one** sentence of ≤6 words per 150 words of output.
- Avoid three consecutive sentences within 5 words of each other in length.
- Allow long sentences when the compound thought genuinely can't be broken.

**When NOT to apply:** Technical reference where uniform sentence length aids scannability. Mathematical proofs. Step-by-step instructions where rhythm aids comprehension.

**What this metric does NOT catch:** Some human authors naturally write uniform-length prose (technical writers, lawyers). Don't force rhythm that breaks the natural flow of the document.

### Lever 3: Hedge surgery

Audit every softening word. Delete the standard set unless factually required.

**Banned EN:** `it is important to note that`, `it is worth mentioning`, `generally speaking`, `in many cases`, `often`, `typically`.
**Banned RU:** `можно сказать`, `вероятно`, `по всей видимости`, `как правило`, `принято считать`.

If uncertainty is real, express it human-style: «I'm not sure this holds for edge cases, but…» / «Я не уверен, что это работает для edge-case, но…».

### Lever 4: Structural flattening

Convert AI prose patterns (bullet list + numbered sections + "In conclusion") into human prose patterns. Structure should emerge from content, not get imposed on it. Topic sentence plus evidence is enough. Skip the restatement humans don't make.

**When NOT to apply:** Reference documentation, API tables, structured checklists where structure aids scanning. Don't convert bullets to prose if bullets are the right tool.

### Lever 5: Specificity insertion

Every abstract claim needs a grounding anchor: a number, a named example, a time reference, a named person or tool.

- Generic: «Many companies have adopted this.»
- Human: «Stripe, Datadog, and PlanetScale all pulled this off the same way.»

### Lever 6: Voice and register

Add traceable perspective: first-person where natural, occasional second-person direct address, mild rhetorical questions as transitions, self-interruption or course-correction mid-thought, contractions in conversational registers.

**When NOT to apply:**
- API reference where third-person passive is the genre norm.
- Academic writing where «мы» (author's мы) is conventional.
- Legal text where voice is intentionally impersonal.
- Translations where preserving source voice is the goal.

**What if the user explicitly wants first-person?** Skip this lever.

### Lever 7: Discourse coherence (human transitions)

Remove AI transition words.
- «Furthermore» → cut.
- «Moreover» → cut.
- «In addition to the above» → «And».
- «It is clear that» → delete, then assert directly.
- «This highlights the importance of» → say what the importance is: «Which means you need to…»
- RU: «Более того» → cut, «Кроме того» → cut, «Таким образом» → cut.

### Lever 8: Punctuation normalization

Three punctuation marks are strong AI tells (3–5× above human baseline):

- **Em dashes (—)**: replace most with period, comma, or cut. Hard limit: **1 per 300 words**.
- **Semicolons (;)**: real-world prose almost never uses them. Replace with period.
- **Mid-sentence colons (:)**: replace with full sentence construction or period.

Russian-specific em-dash is even more diagnostic — see `references/lexicon-ru.md` (load via `read` if needed).

**Heuristic, not absolute.** The 1-per-300-words limit is a guideline, not a law. Some human authors legitimately use em-dash more often (Russian по-русски официальный стиль). When in doubt, count and compare to similar human-written Russian texts.

**When NOT to apply:** Russian **официально-деловой стиль** (legal, diplomatic, formal business correspondence) where em-dash is **expected** as part of the register.

### Lever 9: Strip RLHF / instruction-tuning voice (HIGHEST LEVERAGE)

Per arXiv 2605.19516 and 2025 detection literature, detectors fire on RLHF artifacts, not "AI-ness". Strip:
- Polite hedging
- Balanced tradeoffs offered unprompted
- Structured enumeration when a single answer would do
- Perfect local coherence
- "Helpful assistant" register
- Acknowledgment-prefix openers («That's a great question...», «Прекрасный вопрос!»)
- Hedged closers («I hope this helps», «Надеюсь, это пригодится»)

This lever overlaps with 3 (hedge surgery) and 4 (structural flattening), but is the single highest-leverage addition because it targets what detectors actually detect.

### Lever 10: Sufficiency / «когда хватит» — Grice submaxim 2

> [!important] Положительный принцип, не запрет
> Levers 1–9 говорят «не делай X». Lever 10 говорит «удали всё, что больше, чем нужно для цели». Это **не лечится** списком запрещённых слов — это структурное свойство LLM.

**Принцип (Grice, 1975):** «Make your contribution as informative as is required. **Do not make your contribution more informative than is required.**»

LLM систематически нарушает это из-за RLHF preference tuning (см. YapBench, arXiv 2601.00624, январь 2026: 76 моделей, порядок величин по over-generation). Признаки:

- **Vacuum-filling (P-NEW-1)**: вводные предложения без информации («У нас в команде возник вопрос...»)
- **Restatement chains (P-NEW-2)**: «API стал работать быстрее. Оптимизация позволила сократить время отклика.»
- **Bridging (P-NEW-3)**: «Как упоминалось выше...», «Это подводит нас к...»
- **Over-explanation (P-NEW-4)**: объяснение очевидного («pip install — это команда для установки пакетов»)
- **Anticipatory hedging (P-NEW-5)**: «возможно, в некоторых случаях может быть полезно рассмотреть...»
- **Balanced framing (P-NEW-6)**: «У подхода есть плюсы и минусы. С одной стороны...»
- **Antithetical recap (P-NEW-7)**: «Итак, мы рассмотрели три подхода...»

**Cut-test (Strunk):** удалите любое предложение. Смысл потерялся? Если нет — навсегда удалите.

**YapScore check (Borisov 2026):** сравните с минимально достаточным baseline. Цельтесь в 1.0–1.5× длины baseline для conversational регистра.

**Cut-the-second-reason:** если у вас два аргумента в пользу одного тезиса и одного достаточно — удалите второй. LLM любит давать «взвешенный» ответ из двух причин. Хороший автор часто даёт одну главную.

**Replace-explanation-with-example:** если у вас есть пример — удалите абстрактное объяснение перед ним. Пример сам по себе всё показывает.

> ❌ «Система работает эффективно. Например, на прошлой неделе API обработал 10 000 запросов за 50 мс.»
> ✅ «На прошлой неделе API обработал 10 000 запросов за 50 мс.»

**Когда НЕ применять:**
- Техническая документация с шагами (пропущенный шаг = сломанная инструкция)
- Юридический текст (точность > стиль)
- Научные методы/результаты (полнота обязательна)
- Tutorial для новичков (базовые шаги нужны)

Подробнее: `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/sufficiency-and-underspecification.md`, `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/structural/over-generation.md`.

### Lever 11: Trust the reader (iceberg) — Hemingway

> [!important] Положительная модель, не запрет
> Lever 10 — про удаление лишнего. Lever 11 — про **намеренное оставление пробелов**. Это приём, не дефект.

**Принцип (Hemingway, 1932):** «If a writer of prose knows enough of what he is writing about he may omit things that he knows and the reader, if the writer is writing truly enough, will have a feeling of those things as strongly as though the writer had stated them. The dignity of movement of an ice-berg is due to only one-eighth of it being above water.»

**Reader-fill test:** если вы убрали предложение — читатель сможет продолжить мысль без него? Если да — это и есть iceberg.

**Distinctive-word test:** если в предложении нет ни одного слова, которое добавляет информацию, которой не было в предыдущем, — удалите его.

**Distinction underspecification vs missing-info:**
- Underspecification (good): оставить пробелы, которые читатель заполнит.
- Missing information (bad): оставить пробелы, которые фрустрируют.
- Тест: читатель может продолжить мысль / действие без этой информации? Если да → underspecification. Если нет → must add.

**Примеры:**
> ❌ «Я долго думал над этой проблемой. У неё много аспектов. Я рассмотрел несколько подходов. В конце концов я пришёл к выводу, что оптимальное решение — использовать Redis. Redis — это in-memory хранилище, которое обеспечивает высокую скорость доступа к данным.»

> ✅ «Redis. Почему — ниже.»

> ❌ «Мы переписали кеш. Это было важное решение, потому что до этого API не справлялся с нагрузкой. Теперь система работает значительно быстрее.»

> ✅ «Мы переписали кеш. API отвечает за 14 мс вместо 380.»

**Russian tradition — литота:** русская литературная традиция преуменьшения. «Мужичок с ноготок» (Некрасов), «черепашьи темпы», «рукой подать», «небо с овчинку». Это тёплый, ироничный, живой тон. LLM почти не использует.

**Условие Хемингуэя:** underspecification работает только если автор **знает** то, что не говорит. Иначе — hollow places, не gravitas. Если нечего подразумевать — лучше сказать явно.

**Stop at the turn:** если в абзаце есть «поворотный момент» (решение, открытие, конфликт) — остановитесь на нём. LLM продолжает объяснять, что это значит. Хороший автор ставит точку.

> ❌ «Я понял, что проблема в rate limiter. Это было важное открытие, потому что до этого мы два дня искали в неправильном месте. После этого мы смогли сосредоточиться на реальной причине.»
> ✅ «Я понял, что проблема в rate limiter.»

**When NOT to apply:**
- Technical reference where completeness is required
- Legal/official text where every word has legal weight
- Onboarding/tutorial for beginners
- Translations that need to preserve original precision

### Lever 12: Russian brevity grammar (парцелляция, эллипсис, литота)

> [!important] Положительная модель для русского языка
> В русском есть свои грамматические инструменты краткости. LLM их **почти не использует** — он генерирует «полные» конструкции в стиле канцелярита. Lever 12 учит LLM применять эти инструменты.

**Три рычага:**

#### 12.1. Парцелляция (расщепление)

Разбить сложное предложение на 2–5 коротких через точку.

> ❌ «Город стоит на реке, обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат.»
> ✅ «Город стоит на реке. Отсюда — водоснабжение и полив.»

Примеры из литературы (Шукшин, Антокольский, Гришковец) подтверждают как живую традицию. Шкловский и Сковородников — академические источники.

**Устраняет:** P3 (деепричастия), P8 (copula avoidance).

#### 12.2. Эллипсис (опущение)

Опустить восстанавливаемый элемент.

> ❌ «Я говорю по-английски, а он говорит по-немецки.»
> ✅ «Я говорю по-английски, а он — по-немецки.» (гэппинг)
> ✅ «Я пошёл в магазин. Хлеб.» (фрагментирование)

Типы: глагольной группы, именной группы, стриппинг, фрагментирование, гэппинг, псевдогэппинг.

**Устраняет:** P22 (filler phrases), P18 (канцелярит).

#### 12.3. Литота (преуменьшение)

Использовать готовые русские формулы вместо абстрактных.

> ❌ «У нас совсем немного пользователей, практически никто не пользуется.»
> ✅ «У нас пользователей — кот наплакал.»

Готовые формулы: «черепашьи темпы», «рукой подать», «кот наплакал», «с ноготок», «с овчинку», «не более напёрстка».

**Устраняет:** P11 (elegant variation для синонимов «маленький»), P8 (copula avoidance).

#### 12.4. Нулевая связка и безличные конструкции

В русском **опускается подлежащее** — это норма.

> ❌ «Я пошёл в магазин, чтобы купить хлеб.»
> ✅ «Пошёл в магазин. Хлеб.»

**Условие:** нулевая связка уместна в разговорном, постовом, беллетристическом регистрах. В официально-деловом — нет.

**When NOT to apply:**
- Официально-деловой стиль (юридические документы, дипломатические ноты)
- Научный регистр (частично — допустимо в обзорной части)
- Перевод с другого языка, где сохранение оригинальной структуры обязательно

Подробнее: `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md`.

## Russian-specific extensions (Wikipedia RU + own research)

Apply these IN ADDITION to levers 1–12 when writing in Russian. Lever 12 (Russian brevity grammar) особенно важен — парцелляция, эллипсис, литота как живые традиции.

### R-0: Strip negative parallelisms (P9) — HIGHEST LEVERAGE FOR RU

**Russian-specific danger.** The construction «Это не X. Это Y.» / «Это не X, а Y.» is **#1 AI marker** in Russian (Washington Post 2024: 43% GPT outputs vs 3% human). LLM uses it **5–15 times per 1000 words**; humans use it **0–1 times per 1000 words**.

Forms to ban:
- ❌ «Это не X, а Y.»
- ❌ «Это не просто X. Это Y.»
- ❌ «Это не столько X, сколько Y.»
- ❌ «Это больше, чем X. Это Y.»
- ❌ «Это не только X, но и Y.»
- ❌ «MathCodingFractal — это не „ещё одна методология". Это инфраструктура...»

**Replacement rules:**
1. If X and Y are genuinely mutually exclusive (монорепо vs polyrepo) → keep, but add concrete details.
2. If X and Y are both abstract labels → replace with concrete facts.
3. If the construction adds nothing → delete it entirely.

Examples:
- ❌ «Это не баг, а фича.» → ✅ «Метод возвращает `null` для не-ASCII; это документировано в README как ожидаемое поведение.»
- ❌ «Это не просто библиотека, а фреймворк.» → ✅ «Фреймворк: предоставляет архитектуру, конвенции и систему плагинов.»
- ❌ «Это не методология, а инфраструктура.» → ✅ «Инфраструктура: роутинг, авторизация, observability из коробки.»

Density target: **<1 per 1000 words.** Anything >3 = AI.

Full methodology: `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/rhetorical/negative-parallelisms.md`

### R-1: Strip deeprichastnye chains

Russian LLM outputs overuse деепричастия (-а/-в/-вши/-я). Limit to 1 per paragraph, prefer глагол.

- ❌ «Город расположен на реке, **обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат**.»
- ✅ «Город стоит на реке. Отсюда — водоснабжение и полив.»

Metric: `D = (деепричастий / слов) × 1000`. D > 7 → AI-suspicious.

### R-2: Break paired synonyms through "и"

LLM loves "цели и задачи", "принципы и подходы", "методы и средства". Pick one.

- ❌ «Цели и задачи проекта»
- ✅ «Цели проекта»

### R-3: Em-dash discipline

Russian em-dash even more diagnostic than EN. **≤1 per 300 words.** Often hides a missing точка or глагол.

- ❌ «Решение — принято, команда — готова.»
- ✅ «Решение принято. Команда готова.»

### R-4: Voice in Russian

Use «я» for personal content, «мы» (team) for collaborative, безличное for instructions. Don't switch between them. See `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/voice-russian-specifics.md`.

### R-5: Concrete with Russian flavor

Numbers: «на 30%», «+200 тыс.», not «существенно». Cities: «в Казани», not «в России». Years: «в 2024», not «недавно».

## Workflow

### Step 1 — Pre-flight

Ask (or default) 4 questions:
1. **Voice** — 2–3 adjectives. Default: *practical, concrete, direct, opinionated*.
2. **Lead** — most concrete / surprising fact you can open with.
3. **Numbers ready?** — collect ≥3 hard facts.
4. **Sufficiency budget** — есть ли верхняя граница длины? (Если формат — email / commit message / статус-апдейт / личное сообщение — установить жёсткую. Если README — граница мягкая.)

### Step 2 — Draft

Write full text. Monitor:
- Sentence length diversity (5–25+ words)
- No 3-parallel bullet lists without rupture
- One деепричастие per paragraph max (RU)
- Em-dash count: ≤1 per 300 words
- At least one «я»/«мы» per 200 words (where format allows)
- **YapScore target**: ≤1.5× длины минимально достаточного baseline

### Step 3 — Audit pass

Re-read. For each paragraph:
- [ ] Contains concrete detail (number/name/date/path/command)
- [ ] Sentence lengths visibly differ
- [ ] No banned lexicon item
- [ ] No triple-parallel without rupture
- [ ] No abstract sentence that could be cut without loss
- [ ] No клише from R-0 through R-5 (RU)
- [ ] **Lever 12 check (RU):** есть ли кандидаты для парцелляции (длинное предложение с деепричастиями)?
- [ ] **Lever 12 check (RU):** есть ли кандидаты для эллипсиса (повтор глагола во второй части сложного предложения)?
- [ ] **Lever 12 check (RU):** есть ли литота для абстрактного преуменьшения («совсем немного» → «кот наплакал»)?
- [ ] **Sufficiency check (Lever 10)**: есть ли предложение, которое можно удалить без потери смысла? Если да — cut-test: удалить и проверить, выжил ли смысл.
- [ ] **Vacuum-filling check**: есть ли вводное предложение без информации? Удалить.
- [ ] **Restatement check**: есть ли 2+ предложения с одинаковым содержанием? Оставить одно самое конкретное.

### Step 4 — Tighten pass (Lever 10 / Strunk)

Apply Strunk cut-test ко всему тексту:
- Прочитайте каждое предложение. Спросите: «Если я это уберу, что исчезнет?»
- Если ответ — ничего, что не было сказано раньше, — удалите.
- Цельтесь в уменьшение на 15–30% от черновика. LLM обычно даёт в 1.5–2× больше нужного.

Применяйте шесть операций Williams:
1. Delete words that mean little or nothing («in order to», «the fact that»)
2. Delete words that repeat the meaning of other words
3. Delete words implied by other words
4. Replace a phrase with a word («the way in which» → «how»)
5. Change negatives to affirmatives («did not remember» → «forgot»)
6. Delete useless adjectives and adverbs («absolutely essential», «completely unanimous»)

### Step 5 — Rupture pass

If a paragraph looks "smooth", insert a **rupture sentence**:
- one-line aside («Note:», «Кстати,», «А теперь — лирическое отступление.»)
- personal aside («У меня на это ушло два часа в прошлый раз.»)
- blunt opinion («Это не работает.»)
- short question («Зачем?»)
- tangent that ties back
- **silence** — иногда правильный rupture = ничего не писать (Lever 11)

### Step 6 — Trust-the-reader pass (Lever 11)

Reader-fill test:
- Прочитайте текст и для каждого абзаца спросите: «Если я уберу 1–2 предложения, читатель всё поймёт?»
- Если да — удалите. Это iceberg.
- Условие: вы **знаете** то, что не говорите. Если не знаете — допишите.

Distinctive-word test:
- Если в предложении нет ни одного слова, которое добавляет новую информацию — удалите его.

### Step 7 — Density check

Count per 1000 words:
- AI-clichés from lexicon: target <5
- Деепричастия (RU): target <7
- Em-dashes: target <3
- Парные синонимы (RU): target <2
- Канцеляризмы: target <3
- **Bridging density (P-NEW-3)**: target <5% абзацев начинаются с bridging
- **Vacuum-filling sentences (P-NEW-1)**: target <5 на 1000 слов
- **Antithetical recaps (P-NEW-7)**: 0 — удалить безусловно

If multiple metrics exceed targets → rewrite.

## Output format

Always output **only the final text**. No preamble, no "Here's a draft:", no apologies.

## Когда молчать: где уместна недосказанность

> [!info] Это пересекается с Lever 10/11, но заслуживает отдельного раздела, потому что применение избирательное.

| Уместно | Неуместно |
|---|---|
| Email коллеге — контекст общий | Onboarding нового сотрудника — контекст нужно дать |
| Пост в блог для своей аудитории | Tutorial для новичков в теме |
| RFC внутри команды | RFC для другой команды, с которой мало пересечений |
| Комментарий в PR | API reference documentation |
| Личное сообщение | Юридический/финансовый документ |
| Пресс-релиз для отрасли | Пресс-релиз для широкой публики |
| Status update для уже знакомых | Status update для стейкхолдеров |
| Доклад на конференции для своих | Доклад для широкой аудитории |
| Художественная проза | Научная статья |

**Принцип различения:** underspecification работает, когда у автора и читателя есть общий контекст. Если общего контекста нет — нужно дать его явно. Это не нарушение Lever 10, это уважение к Gricean maxim of quantity: информативность должна соответствовать цели.

**Конкретные знаки, что underspecification здесь НЕ работает:**
- Читатель должен выполнить действие (установить, настроить, оплатить)
- У читателя нет вашего контекста
- Ошибка интерпретации дорого стоит (медицина, финансы, безопасность)
- Формат требует полноты (API ref, ТЗ, договор)

**Признаки, что underspecification здесь работает:**
- Аудитория разделяет контекст (команда, комьюнити, своя отрасль)
- Цель — передать идею, а не инструкцию
- Тон — равный или сверху вниз (не снизу вверх)
- Читатель может google недостающее

## Companion skills

- `humanize-editor` — for rewriting existing text.
- `anti-ai-auditor` — for diagnosis without rewriting.
- `ai-pattern-rewriter` — for surgical span fixes.

## See also

- Obsidian vault: `https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/`
- Especially: `02-Techniques/perplexity-and-burstiness.md`, `02-Techniques/voice-russian-specifics.md`, `02-Techniques/show-dont-tell.md`, `02-Techniques/sufficiency-and-underspecification.md`, `02-Techniques/length-bias-research.md` (NEW v4), `02-Techniques/russian-brevity-grammar.md` (NEW v4), `01-Patterns/43-patterns-catalogue.md`, `01-Patterns/structural/over-generation.md`.
- External: [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill), [harshaneel/humanize](https://github.com/harshaneel/humanize), [YapBench paper](https://arxiv.org/abs/2601.00624), [HC3 dataset](https://huggingface.co/datasets/Hello-SimpleAI/HC3), [RAID dataset](https://huggingface.co/datasets/liamdugan/raid).