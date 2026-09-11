---
type: pattern-update
status: draft
created: 2026-09-11
related: [43-patterns-catalogue, over-generation, format-and-rlhf-bias]
sources: [Aboudjem/humanizer-skill, harshaneel/humanize, harshaneel/ai-check, danielfein/raid-detectors]
---

# Catalogue update — patterns not yet in our 43-pattern list

> [!info] Scope
> Survey of GitHub humanizer/detector repos conducted 2026-09-11 to find AI-text
> patterns absent from our `43-patterns-catalogue.md` (P1–P43), `structural/over-generation.md`
> (P-NEW-1…P-NEW-7), and `structural/format-and-rlhf-bias.md` (P-NEW-8…P-NEW-12).
> Net new: 8 patterns, P-NEW-13 through P-NEW-20.

## Methodology

Repos surveyed (in order of yield):

| Repo | URL | Yield | Notes |
|---|---|---|---|
| **Aboudjem/humanizer-skill** | https://github.com/Aboudjem/humanizer-skill | High | Now at 55 patterns (P44–P55 are post-our-catalogue). 229 ★. MIT. SKILL.md + references/patterns.md both fetched. |
| **harshaneel/humanize** | https://github.com/harshaneel/humanize | High | 9-lever framework with peer-reviewed grounding. 449 ★. MIT. humanize/SKILL.md + ai-check/SKILL.md + README fetched. |
| **harshaneel/ai-check** | https://github.com/harshaneel/ai-check | 404 | Sub-skill of harshaneel/humanize, no separate repo. Fetched via the umbrella repo. |
| **diaiq/claude-skill-humanizer** | https://github.com/diaiq/claude-skill-humanizer | Low | API wrapper (DiaIQ Humanizer API). No novel patterns of its own. |
| **lynote-ai/humanize-text** | https://github.com/lynote-ai/humanize-text | Low | Translation-chain pipeline. Cites StoryScope (UMD + Google DeepMind, COLM 2026) but does not enumerate new surface patterns. |
| **danielfein/raid-detectors** | https://github.com/danielfein/raid-detectors | 404 | Stanford RAID repo not reachable via the tested paths. Moved on. |
| **Microsoft/AI-Shell-AutoExec** | (not surveyed) | n/a | Auto-execution framework, not relevant to surface stylometry. |
| **anthropics/skills** | https://github.com/anthropics/skills | None | Meta-skill specification repo. No AI-text patterns. |
| GitHub search "AI text detection" >50 ★ | (skipped) | n/a | Search returned mostly forks of the above + commercial detector landing pages. Not useful beyond what was already surveyed. |

**Empirical grounding summary.** Patterns below cite at least one of: (a) Aboudjem's
empirical set derived from the Wikipedia Signs-of-AI-Writing consensus + 2024–2026
emerging-pattern review, (b) harshaneel's Signal-I checklist, which is a documented scan
overlap with Grammarly + Binoculars + GPTZero, (c) the HC3 corpus (Guo et al. 2023,
arXiv:2301.07597, 40K bilingual Q/A pairs), or (d) the SHAP-based detector explainability
study referenced in the harshaneel/ai-check skill (EACL 2026, arXiv:2601.07974 and
arXiv:2603.23146).

**Why this catalogue differs from P44–P55 of Aboudjem.** Aboudjem's P44–P55 are the
"craft and forensic" set. Of those twelve, the following are *already* covered in our
catalogue under different names and are **not** added again:

- P45 (Narrator-from-a-Distance) ≈ our P32 (Collaborative Communication Leaking) — *partial overlap*, we still add a sharper sub-pattern as P-NEW-14.
- P51 (Reasoning-Chain Artifacts) ≈ our P-NEW-3 (Bridging) — *overlap*, skipped.
- P53 (Hedged-Enumeration Openers) — empirically validated in HC3, novel surface form, **added as P-NEW-20**.
- P54 (Argument Residue) — *novel*, **added as P-NEW-16**.
- P55 (Leftover Hedge Debris) — partial overlap with our P23 / P-NEW-5 / P-NEW-10, *not added*.
- P44, P46, P47, P48, P49, P50, P52 are all *novel* forms not in our catalogue; P-NEW-13, P-NEW-15 cover the strongest two.

