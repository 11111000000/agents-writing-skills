#!/usr/bin/env bash
# scripts/check-editing-output.sh
#
# Invariant validator for the v7 meaning contract: does an editing agent's
# output still say the same thing as the source it was given?
#
# Usage:
#   bash scripts/check-editing-output.sh <output-file> <fixture-file>
#   bash scripts/check-editing-output.sh --selftest
#
# <output-file>  — the editing agent's result (plain text / markdown)
# <fixture-file> — a fixture from tests/fixtures/editing/*.md with frontmatter
#                  (required_preservation, forbidden_additions, ...) and the
#                  sections "## Source" and "## Gold edit"
#
# Checks (each one prints PASS:/FAIL: with its own name):
#   numbers-preserved      every number of "## Source" survives in the output
#   claims-preserved       required_preservation.claims survive
#   conditions-preserved   required_preservation.conditions survive
#   exceptions-preserved   required_preservation.exceptions survive
#   terminology-preserved  required_preservation.terminology survives
#   uncertainty-preserved  required_preservation.uncertainty keeps its hedge
#   no-invented-numbers    the output introduces no number absent from Source
#   no-forbidden-additions nothing from forbidden_additions shows up
#   already-good-unchanged an already-good source is not rewritten for nothing
#
# Exit: 0 = every invariant held, 1 = at least one violation, 2 = usage error.
#
# Only bash + python3 standard library are used.

set -uo pipefail

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

MODE=check
if [[ "${1:-}" == "--selftest" ]]; then
  MODE=selftest
  shift
fi

