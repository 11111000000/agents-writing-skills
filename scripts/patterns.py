#!/usr/bin/env python3
"""Рамочные детекторы паттернов для benchmark-skill.sh.

Зачем отдельный хелпер, а не ещё один grep:

  * Shell-детекторы смотрели на сырые строки. Паттерн, разорванный мягким
    переносом строки, был невидим: один и тот же текст давал AP 0.0 с
    переносом и 166.67 без него.
  * AP-детектор ловил ОДИН лексический якорь («это не X, а Y») и находил
    0 из 8 канонических примеров каталога: «Это» в начале фразы никогда не
    матчилось. Пропускались все остальные поверхностные формы той же
    риторической рамки.
  * P-NEW-19 не мог сработать никогда: `/[.!?]+[^.!?]*$/` откатывался на
    последнюю точку, поэтому «closer» всегда был пустым.
  * P-NEW-16 существовал только на английском.

Ключевой принцип: детектор меряет РИТОРИЧЕСКУЮ РАМКУ, а не лексический
якорь. Приём лечения вроде «нулевой связки» (убрать «это» из «Это не X, а
Y») не должен делать рамку невидимой — иначе лечение обходит счётчик.

Классы AP разделены на strong и weak не по вкусу, а по измерению:
strong — рамка однозначна (отрицание одной характеристики заменяется другой),
weak — обычный контраст, который встречается и у человека («не X, но Y»).

Использование:
  patterns.py --normalize    # нормализованный текст (абзацы склеены)
  patterns.py --env          # KEY=VALUE для подстановки в bash
  patterns.py --json         # подробный JSON со всеми классами
"""

import json
import re
import sys

# --------------------------------------------------------------------------
# AP (P9 negative parallelism) — риторические рамки
# --------------------------------------------------------------------------

# strong: отрицание одной характеристики заменяется другой.
RU_STRONG = [
    ("A", re.compile(r"\bне\s+[^,.;:!?]{2,70},\s+а\s+[^,.;:!?]{2,70}", re.I)),
    ("A_graded", re.compile(r"\bне\s+столько\s+[^,.;:!?]{2,60},\s+сколько\s+[^,.;:!?]{2,60}", re.I)),
    ("A_excl", re.compile(r"\bне\s+(?:только|просто)\s+[^,.;:!?]{2,60},\s+но\s+(?:ещё\s+)?(?:и\s+)?[^,.;:!?]{2,60}", re.I)),
]
EN_STRONG = [
    ("A_en", re.compile(
        r"\b(?:it'?s\s+not|this\s+is\s+not|this\s+isn't|that\s+is\s+not|that\s+isn't)\s+"
        r"[^,.;:!?]{2,60},?\s*(?:—|–|-)?\s*"
        r"(?:it'?s|this\s+is|that\s+is)\s+[^,.;:!?]{2,60}", re.I)),
    ("A_en_graded", re.compile(r"\bnot\s+so\s+much\s+[^,.;:!?]{2,60}\s+as\s+[^,.;:!?]{2,60}", re.I)),
    ("A_en_excl", re.compile(r"\bnot\s+only\s+[^,.;:!?]{2,60}\s+but\s+also\s+[^,.;:!?]{2,60}", re.I)),
    ("A_en_just", re.compile(r"\bnot\s+just\s+[^,.;:!?]{2,60},?\s*but\s+[^,.;:!?]{2,60}", re.I)),
]

# weak: обычный контраст без замены характеристики.
EN_WEAK = [
    ("A_but_en", re.compile(
        r"\b(?:it'?s\s+not|this\s+is\s+not|this\s+isn't|that\s+is\s+not|that\s+isn't)\s+"
        r"[^,.;:!?]{2,60},\s+but\s+[^,.;:!?]{2,60}", re.I)),
]

# weak: контраст без замены характеристики.
RU_WEAK = [
    ("A_but", re.compile(r"\bне\s+[^,.;:!?]{2,70},\s+но\s+[^,.;:!?]{2,70}", re.I)),
    ("C_dash", re.compile(r"\bне\s+[^.;!?—]{2,70}\s+—\s+(?:а|это|значит|вместо)", re.I)),
    ("E_inverted", re.compile(r"[^,.;:!?]{15,70},\s+а\s+не\s+[^,.;:!?]{2,60}", re.I)),
    ("F_versus", re.compile(r"\bвместо\s+[^,.;:!?]{2,60}\s+—\s+[^,.;:!?]{2,60}", re.I)),
]