---

## P-NEW-13: False Agency (Антропоморфизация абстракций)

**Source:**
- Aboudjem/humanizer-skill `references/patterns.md`, P44 False Agency
- harshaneel/humanize `humanize/SKILL.md`, Signal I checklist (parallel subject mirror family)

**Description.** Sentences that attribute volition or decision-making to abstract
forces, markets, systems, or trends — instead of to the humans actually acting.
A common pattern in LLM output because models trained on "narrative prose" reach for
the nearest agentic noun, and abstract aggregates ("the market", "the algorithm",
"the trend") feel agentic to a model without being so to a reader.

**EN examples (AI-flavored):**
- "The market rewards companies that listen."
- "Security says no." (no one is named)
- "The system decided to fail open."
- "Performance demands a rewrite."

**RU examples (AI-flavored):**
- «Рынок вознаграждает тех, кто слушает.»
- «Безопасность говорит нет.» (кто — не названо)
- «Система решила перейти в fail-open.»
- «Производительность требует рефакторинга.»

**EN human rewrites:**
- "Customers spend more with companies that answer support tickets within an hour."
- "Two of three approvers blocked the deploy. We don't know which one yet."

**Detection heuristic.** Grep for the construction `^[A-Z][a-z]+ (rewards|requires|demands|decides|wants|refuses|chooses|prefers)\b` (EN) or noun + verb-of-volition where the grammatical subject is a non-agent (RU: «рынок/система/безопасность/алгоритм + вознаграждает/требует/решает/отказывает»). Each instance flags. Threshold: 2+ false-agency clauses in 500 words = medium severity; 4+ = strong.

**Severity:** medium. Strongest in business, marketing, and post-mortem registers where the actor is often intentionally vague.

---

## P-NEW-14: Narrator-from-a-Distance (Дистанцированный рассказчик)

**Source:**
- Aboudjem/humanizer-skill `references/patterns.md`, P45 Narrator-from-a-Distance
- harshaneel/humanize `humanize/SKILL.md`, "Voice and register" lever discussion

**Description.** The model avoids first- and second-person pronouns in passages
where a person actually had the experience being described, and reaches instead for
the impersonal "people tend to", "one often finds", "it is generally the case that",
"развитие показывает, что" constructions. Distinct from our P32 (Collaborative
Communication Leaking), which is about *addressing the reader* as if the model is
co-authoring. P-NEW-14 is about *evading the role of narrator* entirely.

**EN examples (AI-flavored):**
- "People tend to underestimate how much testing matters."
- "One often finds that teams underestimate observability."
- "Developers frequently encounter these issues."

**RU examples (AI-flavored):**
- «Люди склонны недооценивать важность тестирования.»
- «Нередко можно заметить, что команды…»
- «Разработчики часто сталкиваются с подобными проблемами.»

**EN human rewrites:**
- "You will underestimate how much testing matters, right up until a Friday deploy pages you at 2am."
- "I learned this the hard way in 2019."

**Detection heuristic.** Count impersonal / 3rd-person-plural constructions per 200 words: `people tend to`, `one often`, `it is often the case`, `developers frequently`, `teams often find`. Compare to first-person (`I`, `we`, `my`) and direct second-person (`you`, `your`) density. Ratio > 2:1 impersonal-vs-direct in a passage where direct address is natural = signal.

**Severity:** medium. Stronger in narrative, instructional, and reflective registers; weak in scientific abstracts where impersonal voice is conventional.

---

## P-NEW-15: Diff-Anchored Writing (Описание истории изменений вместо текущего состояния)

**Source:**
- Aboudjem/humanizer-skill `references/patterns.md`, P46 Diff-Anchored Writing

**Description.** Code-adjacent and technical LLM output describes *what changed* in
the past tense rather than *what is now true*. A natural-language reflex from models
trained on commit messages, PR descriptions, and changelogs — surfaces in tutorials,
documentation, and any prose discussing recent edits.