if [[ "$MODE" == "check" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "usage: $(basename "${BASH_SOURCE[0]}") <output-file> <fixture-file>" >&2
    echo "       $(basename "${BASH_SOURCE[0]}") --selftest" >&2
    exit 2
  fi

  python3 - "$1" "$2" <<'PYEOF'
# -*- coding: utf-8 -*-
"""Meaning-contract validator: agent output vs. editing fixture."""

import difflib
import os
import re
import sys

# ------------------------------------------------------------------ lexicons

# Function words that carry no claim of their own (single words only).
STOP_RU = set("""
и в во что он она оно они мы вы я ты с со к у о об от до по за из для при над под
про на а но или либо же ж бы ли то вот там тут здесь как какой какая какие кто
чего чей чья чьи все всё всех весь вся сам сама сами самом самому свою своей
своим свои своих нам нами вас вами их им ими них этом этой этих этот эта эти том
той тех тот та те так такой такие также кроме вместо около после перед между
среди через согласно поскольку чтобы чтоб будто словно тоже опять снова ещё уж
даже лишь только раз два три четыре пять шесть семь восемь девять десять много
мало больше меньше всегда никогда часто редко обычно иногда каждый другой
других иной иные самый самая самое более менее всякое всякий любой любая
любое некоторый отличный приведенный данный данная данное настоящий оный
таковой вышеуказанный нижеследующий означенный указанный соответствующий
вышеуказанно аналогичный упомянутый вышесказанный последний впоследствии
вследствие вслед ввиду течение протяжении связи случае качестве исключая
считая начиная первоначально изначально разумеется безусловно очевидно
правда хотя менее к тому итак образом самым иначе потому
поскольку следовательно значит отсюда итоге результате целом частности
основном большинстве правило очередь во-первых во-вторых в-третьих
касается касаться затрагивает затронут касаются относится относиться
следует чего данной данного данную
""".split())

STOP_EN = set("""
a an the and or but if of to in on for with is are was were be been being it its
this that these those as at by from so than then there their they them he she we
you i his her our your my will would can could should may might must do does did
have has had also into about over when while which who what where how all any both
each more most other some such only own same too very just up out down off again
further once here s t d ll m o re ve y ain aren couldn didn doesn hadn hasn haven
isn ma mightn mustn needn shan shouldn wasn weren won wouldn one two three first
second next last per via eg ie etc whose whom within without upon among
across behind beyond toward towards under above below between during before
after since until whereas whether though although unlike
""".split())

# Hedge / modality vocabulary. Markers are grouped into families: an
# uncertainty entry is kept when the output still carries *a* marker of the
# same family ("может" may legitimately become "по-видимому").
MODAL_FAMILIES = {
    "epistemic": {
        "possibility": [
            "может", "могут", "мог", "можно", "возможно", "возможны",
            "способен", "способны", "способно", "вряд ли", "может быть",
            "не исключено", "предполагает", "предположительно", "позволяет",
            "допускает", "может оказаться", "вероятно",
            "may", "might", "could", "possibly", "possible", "perhaps",
            "potential", "potentially", "can", "would",
        ],
        "probability": [
            "вероятно", "вероятность", "скорее всего", "похоже", "по-видимому",
            "кажется", "примерно", "приблизительно", "около", "порядка",
            "как правило", "предварительно", "предварительный",
            "tentative", "preliminary", "appears", "appear", "seems", "seem",
            "suggests", "suggest", "likely", "probably", "roughly", "about",
            "approximately", "around", "arguably",
        ],
    },
    "limitation": {
        "limitation": [
            "нет", "не", "недостаточно", "ограничен", "ограничена",
            "ограничены", "ограничение", "не исключено", "не утверждаю",
            "не знала", "не знал", "не могу", "не мог", "нельзя",
            "preliminary", "wide", "confounded", "uncontrolled", "uncertain",
            "uncertainty", "limited", "not", "no", "never", "cannot", "without",
        ],
    },
    "obligation": {
        "obligation": [
            "должен", "должна", "должны", "должно", "необходимо", "нужно",
            "требуется", "следует", "shall", "must", "should", "need", "needs",
            "required",
        ],
    },
}

# Categorical wording: it cancels a hedge instead of keeping it.
STRENGTHENING_MARKERS = [
    "точно", "доказуемо", "доказано", "доказан", "гарантированно",
    "гарантирует", "безусловно",
    "certainly", "definitely", "guaranteed", "guarantees", "proves", "proven",
    "undoubtedly", "unequivocally",
]

# Single-word hedge markers (used to keep modal words out of the keyword
# coverage of uncertainty entries).
MODAL_MARKER_WORDS = frozenset(
    marker
    for classes in MODAL_FAMILIES.values()
    for markers in classes.values()
    for marker in markers
    if " " not in marker
)

# Negations: dropping one flips the meaning, so they are checked separately.
NEGATION_RU = set("не нет без ни нельзя никогда".split())
NEGATION_EN = set("not no never without cannot can't".split())

# Words that only qualify a forbidden_additions entry (they describe the class
# of the forbidden thing, not the thing itself).
META_WORDS = set("""
новый новая новые новым нового другие другой других не в из на и или но а
что нет без упомянутый упомянутая упомянутые упомянутых упомянуть которых
который которая которые отсутствуют отсутствующий отсутствующие
исходнике исходнике исходник источник например вроде вида вид такие такой
класс категории категория вместо любой любые любого слова выражения утверждения
факты факт данные цифры числа числами выдуманный выдуманная выдуманные
подтверждённый подтверждённые категоричный категоричные категоричных пугающие
source not in the source beyond mentioned new others other kind
sort added addition additions additional and or of the a an to for
""".split())

# ------------------------------------------------------------------ helpers

WORD_RE = re.compile(r"[^\W\d_]+(?:[-'’][^\W\d_]+)*", re.UNICODE)
LITERAL_RE = re.compile(r"[A-Za-z][A-Za-z0-9._+/=-]*")
NUM_RE = re.compile(r"\d+(?:[ \u00a0\u202f]\d{3})+(?:[.,]\d+)?|\d+(?:[.,]\d+)?")

RU_SUFFIXES = (
    "иями", "ями", "ами", "ился", "илась", "ились",
    "ого", "его", "ому", "ему", "ыми", "ими",
    "ах", "ях", "ов", "ев", "ей", "ый", "ий", "ая", "яя", "ое", "ее", "ые", "ие",
    "ется", "ются", "лся", "лась", "лись", "ть", "ся", "сь", "ла", "ло", "ли",
    "ем", "ом", "ым", "им", "у", "ю", "а", "я", "ы", "и", "о", "е", "ь", "й",
)

EN_SUFFIXES = ("ings", "ing", "ment", "ments", "ed", "es", "s", "ly")

CYRILLIC_RE = re.compile(r"[Ѐ-ӿ]")


def is_cyrillic(text):
    return bool(CYRILLIC_RE.search(text))


def min_stem_len(word):
    return 4 if is_cyrillic(word) else 4


def stem(word):
    """Very light stemmer: strips one inflectional suffix, never below the
    minimum stem length (so that short words stay intact)."""
    w = word.lower().replace("ё", "е")
    suffixes = RU_SUFFIXES if is_cyrillic(w) else EN_SUFFIXES
    limit = min_stem_len(w)
    for suf in sorted(suffixes, key=len, reverse=True):
        if w.endswith(suf) and len(w) - len(suf) >= limit:
            return w[: -len(suf)]
    return w


def stems_match(a, b):
    """True when two word stems denote the same word (same stem, stem prefix,
    or a close fuzzy match)."""
    if a == b:
        return True
    shorter, longer = (a, b) if len(a) <= len(b) else (b, a)
    if len(shorter) >= 4 and len(longer) - len(shorter) <= 2 and longer.startswith(shorter):
        return True
    if min(len(a), len(b)) >= 5 and abs(len(a) - len(b)) <= 4:
        # a close match must share the beginning of the word: Russian and
        # English inflection differ at the end, not in the middle
        if len(os.path.commonprefix([a, b])) >= 5:
            if difflib.SequenceMatcher(None, a, b).ratio() >= 0.70:
                return True
    if min(len(a), len(b)) >= 4 and abs(len(a) - len(b)) <= 3:
        if difflib.SequenceMatcher(None, a, b).ratio() >= 0.85:
            return True
    return False


def word_tokens(text):
    return WORD_RE.findall(text)


def lower_tokens(text):
    return [t.lower() for t in word_tokens(text)]


def normalize_numbers(text):
    out = []
    for raw in NUM_RE.findall(text):
        norm = raw.replace(" ", "").replace("\u00a0", "").replace("\u202f", "")
        norm = norm.replace(",", ".")
        if norm:
            out.append(norm)
    return out


def is_number_token(token):
    return bool(token) and all(ch.isdigit() or ch == "." for ch in token)


def text_similarity(a, b):
    """Word-level similarity of two texts, 0..1 (same metric as
    scripts/test-editing-fixtures.sh)."""
    wa = lower_tokens(a)
    wb = lower_tokens(b)
    if not wa or not wb:
        return 0.0
    return difflib.SequenceMatcher(None, wa, wb).ratio()


def literal_in_text(literal, text):
    """Case-insensitive search of a technical literal in raw text."""
    pattern = r"(?<![\w-])" + re.escape(literal) + r"(?![\w])"
    return re.search(pattern, text, re.IGNORECASE | re.UNICODE) is not None


# ------------------------------------------------------------------ frontmatter

def split_inline_list(inner):
    items, buf, quote = [], "", None
    for ch in inner:
        if quote:
            buf += ch
            if ch == quote:
                quote = None
            continue
        if ch in "\"'":
            quote = ch
            buf += ch
            continue
        if ch == ",":
            items.append(buf)
            buf = ""
            continue
        buf += ch
    if buf.strip():
        items.append(buf)
    return [i.strip() for i in items if i.strip()]


def parse_scalar(value):
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        return [parse_scalar(x) for x in split_inline_list(value[1:-1])]
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    low = value.lower()
    if low in ("true", "yes"):
        return True
    if low in ("false", "no"):
        return False
    return value


def parse_yaml_subset(lines):
    """Parser for the small YAML subset the fixtures use (scalars, inline
    lists, one level of nested maps and block lists)."""
    data = {}
    i = 0
    while i < len(lines):
        raw = lines[i]
        if not raw.strip() or raw.lstrip().startswith("#") or raw[:1] in (" ", "\t"):
            i += 1
            continue
        key, _, rest = raw.partition(":")
        key, rest = key.strip(), rest.strip()
        if rest:
            data[key] = parse_scalar(rest)
            i += 1
            continue
        block, j = [], i + 1
        while j < len(lines) and (not lines[j].strip() or lines[j][:1] in (" ", "\t")):
            block.append(lines[j])
            j += 1
        i = j
        items = [b.strip()[1:].strip() for b in block if b.strip().startswith("-")]
        if items:
            data[key] = [parse_scalar(x) for x in items]
        else:
            sub = {}
            for b in block:
                if not b.strip():
                    continue
                k, _, v = b.strip().partition(":")
                sub[k.strip()] = parse_scalar(v.strip())
            data[key] = sub
    return data


def parse_frontmatter(text):
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return {}, text
    end = None
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            end = i
            break
    if end is None:
        return {}, text
    return parse_yaml_subset(lines[1:end]), "\n".join(lines[end + 1:])


def section(body, name):
    out, collecting = [], False
    for line in body.split("\n"):
        if line.startswith("## "):
            if collecting:
                break
            collecting = line[3:].strip().lower() == name.lower()
            continue
        if collecting:
            out.append(line)
    return "\n".join(out).strip()


def as_list(value):
    if value is None:
        return []
    if isinstance(value, list):
        return [v for v in value if isinstance(v, str)]
    if isinstance(value, str):
        return [value]
    return []


# ------------------------------------------------------------- text analysis

class TextIndex:
    """Pre-computed view of a text: word stems, numbers, marker positions."""

    def __init__(self, text):
        self.text = text
        self.tokens = lower_tokens(text)
        self.stems = [stem(t) for t in self.tokens]
        self.stem_set = set(self.stems)
        self.numbers = set(normalize_numbers(text))

    def has_stem(self, needle):
        return needle in self.stem_set

    def find_stem(self, needle):
        for s in self.stems:
            if stems_match(needle, s):
                return s
        return None

    def has_number(self, number):
        return number in self.numbers

    def match_positions(self, words):
        """Position of the first occurrence of every given word."""
        positions = []
        for word in words:
            needle = stem(word)
            for i, candidate in enumerate(self.stems):
                if stems_match(needle, candidate):
                    positions.append(i)
                    break
        return positions

    def window(self, lo, hi):
        """Text of the token range [lo, hi)."""
        return " ".join(self.tokens[max(0, lo):min(len(self.tokens), hi)])

    def contains_phrase(self, phrase_tokens, max_gap=2):
        """True when the given word tokens occur in the text in the given order
        with at most max_gap other tokens in between. Every token of the
        phrase must be matched — one repeated word is not enough."""
        needles = [stem(t) for t in phrase_tokens]
        if not needles:
            return False
        position, last = 0, None
        for needle in needles:
            found = None
            for i in range(position, len(self.stems)):
                if last is not None and i - last > max_gap + 1:
                    break
                if stems_match(needle, self.stems[i]):
                    found = i
                    break
            if found is None:
                return False
            last, position = found, found + 1
        return True


def best_cluster(positions, max_gap=12):
    """Tightest span that holds as many matched positions as possible: a word
    that also occurs somewhere else in the text must not widen the span."""
    if not positions:
        return None
    ordered = sorted(positions)
    clusters = [[ordered[0]]]
    for position in ordered[1:]:
        if position - clusters[-1][-1] <= max_gap:
            clusters[-1].append(position)
        else:
            clusters.append([position])
    best = max(clusters, key=len)
    return best[0], best[-1]


def strengthening_markers(text):
    """Categorical words found in a text."""
    found = []
    low = " " + re.sub(r"[^\w\s-]", " ", text.lower()) + " "
    low = re.sub(r"\s+", " ", low)
    for marker in STRENGTHENING_MARKERS:
        if re.search(r"(?<![\w-])" + re.escape(marker) + r"(?![\w-])", low):
            found.append(marker)
    return found


def content_words(text, extra_stop=frozenset()):
    """Content-bearing words: alphabetic, long enough, not a function word."""
    out = []
    for token in word_tokens(text):
        low = token.lower()
        if len(low) < 3:
            continue
        if is_number_token(low):
            continue
        if low in STOP_RU or low in STOP_EN or low in extra_stop:
            continue
        out.append(low)
    return out


def modal_markers(text):
    """Hedge markers found in a text: list of (marker, family)."""
    found = []
    low = " " + re.sub(r"[^\w\s-]", " ", text.lower()) + " "
    low = re.sub(r"\s+", " ", low)
    for family, classes in MODAL_FAMILIES.items():
        for markers in classes.values():
            for marker in markers:
                if " " in marker:
                    if marker in low:
                        found.append((marker, family))
                elif re.search(r"(?<![\w-])" + re.escape(marker) + r"(?![\w-])", low):
                    found.append((marker, family))
    return found


def negation_markers(text):
    return [t for t in lower_tokens(text) if t in NEGATION_RU or t in NEGATION_EN]


def strip_parenthetical(text):
    return re.sub(r"\([^)]*\)", " ", text)


# ------------------------------------------------------------------ reporting

class Report:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.skipped = 0

    def ok(self, name, detail=""):
        self.passed += 1
        print("PASS: %s%s" % (name, (" — " + detail) if detail else ""))

    def bad(self, name, detail=""):
        self.failed += 1
        print("FAIL: %s%s" % (name, (" — " + detail) if detail else ""))

    def skip(self, name, detail=""):
        self.skipped += 1
        print("SKIP: %s%s" % (name, (" — " + detail) if detail else ""))


# ------------------------------------------------------------------ the checks

# The reference edit ("## Gold edit") shows how much of a required item a
# correct edit may reasonably keep. The output must keep at least that much,
# with a small tolerance; the floor keeps the check meaningful even when the
# reference edit itself is loose.
COVERAGE_FLOOR = 0.1
COVERAGE_TOLERANCE = 0.2

# How many tokens around a claim still count as "next to it" when looking
# for the hedge that qualifies it. The margin behind the claim is smaller:
# a hedge that opens the claim ("может снижать") belongs to it, while a hedge
# several clauses earlier usually qualifies something else.
MODAL_MARGIN_BEFORE = 3
MODAL_MARGIN_AFTER = 6


def coverage_of(words, index):
    """Fraction of the given words that the indexed text contains."""
    if not words:
        return None, []
    found, missing = 0, []
    for word in words:
        if index.find_stem(stem(word)) is not None:
            found += 1
        else:
            missing.append(word)
    return found / len(words), missing


def check_preservation(rep, kind, entries, out_index, gold_index, require_modal=False):
    """Shared logic for claims / conditions / exceptions / terminology /
    uncertainty: the key words of every required item must survive."""
    for number, entry in enumerate(entries, 1):
        name = "%s-preserved[%d]" % (kind, number)
        label = entry[:70] + ("…" if len(entry) > 70 else "")
        entry_stemmed = strip_parenthetical(entry)
        # for uncertainty entries the hedge is checked separately, so modal
        # words are not counted as content
        extra_stop = MODAL_MARKER_WORDS if require_modal else frozenset()
        words = content_words(entry_stemmed, extra_stop)
        if not words:
            # nothing to match by keyword — fall back to a literal check
            literal = entry.strip()
            if literal and literal.lower() in out_index.text.lower():
                rep.ok(name, "«%s» присутствует буквально" % label)
            elif literal and literal.lower() in gold_index.text.lower():
                rep.bad(name, "потеряно утверждение/условие — «%s» исчез" % label)
            else:
                rep.skip(name, "нет ключевых слов для проверки")
            continue

        cov_out, missing_out = coverage_of(words, out_index)
        cov_gold, _ = coverage_of(words, gold_index)
        if cov_gold is None or cov_gold <= 0.0:
            rep.skip(name, "эталонная редакция не сохраняет ключевые слова — проверка невозможна")
            continue
        bar = max(COVERAGE_FLOOR, cov_gold - COVERAGE_TOLERANCE)
        detail = "покрытие %.2f, порог %.2f; потеряно: %s | «%s»" % (
            cov_out, bar, ", ".join(missing_out[:6]) or "—", label)

        # Negations flip the meaning when they disappear — they are required
        # outright (as long as the reference edit keeps them).
        lost_neg = [n for n in negation_markers(entry)
                    if gold_index.has_stem(stem(n)) and not out_index.has_stem(stem(n))]
        if lost_neg:
            rep.bad(name, "потеряно отрицание «%s»; %s" % (", ".join(lost_neg), detail))
            continue

        if cov_out < bar - 1e-9:
            reason = "ослаблена/усилена модальность" if require_modal else "потеряно утверждение/условие"
            rep.bad(name, "%s — покрытие %.2f < порог %.2f; потеряно: %s | «%s»" % (
                reason, cov_out, bar, ", ".join(missing_out[:6]) or "—", label))
            continue

        if require_modal:
            relevant = [(m, f) for m, f in modal_markers(entry_stemmed)
                        if gold_index.contains_phrase(m.split())]
            if relevant:
                families = {f for _, f in relevant}
                # the hedge has to sit next to the claim it qualifies, not
                # somewhere else in the text
                positions = out_index.match_positions(words)
                near = False
                window = ""
                span = best_cluster(positions)
                if span:
                    window = out_index.window(span[0] - MODAL_MARGIN_BEFORE,
                                              span[1] + MODAL_MARGIN_AFTER + 1)
                    near = any(f in families for _, f in modal_markers(window))
                    strengthened = strengthening_markers(window)
                    if strengthened:
                        rep.bad(name, "усилена модальность — категоричное слово «%s» рядом с "
                                      "утверждением; %s" % (", ".join(strengthened), detail))
                        continue
                # name the most specific marker, not every generic one
                named = sorted({m for m, _ in relevant}, key=len, reverse=True)[:2]
                if not near and not any(f in families
                                        for _, f in modal_markers(out_index.text)):
                    rep.bad(name, "ослаблена/усилена модальность — маркер «%s» исчез; %s" % (
                        ", ".join(named), detail))
                    continue
                if not near:
                    rep.bad(name, "ослаблена/усилена модальность — маркер «%s» остался в тексте, "
                                  "но не у этого утверждения; %s" % (
                                      ", ".join(named), detail))
                    continue

        rep.ok(name, "покрытие %.2f ≥ порог %.2f | «%s»" % (cov_out, bar, label))


def check_numbers(rep, source, out_index, allow_drop):
    name = "numbers-preserved"
    src_numbers = normalize_numbers(source)
    if not src_numbers:
        rep.skip(name, "в Source нет чисел")
        return
    if allow_drop:
        rep.skip(name, "allow_number_drop: true — проверка пропущена")
        return
    missing = [n for n in dict.fromkeys(src_numbers) if not out_index.has_number(n)]
    if missing:
        rep.bad(name, "потеряно число/факт: %s" % ", ".join(missing))
    else:
        rep.ok(name, "все %d чисел Source на месте" % len(set(src_numbers)))


def check_invented(rep, source, out_index):
    name = "no-invented-numbers"
    src_numbers = set(normalize_numbers(source))
    invented = [n for n in dict.fromkeys(normalize_numbers(out_index.text))
                if n not in src_numbers]
    if invented:
        rep.bad(name, "выдуман факт — числа отсутствуют в Source: %s" % ", ".join(invented))
    else:
        rep.ok(name, "новых чисел нет")


def forbidden_markers(entry):
    """Markers that betray an addition described by a forbidden_additions
    entry: quoted literals, technical literals and Russian/English phrases."""
    markers = []

    for literal in re.findall(r"[«\"']([^»\"']{2,})[»\"']", entry):
        markers.append(("literal", literal))

    # drop the qualifier clause ("..., которых нет в исходнике")
    trimmed = re.split(r",\s*(?:которых|который|которое|которые|не\s+упомянутые|"
                       r"не\s+упомянутый|not\s+in\s+the\s+source|beyond\s+the\s+source)",
                       entry)[0]

    for token in LITERAL_RE.findall(trimmed):
        token = token.rstrip("-._+/=")
        low = token.lower()
        if len(low) < 2 or low in META_WORDS or low in STOP_EN or low in STOP_RU:
            continue
        markers.append(("literal", token))

    # the phrase itself is a marker too: "личный опыт", "перцентили", ...
    words = [w.lower() for w in word_tokens(trimmed)
             if len(w) >= 3 and w.lower() not in META_WORDS
             and w.lower() not in STOP_RU and w.lower() not in STOP_EN]
    if words:
        markers.append(("phrase", words))
    return markers


def check_forbidden(rep, entries, out_index, source_index):
    name = "no-forbidden-additions"
    if not entries:
        rep.skip(name, "список forbidden_additions пуст")
        return
    hits = []
    for number, entry in enumerate(entries, 1):
        found = None
        for kind, payload in forbidden_markers(entry):
            if kind == "literal":
                if literal_in_text(payload, source_index.text):
                    continue  # already in the source — not an addition
                if literal_in_text(payload, out_index.text):
                    found = payload
                    break
                continue
            if kind == "phrase":
                if source_index.contains_phrase(payload):
                    continue
                if out_index.contains_phrase(payload):
                    found = " ".join(payload)
                    break
        if found:
            hits.append((number, entry, found))
    if hits:
        rep.bad(name, "добавлено запрещённое: " + "; ".join(
            "«%s» → %s" % (e[:50], f) for _, e, f in hits))
    else:
        rep.ok(name, "запрещённых добавлений нет (%d правил)" % len(entries))


def check_already_good(rep, genre, source, out_index):
    name = "already-good-unchanged"
    if genre != "already-good":
        rep.skip(name, "категория фикстуры «%s»" % genre)
        return
    ratio = text_similarity(source, out_index.text)
    if ratio >= 0.8:
        rep.ok(name, "сходство %.2f ≥ 0.80" % ratio)
    else:
        rep.bad(name, "хороший текст переписан зря — сходство %.2f < 0.80" % ratio)


# ------------------------------------------------------------------ main

def main(argv):
    if len(argv) != 2:
        print("usage: check-editing-output.sh <output-file> <fixture-file>", file=sys.stderr)
        return 2
    out_path, fix_path = argv
    for path in (out_path, fix_path):
        if not os.path.isfile(path):
            print("ERROR: file not found: %s" % path, file=sys.stderr)
            return 2
    with open(out_path, encoding="utf-8") as fh:
        out_text = fh.read()
    with open(fix_path, encoding="utf-8") as fh:
        fix_text = fh.read()

    fm, body = parse_frontmatter(fix_text)
    source = section(body, "Source")
    gold = section(body, "Gold edit")
    if not source:
        print("ERROR: fixture has no '## Source' section: %s" % fix_path, file=sys.stderr)
        return 2

    rep = Report()
    out_index = TextIndex(out_text)
    gold_index = TextIndex(gold)
    source_index = TextIndex(source)

    preserved = fm.get("required_preservation") or {}
    if not isinstance(preserved, dict):
        preserved = {}
    allow_drop = bool(fm.get("allow_number_drop", False))
    genre = str(fm.get("genre", "") or "")

    print("Проверка результата редактуры")
    print("  output:   %s" % out_path)
    print("  fixture:  %s" % fix_path)
    print("")

    check_numbers(rep, source, out_index, allow_drop)
    check_preservation(rep, "claim", as_list(preserved.get("claims")), out_index, gold_index)
    check_preservation(rep, "condition", as_list(preserved.get("conditions")), out_index, gold_index)
    check_preservation(rep, "exception", as_list(preserved.get("exceptions")), out_index, gold_index)
    check_preservation(rep, "terminology", as_list(preserved.get("terminology")), out_index, gold_index)
    check_preservation(rep, "uncertainty", as_list(preserved.get("uncertainty")), out_index,
                       gold_index, require_modal=True)
    check_invented(rep, source, out_index)
    check_forbidden(rep, as_list(fm.get("forbidden_additions")), out_index, source_index)
    check_already_good(rep, genre, source, out_index)

    print("")
    print("Summary: passed %d, failed %d (skipped %d)" % (rep.passed, rep.failed, rep.skipped))
    return 1 if rep.failed else 0


sys.exit(main(sys.argv[1:]))
PYEOF
  exit $?
fi

# =====================================================================
# --selftest: the validator must accept a faithful edit and catch a
# broken one. Runs in a temporary directory, leaves nothing behind.
# =====================================================================
selftest() {
  local tmp good bad fix log rc failures=0

  tmp="$(mktemp -d)" || { echo "selftest: cannot create temp dir" >&2; return 1; }
  trap 'rm -rf "$tmp"' RETURN

  cat > "$tmp/fixture.md" <<'EOF'
---
id: selftest-1
language: ru
genre: already-good
audience: general
edit_mode: proofread
required_preservation:
  claims: ["в выборке из 48 участников средняя утомляемость была ниже"]
  conditions: ["если кеш отключён, сборка выполняется полностью"]
  exceptions: []
  uncertainty: ["перерывы могут снижать утомляемость (не «снижают»)"]
  terminology: ["идемпотентность"]
forbidden_additions: ["личный опыт", "p99"]
expected_issues: []
allow_major_rewrite: false
---

## Source
В выборке из 48 участников средняя утомляемость была ниже. Если кеш отключён, сборка выполняется полностью. Перерывы могут снижать утомляемость операторов. Обработчик должен быть идемпотентным.

## Gold edit
В выборке из 48 участников средняя утомляемость была ниже. Если кеш отключён, сборка выполняется полностью. Перерывы могут снижать утомляемость операторов. Обработчик должен быть идемпотентным.
EOF

  cat > "$tmp/good.md" <<'EOF'
В выборке из 48 участников средняя утомляемость была ниже. Если кеш отключён, сборка выполняется полностью. Перерывы могут снижать утомляемость операторов. Обработчик должен быть идемпотентным.
EOF

  # broken: lost number, lost claim, lost condition, de-hedged modality,
  # forbidden addition, invented number.
  cat > "$tmp/bad.md" <<'EOF'
В выборке участников. Перерывы снижают утомляемость операторов. По моему личному опыту, p99 составил 5 мс.
EOF

  echo "selftest: faithful edit must pass"
  bash "$SCRIPT_PATH" "$tmp/good.md" "$tmp/fixture.md" > "$tmp/good.log" 2>&1
  rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "  FAIL: faithful edit rejected (exit $rc)" >&2
    sed 's/^/    | /' "$tmp/good.log" >&2
    failures=$((failures + 1))
  else
    echo "  PASS: faithful edit accepted"
  fi

  echo "selftest: broken edit must be caught"
  bash "$SCRIPT_PATH" "$tmp/bad.md" "$tmp/fixture.md" > "$tmp/bad.log" 2>&1
  rc=$?
  if [[ $rc -ne 1 ]]; then
    echo "  FAIL: broken edit was not rejected (exit $rc, expected 1)" >&2
    sed 's/^/    | /' "$tmp/bad.log" >&2
    failures=$((failures + 1))
  else
    echo "  PASS: broken edit rejected (exit 1)"
  fi

  local expected=(
    "FAIL: numbers-preserved"
    "FAIL: claim-preserved[1]"
    "FAIL: condition-preserved[1]"
    "FAIL: uncertainty-preserved[1]"
    "FAIL: no-invented-numbers"
    "FAIL: no-forbidden-additions"
  )
  local pattern
  for pattern in "${expected[@]}"; do
    if ! grep -qF "$pattern" "$tmp/bad.log"; then
      echo "  FAIL: broken edit did not trigger «$pattern»" >&2
      failures=$((failures + 1))
    fi
  done
  if [[ $failures -eq 0 ]]; then
    echo "  PASS: all expected violations detected"
  fi

  echo "selftest: usage error must exit 2"
  bash "$SCRIPT_PATH" "$tmp/does-not-exist.md" "$tmp/fixture.md" > /dev/null 2>&1
  rc=$?
  if [[ $rc -ne 2 ]]; then
    echo "  FAIL: missing file gave exit $rc, expected 2" >&2
    failures=$((failures + 1))
  else
    echo "  PASS: usage error handled"
  fi

  # The reference edits of the real fixtures must satisfy the validator.
  local fixtures_dir
  fixtures_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tests/fixtures/editing"
  if [[ -d "$fixtures_dir" ]]; then
    echo "selftest: reference edits of tests/fixtures/editing must pass"
    local f base
    shopt -s nullglob
    for f in "$fixtures_dir"/*.md; do
      base="$(basename "$f" .md)"
      awk '/^## Gold edit/{flag=1; next} /^## /{flag=0} flag' "$f" > "$tmp/gold-$base.md"
      bash "$SCRIPT_PATH" "$tmp/gold-$base.md" "$f" > "$tmp/gold-$base.log" 2>&1
      rc=$?
      if [[ $rc -ne 0 ]]; then
        echo "  FAIL: reference edit $base does not pass" >&2
        sed 's/^/    | /' "$tmp/gold-$base.log" >&2
        failures=$((failures + 1))
      fi
    done
    shopt -u nullglob
    if [[ $failures -eq 0 ]]; then
      echo "  PASS: all reference edits pass"
    fi
  fi

  if [[ $failures -gt 0 ]]; then
    echo "selftest: FAILED ($failures problem(s))" >&2
    return 1
  fi
  echo "selftest: OK"
  return 0
}

selftest
exit $?