# Иерархический антитезис (каталог §3.4): «Это больше, чем X. Это Y.»
# Требуем демонстративный подлежащее: «В зале было больше, чем сто человек» —
# это не антитезис, а обычное сравнение.
HIER_HEAD = re.compile(
    r"^(?:(?:это|эта|этот|эти)\s+(?:больше|меньше|не\s+более|не\s+менее)\s*,?\s*чем\s+"
    r"[^.!?]{2,70}"
    r"|(?:it'?s|this\s+is|that\s+is)\s+(?:more|less)\s+than\s+[^.!?]{2,70})",
    re.I,
)

# Кросс-предложная рамка: «…не X. Это Y.» / «…не X. А про Y.»
RU_RESTART = re.compile(r"^(Это|Эта|Этот|Он|Она|Оно|А)\b", re.I)
EN_RESTART = re.compile(r"^(It|This|That|They)\b", re.I)
NEG_TAIL = re.compile(r"\bне\b|\bnot\b", re.I)
NEG_HEAD = re.compile(r"^(?:это|эта|этот|он|она|оно|it|this|that)\s+не\b", re.I)

# Эллипсис в концовке абзаца: короткий огрызок с пропущенным подлежащим
# («Не про это.»), продолжающий предыдущую мысль. Только в последнем
# предложении абзаца и только если это не самостоятельная антитеза.
ELLIP_HEAD = re.compile(r"^(?:Но\s+не|Не)\b", re.I)
ELLIP_HEAD_EN = re.compile(r"^(?:Not\s+just\s+not|It'?s\s+not)\b", re.I)

# --------------------------------------------------------------------------
# P-NEW-16 Argument Residue — «оппонент, которого никто не называл»
# --------------------------------------------------------------------------

# Оппонент без имени (по каталогу: hypothetical opponents without named referents)
OPPONENT_RU = re.compile(
    r"(?:^|[.!?—–]\s+|\bа\s+)\s*(?:Некоторые|Критики|Скептики|Часть\s+(?:исследователей|аудитории)|"
    r"Отдельные\s+(?:эксперты|специалисты))\s+"
    r"(?:могут\s+|нередко\s+|часто\s+|иногда\s+|склонны\s+)?"
    # Глаголы во всех лицах: «утверждают», «возражают», «возразить», «указывают».
    r"(?:утвержд\w*|возраж\w*|возраз\w*|указыва\w*|говор\w*|полага\w*|заявля\w*|отмеча\w*|счита\w*)",
    re.I,
)
OPPONENT_EN = re.compile(
    r"\b(?:while|although|though)\s+(?:some|critics|skeptics|detractors|others)\s+"
    r"(?:might\s+|may\s+|often\s+|tend\s+to\s+)?"
    r"(?:argue|claim|suggest|point\s+out|contend|insist)\b"
    r"|\b(?:critics|skeptics|detractors|others|some\s+might)\s+"
    r"(?:may\s+|might\s+|often\s+|tend\s+to\s+)?"
    r"(?:argue|claim|suggest|point\s+out|contend|insist)\b",
    re.I,
)

# Маркер добивания: «…но данные говорят иное», «однако», «тем не менее».
REBUT_RU = re.compile(
    r"\b(?:но|однако|тем\s+не\s+менее|всё\s+же|хотя|не\s+только\s+что|в\s+реальности|"
    r"на\s+деле|данные\s+говорят|факты\s+показывают|как\s+показывает\s+практика)\b",
    re.I,
)
REBUT_EN = re.compile(
    r"\b(?:but|however|yet|nonetheless|still|though|the\s+reality\s+is|the\s+data\s+"
    r"(?:tells|shows)|in\s+practice|actually)\b",
    re.I,
)

# Именованный оппонент: если в абзаце он есть, возражение не «риторический след».
NAMED_OPPONENT = re.compile(
    r"\b(?:по\s+мнению|по\s+словам|как\s+пишет|как\s+считает|отчёт|исследование|"
    r"в\s+статье|по\s+данным|комментарий\s+[А-ЯЁ]|в\s+интервью|"
    r"according\s+to|reviewer|researcher|according)\b",
    re.I,
)

# Старый детектор (только EN): два контрастивных коннектора в одном предложении.
ARG_CONNECTORS = re.compile(
    r"\b(?:however|though|yet|still|nonetheless|однако|хотя|всё\s+же|тем\s+не\s+менее|"
    r"но\s+всё\s+же|и\s+всё\s+же)\b",
    re.I,
)