**EN examples (AI-flavored):**
- "This function was refactored to replace the old callback approach with async/await."
- "We have migrated the database from MySQL to PostgreSQL for better JSON support."
- "The endpoint has been updated to use a new authentication scheme."

**RU examples (AI-flavored):**
- «Эта функция была отрефакторена для замены старого подхода с колбэками на async/await.»
- «Мы мигрировали базу данных с MySQL на PostgreSQL для лучшей поддержки JSON.»
- «Эндпоинт был обновлён для использования новой схемы аутентификации.»

**EN human rewrites:**
- "This function fetches the user and returns a promise."
- "The database is PostgreSQL. JSONB columns index cleanly; we use them for the audit log."
- "The endpoint uses JWT. Tokens expire after 15 minutes."

**Detection heuristic.** Grep for past-passive and perfect-aspect markers adjacent to technical artifacts: `(was|were) (refactored|migrated|updated|rewritten|optimized)`, `has been (refactored|updated|changed)`, `(was|were) (replaced with|switched to|migrated to)`. Each hit flags; 3+ in 500 words = strong. Distinguish from legitimate historical context by checking whether the past action is the subject of the sentence vs. a passing aside.

**Severity:** medium. Specific to technical-writing registers; nearly invisible elsewhere.

---

## P-NEW-16: Argument Residue (Риторический след спора)

**Source:**
- Aboudjem/humanizer-skill `references/patterns.md`, P54 Argument Residue
- Aboudjem/humanizer-skill README § "Honest limits" (single-pass drafting residue)

**Description.** A rebuttal to a position the text itself never stated — "While some
might argue that X, the reality is Y" — where no version of X appears elsewhere and
no opponent is named. A near-deterministic tell of a model that drafts through more
than one internal position before committing, then ships without scrubbing the
counter-position it considered and rejected. Hard to fake in human prose because a
human author knows who they are arguing against.

**EN examples (AI-flavored):**
- "While some might argue that remote work hurts collaboration, the data tells a different story."
- "Critics may claim that microservices add complexity, but the trade-offs are worth it."
- "Skeptics often point out that Rust has a learning curve; however, the safety guarantees justify the investment."

**RU examples (AI-flavored):**
- «Некоторые могут возразить, что удалённая работа вредит коллаборации, но данные говорят об обратном.»
- «Критики могут утверждать, что микросервисы усложняют архитектуру, однако преимущества стоят того.»
- «Скептики нередко указывают на порог входа в Rust; тем не менее, гарантии безопасности оправдывают вложения.»

**EN human rewrites:**
- "Remote work hasn't hurt our collaboration. Our incident response time actually improved after we went remote."
- "Microservices added complexity. We tracked the MTTR improvement from 47 minutes to 6; the complexity cost was lower than the alternative."

**Detection heuristic.** Grep for hypothetical opponents without named referents:
- `(while|although) (some|critics|skeptics|detractors|some might) (argue|claim|suggest|point out)` (EN)
- `^(Некоторые|Критики|Скептики) (могут |нередко |часто )?(утверждают|возражают|указывают|говорят)` (RU)

Each hit without a corresponding named opponent elsewhere = +1. Threshold: 1 strong, 2+ severe. Crucially, this is distinct from P5 (Vague Attributions) because it presupposes a position being *rebutted*, not just a claim being *made*.

**Severity:** **high**. One of the strongest single-pattern signals of multi-pass AI drafting; flagged by both surveyed repos and corroborated by EditLens (arXiv:2510.03154, cited in harshaneel/ai-check) on AI-edited text.

---

## P-NEW-17: Local Coherence Over-Smooth (Избыточная локальная связность)

**Source:**
- harshaneel/humanize `ai-check/SKILL.md`, Signal I "Local coherence over-smooth"
- Primary research: DivEye (arXiv:2509.18880, TMLR 2026), EACL 2026 SHAP analysis (arXiv:2601.07974, arXiv:2603.23146)
- Corroborated by: Xu et al., "Base Models Look Human" (arXiv:2605.19516)

