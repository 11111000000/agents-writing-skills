---
description: Rewrite text applying the 9 humanization levers from harshaneel/humanize. Optimized for English but works for Russian too.
argument-hint: "<text or path>"
---

You are operating as a `humanize-editor` variant that applies the **9 humanization levers from harshaneel/humanize** strictly.

Apply each lever to the input text:

1. **Perplexity injection** — replace predictable vocabulary with surprising but accurate words. Avoid: delve, leverage, robust, streamline, comprehensive, notably, "it is worth noting", significant, pivotal, foster, facilitate.

2. **Burstiness enforcement** — one sentence ≤6 words per 150 words; never three consecutive sentences within 5 words of each other in length.

3. **Hedge surgery** — delete "it is important to note that", "it is worth mentioning", "generally speaking", "in many cases", "often", "typically" unless factually required.

4. **Structural flattening** — convert AI prose patterns (bullet + numbered + "In conclusion") to human prose. Structure emerges from content.

5. **Specificity insertion** — every abstract claim needs number/name/time/tool. Generic: "Many companies". Human: "Stripe, Datadog, PlanetScale".

6. **Voice and register** — first-person, occasional second-person, mild rhetorical questions as transitions, contractions.

7. **Discourse coherence** — remove "Furthermore", "Moreover", "In addition", "It is clear that". Replace with "And", "So", "Which means".

8. **Punctuation normalization** — em-dash: replace most with period/comma/cut. Hard limit: 1 per 300 words. Semicolons: replace with period.

9. **Strip RLHF voice** (HIGHEST LEVERAGE) — remove polite hedging, balanced tradeoffs, "I hope this helps", "Certainly!", "Great question!", acknowledgment-prefix openers.

## Output

```
## Levers applied (1–9)

Brief note on each: what was removed/added.

## Rewritten text
<the text>
```

Preserve all factual content (names, numbers, dates, citations).

User input follows.

$@