# --------------------------------------------------------------------------
# P-NEW-18 Asyndeton Tricolon — бессоюзное трикольцо с НАРАСТАЮЩЕЙ сложностью
# --------------------------------------------------------------------------

# Соединители, которых быть не должно: asyndeton = члены без союзов.
CONJUNCTION = re.compile(
    r"\b(?:и|а|но|или|либо|также|кроме\s+того|плюс|а\s+также|и\s+так|зато|однако)\b|"
    r"\b(?:and|or|but|plus|as\s+well\s+as)\b",
    re.I,
)

# --------------------------------------------------------------------------
# P-NEW-19 Mini-Aphorism Closer — мини-афоризм в концовке абзаца
# --------------------------------------------------------------------------

APHORISM_RU = re.compile(
    r"(?:^|\.\s+)(?:Урок\s*:|Вот\s+(?:в\s+чём|что)\s+|Именно\s+так\s+и\s+|Вот\s+и\s+всё|"
    r"В этом\s+и\s+смысл|И\s+вот\s+в\s+чём\s+дело)",
    re.I,
)
APHORISM_EN = re.compile(
    r"(?:^|\.\s+)(?:That's\s+the\s+(?:real|actual|whole|part|lesson|point|thing)\b|"
    r"Slide\s+decks\s+don't\b|That's\s+what\s+changed\b|Process\s+is\s+(?:the|actually)\s+|"
    r"The\s+lesson\s*:)",
    re.I,
)

# --------------------------------------------------------------------------
# Служебное
# --------------------------------------------------------------------------

HEADING = re.compile(r"^\s{0,3}#{1,6}\s")
LIST_ITEM = re.compile(r"^\s*(?:[-*+•]|\d+[.)])\s+")
QUOTE = re.compile(r"^\s*>")
SENT_END = (".", "!", "?", "…", ":")

FRONTMATTER = re.compile(r"\A---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\Z)", re.S)


def strip_frontmatter(text: str) -> str:
    """Убрать YAML-frontmatter в начале файла.

    Метаданные фикстуры — не проза: без этого frontmatter становился
    «абзацем» (ложный конёк-афоризм P-NEW-19) и попадал в счёт слов.
    """
    m = FRONTMATTER.match(text.replace("\r\n", "\n").replace("\r", "\n"))
    if not m:
        return text
    # Отсекаем только если блок действительно выглядит как frontmatter.
    if not re.search(r"^[A-Za-z_][A-Za-z0-9_.-]*\s*:", m.group(1), re.M):
        return text
    return text[m.end():]


def blocks(text: str):
    """Разбить текст на абзацы (пустая строка — граница)."""
    text = strip_frontmatter(text)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    out, cur = [], []
    for line in text.split("\n"):
        if not line.strip():
            if cur:
                out.append(cur)
                cur = []
            continue
        cur.append(line)
    if cur:
        out.append(cur)
    return out


def units(para_lines):
    """Разбить абзац на юниты.

    Заголовок, пункт списка и цитата остаются отдельными строками: иначе
    нормализация склеила бы markdown-документ в один абзац и сломала бы
    метрики LISTS, PARAS и SPECIFICITY. Проза склеивается по мягкому переносу:
    строка продолжается, только если предыдущая не кончилась знаком конца
    предложения.
    """
    out, buf = [], []

    def flush():
        if buf:
            out.append(" ".join(buf))
            buf.clear()

    for line in para_lines:
        stripped = line.strip()
        if HEADING.match(line) or LIST_ITEM.match(line) or QUOTE.match(line):
            flush()
            out.append(stripped)
            continue
        if buf and not buf[-1].rstrip().endswith(SENT_END):
            buf[-1] = buf[-1].rstrip() + " " + stripped
        else:
            buf.append(stripped)
    flush()
    return out


def normalize(text: str) -> str:
    """Абзац на строку: мягкие переносы внутри абзаца склеены.

    Абзацы (пустая строка) и структурные строки (заголовки, пункты списка,
    цитаты) сохраняются: иначе детектор абзацных концовок (P-NEW-19)
    склеил бы соседние абзацы в один, а счётчики списков — обнулились бы.
    """
    out = []
    for para in blocks(text):
        out.append(" ".join(units(para)))
    return "\n\n".join(out)