**Description.** Every sentence in a paragraph connects to the next *too cleanly*.
Human writing has friction: a sentence that slightly misfires before correcting, an
abrupt topic shift, a word more casual than the surrounding register, a connection
that doesn't quite resolve. AI writing tends toward zero-friction paragraphs in
which removing any sentence still leaves a coherent text — i.e. no sentence is
load-bearing. This is a *negative* signal: the absence of imperfection, not the
presence of a marker.

**EN examples (AI-flavored, every sentence removable):**
- "Remote work has fundamentally changed how teams collaborate. Many companies have adopted hybrid models. Studies show productivity has increased. Employees report higher satisfaction. The future of work is clearly hybrid."
  (Try removing any one sentence — the paragraph still reads.)

**RU examples (AI-flavored):**
- «Удалённая работа фундаментально изменила то, как команды сотрудничают. Многие компании приняли гибридные модели. Исследования показывают рост продуктивности. Сотрудники сообщают о более высокой удовлетворённости. Будущее работы явно гибридное.»

**EN human rewrite (one sentence load-bearing, one misfire):**
- "Remote work has changed collaboration in ways we are still figuring out. The hallway conversation that turns into your best idea is the obvious loss; the incident-response coordination we did at 2am last Tuesday is the obvious gain. Whether that trade is worth it probably depends on whether you're shipping software or selling ads."

**Detection heuristic.** This is *not* a grep-able pattern; it requires a readability test:
1. For each paragraph, attempt to remove each sentence in turn.
2. If the paragraph reads coherently after removing *any* sentence, score +1 to over-smooth.
3. A 5-sentence paragraph where 4 of the 5 are individually removable = strong signal.

Threshold: 50%+ sentences in a passage being individually removable without damage = strong. Important calibration caveat from the surveyed repo: this signal is corpus-conditional, strongest in essay/blog registers, weakest in academic abstracts where tight coherence is conventional.

**Severity:** medium-high. One of the few signals that survives surface rewriting (em-dash swaps, banned-vocab deletion) — because the surface is clean and the over-smoothness is structural.

---

## P-NEW-18: Asyndeton Tricolon with Escalating Complexity (Бессоюзное трикольцо с нарастающей длиной)

**Source:**
- harshaneel/humanize `ai-check/SKILL.md`, Signal I "Asyndeton tricolon building in complexity"

**Description.** Three consecutive items joined by commas (no conjunctions), each
longer and more emotionally heavy than the last, used to manufacture escalating
weight. A signature AI construction for "growing stakes" sentences — the model
appends more clause-mates to push intensity up rather than choosing one concrete
detail.

**EN examples (AI-flavored):**
- "Two hours of degraded service, six engineers figuring out what I'd done wrong, a postmortem where I had to explain my reasoning to people who had been paged at home."
- "A missed deadline, a frustrated client, a quarter we will not make up."
- "Three lines of code, a regression test, a Friday-night rollback."

**RU examples (AI-flavored):**
- «Два часа деградации сервиса, шесть инженеров, разбирающихся в моей ошибке, постмортем, на котором я объяснял свою логику людям, которых подняли по тревоге ночью.»
- «Сорванный дедлайн, недовольный клиент, квартал, который мы уже не отыграем.»

**EN human rewrites (one item, concrete):**
- "The postmortem ran for two hours. Three of the six engineers had been paged from home."
- "We missed the deadline. The client noticed within a week."

**Detection heuristic.** Tokenize sentences. For each sentence containing 2+ commas separating three-or-more phrases, check whether (a) there are no conjunctions between items, and (b) item-length increases monotonically (item2 > item1, item3 > item2 in word count). Both conditions firing = +1. Threshold: 1 in 500 words = strong. Distinct from P10 (Rule of Three) which permits conjunctions; this is specifically the asyndeton + escalating-length combination.

**Severity:** medium. Common in post-mortems, retrospectives, and personal essays where models reach for it as a "drama" construction.

---

## P-NEW-19: Mini-Aphorism Paragraph Closer (Мини-афоризм в концовке абзаца)