def sentence_lines(text: str) -> str:
    """Предложение на строку, абзацы разделены пустой строкой.

    Нужен shell-детекторам, которые якорем `^` ловят начало предложения
    (V, P-NEW-20) или начало строки (D, LISTS). После нормализации «начало
    строки» и «начало предложения» — разные вещи, и без этого рендера
    якори потеряли бы смысл.
    """
    out = []
    for para in blocks(text):
        para_units = units(para)
        lines = []
        for unit in para_units:
            if LIST_ITEM.match(unit) or QUOTE.match(unit) or HEADING.match(unit):
                lines.append(unit)
                continue
            for sent in split_sentences(unit):
                lines.append(sent)
        if lines:
            out.append("\n".join(lines))
    return "\n\n".join(out)


def paragraphs(text: str):
    for para in text.split("\n\n"):
        lines = [ln for ln in para.split("\n") if ln.strip() and not HEADING.match(ln)]
        if lines:
            yield " ".join(lines)


def split_sentences(para: str):
    return [s.strip() for s in re.split(r"(?<=[.!?…])\s+", para) if s.strip()]


def count_words(text: str) -> int:
    return len(text.split())


# --------------------------------------------------------------------------
# AP
# --------------------------------------------------------------------------

def detect_ap(text: str):
    """Вернуть (strong, weak) — списки сработавших рамок."""
    strong, weak = [], []
    for para in paragraphs(text):
        sents = split_sentences(para)
        for i, sent in enumerate(sents):
            hit_strong = False
            for tag, rx in RU_STRONG + EN_STRONG:
                for m in rx.finditer(sent):
                    strong.append({"tag": tag, "text": m.group(0)[:140]})
                    hit_strong = True
            for tag, rx in RU_WEAK + EN_WEAK:
                for m in rx.finditer(sent):
                    weak.append({"tag": tag, "text": m.group(0)[:140]})
            # Кросс-предложная рамка: первое предложение заканчивается
            # отрицанием, второе начинается с указательного местоимения.
            if i + 1 < len(sents) and not hit_strong:
                nxt = sents[i + 1]
                tail = " ".join(sent.split()[-6:])
                if NEG_TAIL.search(tail) and (RU_RESTART.match(nxt) or EN_RESTART.match(nxt)) \
                        and not NEG_HEAD.match(nxt):
                    strong.append({"tag": "B_cross",
                                   "text": (sent[-70:] + " || " + nxt[:70])})
            # Иерархический антитезис: «Это больше, чем X. Это Y.»
            if i + 1 < len(sents) and not hit_strong and HIER_HEAD.match(sent):
                nxt = sents[i + 1]
                if (RU_RESTART.match(nxt) or EN_RESTART.match(nxt)) and not NEG_HEAD.match(nxt):
                    strong.append({"tag": "G_hier",
                                   "text": (sent[-70:] + " || " + nxt[:70])})
            # Эллипсис-концовка: огрызок с пропущенным подлежащим в последнем
            # предложении абзаца. Самостоятельные антитезы сюда не попадают.
            if i == len(sents) - 1 and len(sent.split()) <= 6 and not hit_strong \
                    and (ELLIP_HEAD.match(sent) or ELLIP_HEAD_EN.match(sent)):
                weak.append({"tag": "D_ellipsis", "text": sent[:90]})
    return strong, weak


# --------------------------------------------------------------------------
# P-NEW-16
# --------------------------------------------------------------------------

def detect_argument_residue(text: str):
    """Возражение позиции, которой в тексте нет: оппонент без имени."""
    out = []
    for para in paragraphs(text):
        named = bool(NAMED_OPPONENT.search(para))
        for sent in split_sentences(para):
            opp_ru = OPPONENT_RU.search(sent)
            opp_en = OPPONENT_EN.search(sent)
            if not (opp_ru or opp_en):
                continue
            rebut = REBUT_RU.search(sent) or REBUT_EN.search(sent)
            out.append({
                "kind": "unnamed_opponent" if not named else "named_opponent_elsewhere",
                "rebutted": bool(rebut),
                "text": sent[:150],
            })
    # Второй, более слабый сигнал: два контрастивных коннектора в одном
    # предложении (старая, только-EN версия детектора).
    doubles = []
    for para in paragraphs(text):
        for sent in split_sentences(para):
            conns = ARG_CONNECTORS.findall(sent)
            if len(conns) >= 2:
                doubles.append({"text": sent[:150], "connectors": len(conns)})
    return out, doubles


# --------------------------------------------------------------------------
# P-NEW-18
# --------------------------------------------------------------------------