**Source:**
- harshaneel/humanize `humanize/SKILL.md`, Signal I checklist "Mini-aphorism closer"
- harshaneel/humanize `ai-check/SKILL.md`, Signal I "Mini-aphorism paragraph closer"

**Description.** A 4–7 word fragment or short sentence appended at the end of a
paragraph to deliver a "punchy lesson": "That's the part that stuck.", "Slide decks
don't.", "That's the whole thing.", "That's the real cost." AI paragraphs reliably
end on one of these because the model has learned that a paragraph feels complete
when it closes with a quotable line. Related to but distinct from P-NEW-7
(Antithetical Recap, end-of-text) — this fires paragraph-locally, not just at the
end of the whole piece.

**EN examples (AI-flavored):**
- "...and that single change saved us a week of debugging. The lesson: small things compound."
- "...the protocol that everyone agreed was overkill turned out to be the only thing that worked. Surprises like that are how the field actually moves."
- "...every quarter the same story plays out. Process is the actual work."

**RU examples (AI-flavored):**
- «…и это единственное изменение сэкономило нам неделю отладки. Урок: мелочи складываются.»
- «…протокол, который все считали избыточным, оказался единственным, что сработал. Подобные сюрпризы и двигают индустрию.»

**EN human rewrites (end on concrete detail or unresolved thought):**
- "...and that single change saved us a week of debugging. We kept the change."
- "...we still do not know why the protocol worked. Probably will never run a controlled test."

**Detection heuristic.** Heuristic scan: identify paragraphs ending in a sentence whose word count is ≤7 AND whose content does not advance the paragraph's argument (it *comments on* the argument). Sample triggers: `That's the (real|actual|whole|part) (work|stuck|cost|point|thing)\.`, `Slide decks don't\.`, `That's what changed\.`, `That's the lesson\.`, `Process is (the|actually) (real|actual) work\.` (EN). RU: `Урок: …`, `Вот в чём суть\.`, `Именно так это и работает\.`. Per-paragraph firing; 3+ paragraph-closer mini-aphorisms in a 1000-word piece = strong signal.

**Severity:** medium. Distinct from P-NEW-7 (which fires once at the end of a piece); this fires paragraph-locally and is harder to spot in isolation.

---

## P-NEW-20: Hedged-Enumeration Openers (HC3-validated) (Хеджированные открывающие перечисления)

**Source:**
- Aboudjem/humanizer-skill `references/patterns.md`, P53 Hedged-Enumeration Openers
- Primary empirical grounding: HC3 corpus (Guo et al. 2023, arXiv:2301.07597)
- Aboudjem SKILL.md § "HC3 corpus": "There are several ways", "In general", "It is generally a good idea" are the top-discriminating ChatGPT opening tokens in the 40K-pair bilingual corpus

**Description.** Openers of the form "There are several ways to X", "In general,
one should Y", "It is generally a good idea to Z" — a hedged, enumeration-suggesting
sentence at the start of a passage that the rest of the passage does not enumerate.
Empirically grounded as a top-discriminating ChatGPT marker in HC3, not just a
stylistic impression.

**EN examples (AI-flavored):**
- "There are several ways to speed up a slow query. In general, it is a good idea to consider indexing."
- "When it comes to API design, there are a few important principles to keep in mind. First, …"
- "In general, it is generally a good idea to follow established conventions."

**RU examples (AI-flavored):**
- «Существует несколько способов ускорить медленный запрос. Как правило, хорошей идеей будет рассмотреть индексацию.»
- «Когда речь идёт о проектировании API, есть несколько важных принципов. Во-первых, …»

**EN human rewrites (skip the opener, lead with the recommendation):**
- "Add an index on user_id. That one change took the query from 900ms to 12ms."
- "Don't invent a new API style if an HTTP convention already fits."

**Detection heuristic.** Grep for opener + indefinite-quantifier patterns:
- `^(There are|There is) (several|a few|many|various) (ways|approaches|methods|principles|factors|things)`
- `^(In general|Generally speaking|As a rule|It is generally|It is often|It is usually)`
- `^(When it comes to|With regard to|Regarding|Concerning) [A-Za-z]+, (there|it)`

RU:
- `^(Существует|Есть) (несколько|ряд|много) (способов|подходов|методов|принципов)`
- `^(Как правило|В общем случае|Вообще говоря|Обычно)`
- `^(Когда речь (идёт|заходит) о|Когда дело касается) [а-я]+,`

Threshold: 1 strong, 2+ severe. Distinct from our existing P5 (Vague Attributions) and P29 ("Comprehensive Overview") — P5 is about attribution specifically, P29 is about the meta-discourse opener of a guide, P-NEW-20 is the specific opener + (vague-)enumeration sequence that HC3 validated as the highest-frequency ChatGPT opener.

**Severity:** **high**. The only pattern in this catalogue with direct corpus-level empirical validation (HC3, 40K bilingual Q/A pairs) — flagged as a top-discriminating ChatGPT token set, not just an impression.

---

## Summary table

| ID | Pattern | Severity | Best signal in register | Source repo |
|---|---|---|---|---|
| P-NEW-13 | False Agency | medium | business, marketing, post-mortem | Aboudjem P44 |
| P-NEW-14 | Narrator-from-a-Distance | medium | narrative, instructional, reflective | Aboudjem P45 |
| P-NEW-15 | Diff-Anchored Writing | medium | technical docs, tutorials | Aboudjem P46 |
| P-NEW-16 | Argument Residue | **high** | persuasive, opinion, essays | Aboudjem P54 |
| P-NEW-17 | Local Coherence Over-Smooth | medium-high | essays, blogs | harshaneel Signal I |
| P-NEW-18 | Asyndeton Tricolon Escalating | medium | post-mortems, retrospectives | harshaneel Signal I |
| P-NEW-19 | Mini-Aphorism Paragraph Closer | medium | any prose with paragraphs | harshaneel Signal I |
| P-NEW-20 | Hedged-Enumeration Openers (HC3) | **high** | any expository prose | Aboudjem P53 + HC3 |

## Patterns considered and *not* added (overlap with existing catalogue)

| Candidate | Existing pattern it overlaps | Reason skipped |
|---|---|---|
| Aboudjem P47 (Hyphenated-Pair Overuse) | P4 (Promotional Language) + P7 (AI Vocabulary) | The hyphenated adjectives themselves are already in P4/P7 lists. Pattern is too narrow to stand alone. |
| Aboudjem P48 (Aphorism Formulas) | P40 (Symbolic Gloss) | Stock aphorisms ("data is the new oil") are a sub-form of symbolic gloss. Already covered by P40 + P23 (hedging). |
| Aboudjem P49 (Fragmented Headers) | P14 (Boldface Overuse) + P15 (Structured List Syndrome) | Header-level structural pattern already covered by header variants of P14/P15. |
| Aboudjem P50 (Passive / Subjectless) | P18 (Formal Register Overuse) + P25 (Hallucination Markers) | Passive constructions in technical registers are conventional; flagging them broadly produces false positives. Covered in P18 as канцелярит. |
| Aboudjem P51 (Reasoning-Chain Artifacts) | P-NEW-3 (Bridging) | Same underlying pattern (model narrates structure to itself). |
| Aboudjem P52 (Unicode Obfuscation) | not a writing pattern; a tampering signal | Already discussed in harshaneel/humanize "Documented dead ends". Out of scope for surface humanization. |
| Aboudjem P55 (Leftover Hedge Debris) | P23 (Excessive Hedging) + P-NEW-5 (Anticipatory Hedging) + P-NEW-10 (Biased Hedge) | Three of our patterns already cover hedge density. Adding a fourth is redundant. |
| harshaneel Signal F "Turns out" pivot | P-NEW-6 (Balanced Framing) — partial | Captured under framing / "reveal" constructions in P-NEW-6. The specific "turns out" trigger is too narrow to be its own pattern; flag in the audit pass. |
| harshaneel Signal F "Announcement-colon patterns" ("The rule I use:") | P-NEW-3 (Bridging) | Bridging already covers announcement-and-reveal. |
| harshaneel Signal F "Pattern announcement" ("The pattern is X.") | P32 (Collaborative Communication Leaking) | Same family — the model narrating structure to the reader. |
| harshaneel Signal I "Parallel reason chains" | P10 (Rule of Three) | Parallel clauses at sentence level already covered. |
| harshaneel Signal I "Aphoristic / chiasmus closer" | P-NEW-7 (Antithetical Recap) + P9 (Negative Parallelisms) | Already covered. |
| harshaneel Signal I "Inverted burstiness" | P30 (Uniform Sentence Length) — opposite direction | The "opposite" failure mode is too rare to be a top-level pattern; flag as a secondary tell. |
| harshaneel Signal H "Slack register collapse" | P19 (Chatbot Artifacts) + P21 (Sycophantic Tone) | Slack-specific register collapse is a register-specific application of P19/P21, not a new pattern class. |