def detect_tricolons(text: str):
    """Бессоюзное трикольцо с нарастающей сложностью.

    По каталогу: три члена подряд, через запятые, без союзов, каждый
    «тяжелее» предыдущего. Длина в словах — прокси тяжести: последний член
    должен быть минимум на два слова длиннее первого. Оба канонических
    примера каталога под это правило попадают («Два часа деградации сервиса,
    шесть инженеров, разбирающихся в моей ошибке, постмортем, на котором я
    объяснял свою логику людям, которых подняли по тревоге ночью.»).
    """
    out = []
    for para in paragraphs(text):
        for sent in split_sentences(para):
            body = sent.rstrip(".!?…").strip()
            if not body:
                continue
            segments = [s.strip() for s in body.split(",")]
            if len(segments) < 3:
                continue
            for start in range(len(segments) - 2):
                trio = segments[start:start + 3]
                lengths = [len(s.split()) for s in trio]
                if min(lengths) < 1:
                    continue
                # Ни союзов, ни вводных конструкций внутри членов.
                if any(CONJUNCTION.search(s) for s in trio):
                    continue
                # Нарастание тяжести: последний член заметно длиннее первого.
                if lengths[2] < lengths[0] + 2:
                    continue
                out.append({"lengths": lengths, "text": sent[:150]})
                break
    return out


# --------------------------------------------------------------------------
# P-NEW-19
# --------------------------------------------------------------------------

def detect_closers(text: str):
    """Абзац заканчивается коротким предложением — кандидат в мини-афоризм."""
    out = []
    for para in paragraphs(text):
        sents = split_sentences(para)
        if not sents:
            continue
        last = sents[-1]
        wc = len(last.split())
        if 0 < wc <= 7:
            aphoristic = bool(APHORISM_RU.search(last) or APHORISM_EN.search(last))
            out.append({"words": wc, "aphoristic": aphoristic, "text": last[:110]})
    return out


# --------------------------------------------------------------------------
# Сборка
# --------------------------------------------------------------------------

def analyse(text: str) -> dict:
    text = normalize(text)
    strong, weak = detect_ap(text)
    residue, residue_doubles = detect_argument_residue(text)
    tri = detect_tricolons(text)
    closers = detect_closers(text)
    words = count_words(text) or 0

    def per1k(n):
        return round(n * 1000 / words, 3) if words else 0.0

    by_class = {}
    for item in strong + weak:
        by_class[item["tag"]] = by_class.get(item["tag"], 0) + 1

    return {
        "words": words,
        "ap_strong": len(strong),
        "ap_weak": len(weak),
        "ap_strong_per_1k": per1k(len(strong)),
        "ap_weak_per_1k": per1k(len(weak)),
        "ap_by_class": by_class,
        "ap_frames": strong[:120],
        "ap_weak_frames": weak[:120],
        "p16_unnamed_opponent": len(residue),
        "p16_examples": residue[:20],
        "p16_double_connectors": len(residue_doubles),
        "p16_double_examples": residue_doubles[:10],
        "p18_tricolons": len(tri),
        "p18_examples": tri[:20],
        "p19_closers": len(closers),
        "p19_aphoristic": sum(1 for c in closers if c["aphoristic"]),
        "p19_examples": closers[:20],
    }


ENV_KEYS = [
    ("AP_STRONG", "ap_strong"),
    ("AP_WEAK", "ap_weak"),
    ("AP_STRONG_PER_1K", "ap_strong_per_1k"),
    ("AP_WEAK_PER_1K", "ap_weak_per_1k"),
    ("P16_UNNAMED_OPPONENT", "p16_unnamed_opponent"),
    ("P16_DOUBLE_CONNECTORS", "p16_double_connectors"),
    ("P18_TRICOLONS", "p18_tricolons"),
    ("P19_CLOSERS", "p19_closers"),
    ("P19_APHORISTIC", "p19_aphoristic"),
]


def main() -> int:
    args = sys.argv[1:]
    raw = sys.stdin.read()
    if "--normalize" in args:
        sys.stdout.write(normalize(raw))
        return 0
    if "--sentences" in args:
        sys.stdout.write(sentence_lines(raw))
        return 0

    result = analyse(raw)

    if "--env" in args:
        for env_name, key in ENV_KEYS:
            value = result[key]
            if isinstance(value, float):
                value = f"{value:.3f}"
            sys.stdout.write(f"{env_name}={value}\n")
        return 0

    sys.stdout.write(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