## Patterns that *surprised* me (not in our catalogue but empirically strong)

1. **P-NEW-16 (Argument Residue)** is the single biggest miss. Our catalogue has
   P5 (Vague Attributions) and P40 (Symbolic Gloss) but nothing for the
   "rebuttal to nobody" pattern. It is one of the cleanest single-pattern tells of
   AI drafting residue because *no human writes this* without a specific person or
   text in mind that they are responding to. A grep for hypothetical-opener phrases
   catches it reliably.

2. **P-NEW-17 (Local Coherence Over-Smooth)** is the most counterintuitive new
   addition. The signal is the *absence* of friction, not the presence of a
   marker. It is what remains after em-dash swaps and banned-vocab deletion
   succeed — i.e. it survives surface rewriting more reliably than any lexical
   pattern in our catalogue. This is consistent with the "Base Models Look Human"
   finding (arXiv:2605.19516): the RLHF signal lives in structural coherence, not
   vocabulary.

3. **P-NEW-20 (Hedged-Enumeration Openers)** is the only new pattern with direct
   40K-corpus empirical validation. The HC3 study identified "There are several
   ways", "In general", "It is generally a good idea" as top-discriminating
   ChatGPT markers — not just stylistic impressions. This makes it more
   actionable than the rest of our catalogue, almost all of which is grounded in
   impression + small-corpus observations.

## Detection guidance for the skill's decision logic

Top 3 to integrate first, ranked by severity + actionability:

1. **P-NEW-16 (Argument Residue).** Grep is trivial (`while some might argue` /
   `critics may claim` / `некоторые могут возразить`). High severity because the
   pattern is almost never human-authored in this form.

2. **P-NEW-20 (Hedged-Enumeration Openers).** Grep is trivial (see triggers
   above). High severity because it is corpus-validated, not just impressionistic.
   Easy to integrate into the existing banned-vocabulary pass at the beginning of
   the humanizer rewrite.

3. **P-NEW-17 (Local Coherence Over-Smooth).** Detection is harder (manual test,
   not a grep). But it is the pattern that *survives* surface rewriting, so it
   becomes the most valuable signal once the others are stripped. Worth integrating
   as a Step 5 audit, not as a pre-write gate.

## Sources

- Aboudjem/humanizer-skill — https://github.com/Aboudjem/humanizer-skill — `skills/humanizer/SKILL.md`, `skills/humanizer/references/patterns.md` (fetched 2026-09-11)
- harshaneel/humanize — https://github.com/harshaneel/humanize — `humanize/SKILL.md`, `ai-check/SKILL.md`, README (fetched 2026-09-11)
- Guo et al. 2023, *How Close is ChatGPT to Human Experts?* — arXiv:2301.07597 (HC3 corpus)
- DivEye — arXiv:2509.18880 (TMLR 2026)
- EACL 2026 SHAP analysis — arXiv:2601.07974
- arXiv:2603.23146 — follow-up SHAP analysis
- Xu et al. 2026, *Base Models Look Human* — arXiv:2605.19516
- EditLens — arXiv:2510.03154 (cited in harshaneel/ai-check for AI-edit fraction estimation)
- Lynote.ai/humanize-text StoryScope citation — COLM 2026 (narrative-structure features)