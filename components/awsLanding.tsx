import { QuartzComponent } from "@quartz-community/types"

type Props = { fileData?: { frontmatter?: { lang?: string } } }

const STRINGS = {
  en: {
    kicker: "Agent skills for prose · 2026 release",
    hero_l1: "Skills that make text",
    hero_l2: "less like a model.",
    lead: "Four skills, nine prompts, and a 41-note knowledge base for agents that write, rewrite, and audit prose with measurable AI-pattern checks.",
    install: "Install skills",
    browse: "Browse knowledge",
    open: "Open knowledge base",
    lim: "Read the limitations",
    metrics: ["4 skills", "9 prompts", "12 levers", "41+ notes", "MIT"],
    trim: "trim",
    ok: "ok",
    divider: "Tighten → Sufficiency",
    write_less: "Write less. Trust the reader.",
    from_bench: "From the bench",
    bench_body: "Russian formalist Viktor Shklovsky showed in 1917 that form is what an artist uses to make the familiar strange. Hemingway, Strunk, Williams all built the same lesson from the American side: trust the reader to fill the gaps, delete what is not needed, stop at the turn.",
    quote: "If a writer of prose knows enough of what he is writing about, he may omit things that he knows, and the reader… will have a feeling of those things as strongly as though the writer had stated them.",
    quote_author: "Ernest Hemingway, Death in the Afternoon, 1932",
    pass: "How it works",
    pass_h: "Three passes. Same vocabulary.",
    pass_sub: "Every skill runs the same loop. Count first. Rewrite second. Verify facts last.",
    pass1_h: "Count the tells.",
    pass1_b: "Compute AP, D, E, YapScore, burstiness, specificity, format bias and voice.",
    pass1_k: "13 metrics/pass",
    pass2_h: "Apply the 12 levers.",
    pass2_b: "STRIP, TIGHTEN, RELY, REBUILD. Per-span preserve-facts check (Lamparth 2026).",
    pass2_k: "12 levers",
    pass3_h: "Hold the facts.",
    pass3_b: "Compare facts before and after. If 5–10% of names, dates, numbers, paths disappear, the rewrite is rejected.",
    pass3_k: "≤10% fact loss",
    pass1_s: "Audit",
    pass2_s: "Rewrite",
    pass3_s: "Verify",
    research_k: "Research-grounded",
    research_h: "The rules in the skill are not ours.",
    research_b: "Each lever traces back to a primary source. We collect, translate, version, and ship. We do not invent writing theory.",
    install_h: "One line for the agent. Three files if you copy them yourself.",
    install_b: "Tell your agent the manifest URL, or copy the directories yourself.",
    step: "Step-by-step",
    eyebrow_why: "What the rewrite does",
    eyebrow_ai_tells: "AI tells",
    tells_h: "AI text has tells. People notice.",
    tells_b: "Each LLM uses the same repertoire: em-dashes everywhere, rule-of-three, hedging, negative parallelisms, polite congratulations. Readers spot it. Detectors flag it. The four skills collapse that repertoire back into sentences a person would have a reason to write.",
    em_h: "Em-dash gravity",
    em_strike: "This carefully designed system — built on a foundation of rigorous engineering — delivers value across the stack.",
    em_redo: "p99 14 ms. 99.99% uptime. One binary.",
    em_strike2: "The new release is fast, reliable, and easy — three things that matter.",
    em_redo2: "p99 14 ms. 99.99% uptime. One binary.",
    em_strike3: "Of course, I'd be happy to help with that — let's dive in.",
    em_redo3: "Tail latency spiked to 430 ms. We added Redis.",
    skill_eyebrow: "The four skills",
    skill_h: "An editor, an author, an auditor, and a watchmaker.",
    skill_b: "They cover the common workflow without dragging in a 1,000-line prompt.",
    install_k: "Install",
    install_t: "terminal · install",
    knowledge: "Knowledge",
    limits: "Limits",
    contributing: "Contributing",
    prompt_install: "Step-by-step",
    prompt_manifest: "manifest.json",
    examples_title: "What the rewrite does",
    examples_sub: "Six patterns. One tap each.",
    examples_nav_prev: "Previous",
    examples_nav_next: "Next",
    examples: [
      {
        pattern: "Em-dash gravity",
        tag: "Lever 8",
        before: "This carefully designed system — built on a foundation of rigorous engineering — delivers value across the stack.",
        after: "p99 14 ms. 99.99% uptime. One binary.",
      },
      {
        pattern: "Restatement chain",
        tag: "P-NEW-2",
        before: "API is faster. The optimization reduced response time. Performance has improved significantly across the board.",
        after: "API now responds in 14 ms, down from 380.",
      },
      {
        pattern: "Hedging opener",
        tag: "Lever 3",
        before: "Of course, I'd be happy to help with that — let's dive in.",
        after: "Tail latency spiked to 430 ms. We added Redis.",
      },
      {
        pattern: "Negative parallelism",
        tag: "Lever 1.4",
        before: "This is not just a feature, it's a paradigm shift in how teams collaborate.",
        after: "We moved standups to async. Decisions dropped from 11 to 4 per week.",
      },
      {
        pattern: "Russian brevity",
        tag: "Lever 12",
        before: "Город стоит на реке, обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат.",
        after: "Город стоит на реке. Отсюда — водоснабжение и полив.",
      },
      {
        pattern: "Closing cliché",
        tag: "P-NEW-7",
        before: "Таким образом, мы рассмотрели три подхода. Каждый имеет свои плюсы и минусы. Надеюсь, это поможет вам принять решение.",
        after: "(cut)",
      },
    ],
  },
  ru: {
    kicker: "Скилы для агентского письма · релиз 2026",
    hero_l1: "Скилы, делающие текст",
    hero_l2: "менее похожим на модель.",
    lead: "Четыре скила, 9 pi-промптов и база из 41+ заметок для агентов, которые пишут, редактируют и проверяют прозу по измеримым AI-маркерам.",
    install: "Установить",
    browse: "Открыть базу",
    open: "Открыть базу",
    lim: "Честные ограничения",
    metrics: ["4 скила", "9 промптов", "12 рычагов", "41+ заметка", "MIT"],
    trim: "чистка",
    ok: "готово",
    divider: "Tighten → Sufficiency",
    write_less: "Пиши меньше. Доверяй читателю.",
    from_bench: "Заметка редактора",
    bench_body: "Русский формалист Виктор Шкловский показал в 1917 году, что форма — это то, чем художник возвращает привычному странность. Хемингуэй, Странк, Уильямс провели тот же урок с американской стороны: доверять читателю, удалять лишнее, останавливаться на повороте.",
    quote: "Если пишущий прозу знает достаточно о том, что он пишет, он может опустить то, что знает, и читатель… ощутит это так же отчётливо, как если бы автор это сказал.",
    quote_author: "Эрнест Хемингуэй, «Смерть после полудня», 1932",
    pass: "Как работает",
    pass_h: "Три прохода. Один словарь.",
    pass_sub: "Каждый скил работает в одном цикле. Сначала счёт. Потом rewrite. В конце проверка фактов.",
    pass1_h: "Считаем маркеры.",
    pass1_b: "Считаем AP, D, E, YapScore, burstiness, конкретику, format bias и голос.",
    pass1_k: "13 метрик/проход",
    pass2_h: "Применяем 12 рычагов.",
    pass2_b: "STRIP, TIGHTEN, RELY, REBUILD. Preserved-факты проверка (Lamparth 2026).",
    pass2_k: "12 рычагов",
    pass3_h: "Держим факты.",
    pass3_b: "Сравниваем факты «до» и «после». Если пропало 5–10% имён, дат, чисел, путей — rewrite отклоняется.",
    pass3_k: "≤10% потерь фактов",
    pass1_s: "Аудит",
    pass2_s: "Rewrite",
    pass3_s: "Проверка",
    research_k: "Основано на исследованиях",
    research_h: "Правила в скилах — не наши.",
    research_b: "Каждый рычаг ведёт к первичному источнику. Мы собираем, переводим, версионируем и поставляем. Писательскую теорию мы не выдумываем.",
    install_h: "Одна строка для агента. Три файла, если копировать вручную.",
    install_b: "Скажите агенту прочитать манифест — или скопируйте директории вручную.",
    step: "Шаг за шагом",
    eyebrow_why: "Что делает rewrite",
    eyebrow_ai_tells: "AI-маркеры",
    tells_h: "У AI-текста есть маркеры. Читатель их замечает.",
    tells_b: "Каждая LLM использует один репертуар: em-dashes везде, rule-of-three, hedging, негативные параллелизмы, вежливые поздравления. Читатель видит, детектор флагает. Четыре скила сворачивают этот репертуар обратно в предложения, которые человек писал бы с причиной.",
    em_h: "Гравитация em-dash",
    em_strike: "Данное тщательно спроектированное решение — построенное на фундаменте строгой инженерии — приносит ценность на всём стеке.",
    em_redo: "p99 14 мс. 99.99% аптайм. Один бинарь.",
    em_strike2: "Новый релиз быстрый, надёжный и удобный — три вещи, которые важны.",
    em_redo2: "p99 14 мс. 99.99% аптайм. Один бинарь.",
    em_strike3: "Конечно, я с радостью помогу с этим — давайте разберёмся.",
    em_redo3: "Хвостовая задержка ушла в 430 мс. Поставили Redis.",
    skill_eyebrow: "Четыре скила",
    skill_h: "Редактор, автор, аудитор и часовщик.",
    skill_b: "Покрывают обычный workflow без тяжёлого 1000-строчного промпта.",
    install_k: "Установка",
    install_t: "терминал · установка",
    knowledge: "База",
    limits: "Ограничения",
    contributing: "Contributing",
    prompt_install: "Шаг за шагом",
    prompt_manifest: "manifest.json",
    examples_title: "Что делает rewrite",
    examples_sub: "Шесть паттернов. По тапу.",
    examples_nav_prev: "Назад",
    examples_nav_next: "Вперёд",
    examples: [
      {
        pattern: "Гравитация em-dash",
        tag: "Рычаг 8",
        before: "Данное тщательно спроектированное решение — построенное на фундаменте строгой инженерии — приносит ценность на всём стеке.",
        after: "p99 14 мс. 99.99% аптайм. Один бинарь.",
      },
      {
        pattern: "Цепочка restatement",
        tag: "P-NEW-2",
        before: "API стал работать быстрее. Оптимизация позволила сократить время отклика. Производительность улучшилась значительно по всем направлениям.",
        after: "API теперь отвечает за 14 мс, было 380.",
      },
      {
        pattern: "Hedging opener",
        tag: "Рычаг 3",
        before: "Конечно, я с радостью помогу с этим — давайте разберёмся.",
        after: "Хвостовая задержка ушла в 430 мс. Поставили Redis.",
      },
      {
        pattern: "Негативный параллелизм",
        tag: "Рычаг 1.4",
        before: "Это не просто функция, это смена парадигмы в том, как команды взаимодействуют.",
        after: "Перевели стендапы в async. Решений стало 4 в неделю вместо 11.",
      },
      {
        pattern: "Русская краткость",
        tag: "Рычаг 12",
        before: "Город стоит на реке, обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат.",
        after: "Город стоит на реке. Отсюда — водоснабжение и полив.",
      },
      {
        pattern: "Закрывающий клише",
        tag: "P-NEW-7",
        before: "Таким образом, мы рассмотрели три подхода. Каждый имеет свои плюсы и минусы. Надеюсь, это поможет вам принять решение.",
        after: "(удалено)",
      },
    ],
  },
} as const

const SKILLS = [
  {
    icon: "write",
    en: {
      name: "humanize-writer",
      tag: "writer · Levers 1–12",
      body: "Drafts README, email, post. Counts em-dashes, hedges, restatements before the user sees them.",
    },
    ru: {
      name: "humanize-writer",
      tag: "writer · 12 рычагов",
      body: "Пишет README, письма, посты. Считает em-dash, hedging и restatement до того, как пользователь их увидит.",
    },
  },
  {
    icon: "edit",
    en: {
      name: "humanize-editor",
      tag: "rewriter · Tighten + Iceberg",
      body: "Rewrites an AI draft. Holds on to every name, number, date, claim — even after cutting length.",
    },
    ru: {
      name: "humanize-editor",
      tag: "rewriter · Tighten + Iceberg",
      body: "Переписывает AI-черновик. Сохраняет имена, числа, даты и claims — даже после сокращения длины.",
    },
  },
  {
    icon: "loupe",
    en: {
      name: "anti-ai-auditor",
      tag: "diagnostic · no rewrite",
      body: "Structured report: per-pattern hit list, density metrics, concrete priorities. Does not modify the text.",
    },
    ru: {
      name: "anti-ai-auditor",
      tag: "диагностика · без rewrite",
      body: "Структурированный отчёт: попадания паттернов, метрики плотности, приоритеты правок. Сам текст не меняет.",
    },
  },
  {
    icon: "pincers",
    en: {
      name: "ai-pattern-rewriter",
      tag: "surgical · single span",
      body: "Touches one flagged phrase at a time. Keeps everything else verbatim. Useful when the rest is fine.",
    },
    ru: {
      name: "ai-pattern-rewriter",
      tag: "хирургия · один span",
      body: "Меняет одну отмеченную фразу. Остальное не трогает. Подходит, когда остальной текст уже хорош.",
    },
  },
] as const

const SOURCES = [
  { year: 2026, en: ["YapBench", "76 LLMs over-generate 1–3×"], ru: ["YapBench", "76 LLM генерируют в 1–3× длиннее"] },
  { year: 2026, en: ["Lamparth", "single-axis mitigation → bias swap"], ru: ["Лампарт", "одностороннее смягчение → bias-swap"] },
  { year: 2026, en: ["MASH (ACL)", "static rewrite, 92% ASR ceiling"], ru: ["MASH (ACL)", "статика, ceiling 92% ASR"] },
  { year: 2024, en: ["Binoculars", "zero-shot baseline detector"], ru: ["Binoculars", "zero-shot baseline"] },
  { year: 2024, en: ["Zhang", "format bias from 1% seed"], ru: ["Чжан", "format bias от 1%"] },
  { year: 1917, en: ["Shklovsky", "defamiliarization through form"], ru: ["Шкловский", "остранение через форму"] },
  { year: 1970, en: ["Lotman", "form carries information"], ru: ["Лотман", "форма несёт смысл"] },
  { year: 1984, en: ["Gasparov", "measure rhythm, not mood"], ru: ["Гаспаров", "измерять ритм, не нрав"] },
] as const

const ROOT_EN = "https://11111000000.github.io/agents-writing-skills"
const ROOT_RU = "https://11111000000.github.io/agents-writing-skills/ru"

const PencilIcon = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
    <path d="M5 19l4-1 9-9a2.5 2.5 0 0 0-3.5-3.5l-9 9z"></path>
    <path d="M14 6l3 3"></path>
  </svg>
)
const ScissorsIcon = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
    <path d="M6 4l12 12"></path>
    <path d="M8 2v2"></path>
    <path d="M16 20v2"></path>
    <circle cx="7" cy="7" r="2"></circle>
    <circle cx="17" cy="17" r="2"></circle>
  </svg>
)
const LoupeIcon = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="11" cy="11" r="6"></circle>
    <path d="M15 15l4 4"></path>
  </svg>
)
const PincersIcon = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
    <path d="M6 6l4 12 2-6 2 6 4-12"></path>
    <path d="M3 21h18"></path>
  </svg>
)
const DASH = (text: number) => <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12h18"></path><circle cx="12" cy="12" r={`${text}`}></circle></svg>
const CHART = () => <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 18l6-6 4 4 6-10"></path></svg>
const SWIRL = () => <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12c4 4 12 4 16 0"></path><path d="M4 12c4-4 12-4 16 0"></path></svg>

function style(): JSX.Element {
  return (
    <style>
      {`:root{--ink:#1a140c;--ink-2:#2c2418;--paper:#fbf7ed;--paper-2:#f0e9d6;--paper-3:#e7dec5;--muted:#6b5c47;--line:rgba(26,20,12,.16);--accent:#8b3a1f;--accent-2:#3d5a40;--dark:#14110d;--dark-2:#1f1a14;--code:#0f0c09}
.aws-landing{color:var(--ink);font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif;background:linear-gradient(180deg,#fdfaef 0%,var(--paper) 38%,var(--paper-2) 100%);margin:0 auto 4rem;max-width:1180px;padding:0 clamp(1rem,3vw,1.5rem) 4rem}
.aws-landing h1,.aws-landing h2,.aws-landing h3{font-family:Newsreader,IBM Plex Serif,Georgia,serif;letter-spacing:-.02em;margin:0}
.aws-shell{background:rgba(255,248,239,.72);border:1px solid var(--line);border-radius:28px;overflow:hidden;position:relative;box-shadow:0 32px 80px -36px rgba(26,20,12,.32)}
.aws-progress{background:linear-gradient(90deg,var(--accent),var(--accent-2));height:2px;position:absolute;top:0;transform-origin:left;transform:scaleX(var(--aws-scroll,0));transition:transform .1s linear;width:100%;z-index:5}
.aws-topbar{align-items:center;border-bottom:1px solid var(--line);display:flex;gap:1rem;justify-content:space-between;padding:1rem clamp(1rem,4vw,3rem);position:sticky;top:0;z-index:4;backdrop-filter:saturate(140%) blur(6px);background:rgba(255,248,239,.82)}
.aws-topbar.scrolled{padding-block:.55rem}
.aws-brand-link{align-items:center;display:flex;gap:.7rem;text-decoration:none;color:inherit}
.aws-mark{align-items:center;background:var(--ink);border-radius:14px;color:var(--paper);display:flex;height:2.5rem;justify-content:center;transition:transform .25s ease;width:2.5rem}
.aws-mark svg{height:1.4rem;width:1.4rem}
.aws-mark-name{font-size:1.05rem;font-weight:800;letter-spacing:-.04em}
.aws-nav{align-items:center;display:flex;gap:.5rem}
.aws-nav a{border-radius:999px;color:var(--muted);font-size:.92rem;font-weight:600;padding:.5rem .9rem;text-decoration:none;transition:color .18s,background .18s}
.aws-nav a:hover{color:var(--ink);background:rgba(255,255,255,.45)}
.aws-lang{align-items:center;background:rgba(255,255,255,.6);border:1px solid var(--line);border-radius:999px;display:flex;margin-left:.4rem;padding:.22rem}
.aws-lang a{border-radius:999px;color:var(--ink);font-size:.84rem;font-weight:700;letter-spacing:.03em;padding:.45rem .85rem;text-decoration:none}
.aws-lang a.is-active{background:var(--ink);color:var(--paper)}
.aws-hero{display:grid;gap:clamp(1.5rem,4vw,4rem);grid-template-columns:minmax(0,1.05fr) minmax(0,.95fr);padding:clamp(2.5rem,6vw,5rem) clamp(1.5rem,4vw,3rem) clamp(2rem,4vw,3rem)}
.aws-kicker{color:var(--accent);font-size:.78rem;font-weight:800;letter-spacing:.18em;margin-bottom:1.5rem;text-transform:uppercase}
.aws-hero h1{color:var(--ink);font-size:clamp(2.6rem,7vw,5.6rem);font-weight:500;letter-spacing:-.06em;line-height:.95}
.aws-hero h1 span.aws-pen{background:linear-gradient(135deg,var(--accent),#c85a35);color:transparent;display:inline-block;font-style:italic;font-weight:600;letter-spacing:-.07em;-webkit-background-clip:text;background-clip:text}
.aws-lead{color:var(--ink-2);font-size:clamp(1.05rem,1.7vw,1.3rem);line-height:1.55;margin:1.6rem 0 0;max-width:38rem}
.aws-actions{display:flex;flex-wrap:wrap;gap:.7rem;margin:1.8rem 0 0}
.aws-button{align-items:center;border-radius:999px;display:inline-flex;font-weight:700;gap:.55rem;min-height:2.95rem;padding:0 1.3rem;text-decoration:none;transition:transform .2s,box-shadow .2s,background .2s}
.aws-button-primary{background:var(--ink);box-shadow:0 12px 24px -10px rgba(26,20,12,.5);color:var(--paper)}
.aws-button-primary:hover{box-shadow:0 20px 28px -10px rgba(26,20,12,.55);transform:translateY(-2px)}
.aws-button-secondary{background:transparent;border:1px solid var(--line);color:var(--ink)}
.aws-button-secondary:hover{background:rgba(255,255,255,.5)}
.aws-meta-strip{align-items:center;border-top:1px dashed var(--line);color:var(--muted);display:flex;flex-wrap:wrap;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.82rem;gap:.6rem 1.4rem;margin:2.5rem 0 0;padding-top:1.4rem}
.aws-meta-strip b{color:var(--ink);font-weight:700}
.aws-compare{align-items:stretch;background:rgba(255,255,255,.55);border:1px solid var(--line);border-radius:22px;display:grid;gap:.6rem;padding:1.1rem 1.2rem 1.3rem;position:relative}
.aws-compare h3{font-family:JetBrains Mono,ui-monospace,monospace;font-size:.78rem;font-weight:800;letter-spacing:.16em;margin:0 0 .35rem;text-transform:uppercase}
.aws-compare h3.before{color:var(--accent)}
.aws-compare h3.after{color:var(--accent-2)}
.aws-compare .ai-text{font-family:Newsreader,serif;font-size:1.05rem;line-height:1.42;margin:0}
.aws-compare .before-card .ai-text{color:#7a6750;text-decoration:line-through;text-decoration-color:rgba(139,58,31,.5);text-decoration-thickness:1.5px}
.aws-compare .before-card{position:relative}
.aws-compare .ai-trim{color:var(--accent);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.72rem;font-weight:800;letter-spacing:.14em;position:absolute;right:.9rem;text-transform:uppercase;top:1rem;transform:rotate(-6deg)}
.aws-compare .after-card{background:var(--paper);border:1px solid rgba(61,90,64,.18);border-radius:16px;padding:.9rem 1rem;position:relative}
.aws-compare .ai-check{color:var(--accent-2);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.72rem;font-weight:800;letter-spacing:.14em;position:absolute;right:.9rem;text-transform:uppercase;top:.8rem}
.aws-compare-divider{align-items:center;align-self:center;color:var(--muted);display:flex;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.74rem;gap:.7rem;justify-content:flex-start;letter-spacing:.18em;text-transform:uppercase}
.aws-compare-divider::after,.aws-compare-divider::before{background:var(--line);content:"";flex:1;height:1px}
.aws-section{border-top:1px solid var(--line);padding:clamp(2.5rem,5vw,4.2rem) clamp(1.5rem,4vw,3rem)}
.aws-section h2{font-size:clamp(1.7rem,3.5vw,2.6rem);letter-spacing:-.05em;margin:0 0 .8rem;max-width:16ch}
.aws-section p{color:var(--ink-2);font-size:1.05rem;line-height:1.65;margin:0;max-width:56ch}
.aws-eyebrow{color:var(--accent);display:block;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.72rem;font-weight:800;letter-spacing:.18em;margin-bottom:.7rem;text-transform:uppercase}
.aws-section.dark{background:var(--ink);border-top-color:var(--ink);color:var(--paper)}
.aws-section.dark p{color:rgba(251,247,237,.78)}
.aws-section.dark .aws-eyebrow{color:#d7b28b}
.aws-why{display:grid;gap:clamp(1.5rem,4vw,3rem);grid-template-columns:minmax(0,1.05fr) minmax(0,.95fr);margin-top:2.2rem}
.aws-tells{display:grid;gap:1rem}
.aws-tell{background:rgba(255,255,255,.55);border:1px solid var(--line);border-radius:16px;padding:1rem 1.1rem}
.aws-tell h4{align-items:center;display:flex;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.78rem;font-weight:800;gap:.5rem;letter-spacing:.14em;margin:0 0 .4rem;text-transform:uppercase}
.aws-tell h4 svg{flex-shrink:0;height:1.1rem;stroke:var(--accent);width:1.1rem}
.aws-tell p{font-family:Newsreader,serif;font-size:.98rem;line-height:1.45;margin:0}
.aws-tell .aws-strike{color:#7a6750;text-decoration:line-through;text-decoration-color:rgba(139,58,31,.5);text-decoration-thickness:1.5px}
.aws-tell .aws-redo{color:var(--accent-2);display:block;font-style:italic;margin-top:.35rem}
.aws-quote-card{background:var(--paper);border:1px solid var(--line);border-radius:20px;padding:1.7rem 1.8rem;position:relative}
.aws-quote-card::before{color:var(--accent);content:"“";font-family:Newsreader,serif;font-size:5rem;left:.7rem;line-height:.6;position:absolute;top:1.4rem}
.aws-quote-card blockquote{font-family:Newsreader,serif;font-size:1.35rem;font-style:italic;line-height:1.45;margin:0;padding-left:1.6rem}
.aws-quote-card cite{display:block;font-size:.92rem;font-style:normal;margin-top:1.1rem;padding-left:1.6rem}
.aws-quote-card cite::before{content:"— "}
.aws-grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));margin-top:2rem}
.aws-card{background:rgba(255,255,255,.62);border:1px solid var(--line);border-radius:20px;color:var(--ink);padding:1.4rem;position:relative;text-decoration:none;transition:box-shadow .25s,transform .25s}
.aws-card:hover{box-shadow:0 24px 40px -22px rgba(26,20,12,.32);transform:translateY(-4px)}
.aws-card-icon{align-items:center;background:rgba(255,255,255,.7);border:1px solid var(--line);border-radius:14px;color:var(--ink);display:inline-flex;height:3rem;justify-content:center;margin-bottom:.9rem;width:3rem}
.aws-card-icon svg{height:1.6rem;width:1.6rem}
.aws-card h3{font-size:1.15rem;margin:0}
.aws-card .aws-tag{color:var(--muted);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.7rem;letter-spacing:.1em;margin:.4rem 0 .7rem;text-transform:uppercase}
.aws-pass{display:grid;gap:1rem;grid-template-columns:repeat(3,minmax(0,1fr));margin-top:2.2rem;position:relative}
.aws-pass::before{border-top:1.5px dashed var(--line);content:"";left:6%;position:absolute;right:6%;top:1.6rem;z-index:0}
.aws-pass-step{background:var(--paper);border:1px solid var(--line);border-radius:22px;padding:1.6rem 1.5rem 1.7rem;position:relative;z-index:1}
.aws-pass-num{align-items:center;background:var(--ink);border-radius:999px;color:var(--paper);display:inline-flex;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.78rem;font-weight:800;height:2.4rem;justify-content:center;letter-spacing:.1em;margin-bottom:1rem;width:2.4rem}
.aws-pass-step h3{font-size:1.45rem;margin:0 0 .5rem}
.aws-pass-step .aws-sub{color:var(--accent);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.72rem;font-weight:800;letter-spacing:.14em;margin-bottom:.6rem;text-transform:uppercase}
.aws-pass-step p{font-size:.96rem;line-height:1.55}
.aws-pass-step .aws-metric{align-items:baseline;display:flex;font-family:JetBrains Mono,ui-monospace,monospace;gap:.4rem;margin-top:1rem}
.aws-pass-step .aws-metric strong{color:var(--accent);font-size:1.4rem;font-weight:800}
.aws-pass-step .aws-metric span{color:var(--muted);font-size:.78rem}
.aws-research{display:grid;gap:.55rem;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));margin-top:2rem}
.aws-source{align-items:center;background:rgba(255,255,255,.55);border:1px solid var(--line);border-radius:14px;display:flex;gap:.7rem;padding:.75rem .9rem;transition:transform .2s}
.aws-source:hover{transform:translateY(-2px)}
.aws-source span.year{color:var(--accent);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.78rem;font-weight:800;letter-spacing:.1em;min-width:3rem}
.aws-source small{color:var(--ink-2);font-size:.88rem;line-height:1.2}
.aws-source small b{display:block;font-weight:700}
.aws-source small span{color:var(--muted);font-size:.78rem}
.aws-install{background:var(--code);border-radius:22px;color:#e7d9c0;font-family:JetBrains Mono,ui-monospace,monospace;font-size:.92rem;line-height:1.7;margin-top:2rem;overflow:hidden}
.aws-install-head{align-items:center;border-bottom:1px solid rgba(255,255,255,.1);color:#c2af94;display:flex;font-size:.78rem;gap:.5rem;padding:.95rem 1.2rem}
.aws-install-head .aws-dot{border-radius:999px;height:.7rem;width:.7rem}
.aws-install-head .aws-dot.a{background:#c96b4f}
.aws-install-head .aws-dot.b{background:#c7a652}
.aws-install-head .aws-dot.c{background:#6da071}
.aws-install-body{padding:1.3rem 1.4rem 1.5rem}
.aws-install-body .aws-line{display:block}
.aws-install-body .aws-c{color:#6da071}
.aws-install-body .aws-p{color:#d7b28b}
.aws-cta-row{align-items:center;display:flex;flex-wrap:wrap;gap:.8rem;margin-top:1.4rem}
.aws-button-on-dark{background:var(--paper);color:var(--ink)}
.aws-button-on-dark:hover{background:#fff;transform:translateY(-2px)}
.aws-footer{align-items:center;border-top:1px solid rgba(255,255,255,.1);display:flex;flex-wrap:wrap;gap:.6rem 1.4rem;justify-content:space-between;padding:1.5rem clamp(1.5rem,4vw,3rem) 1.7rem}
.aws-footer small{color:rgba(251,247,237,.7);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.78rem}
.aws-footer a{color:var(--paper);font-weight:700}
.aws-reveal{opacity:0;transform:translateY(28px);transition:opacity .6s ease,transform .7s cubic-bezier(.2,.8,.2,1)}
.aws-reveal.is-in{opacity:1;transform:translateY(0)}
.aws-slider{padding:0;overflow:hidden}
.aws-slider-head{align-items:flex-start;display:flex;gap:.8rem;justify-content:space-between;margin-bottom:1rem}
.aws-slider-sub{color:var(--muted);font-size:.88rem;margin:.25rem 0 0;max-width:none}
.aws-slider-nav{align-items:center;display:flex;flex-shrink:0;gap:.35rem}
.aws-slider-btn{align-items:center;background:rgba(255,255,255,.65);border:1px solid var(--line);border-radius:999px;color:var(--ink);cursor:pointer;display:inline-flex;height:2.4rem;justify-content:center;transition:background .18s,transform .18s;width:2.4rem}
.aws-slider-btn:hover{background:#fff;transform:translateY(-1px)}
.aws-slider-btn:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
.aws-slider-btn svg{height:1.1rem;width:1.1rem}
.aws-slider-viewport{margin:0 -.2rem;overflow:hidden;padding:0 .2rem}
.aws-slider-track{display:flex;list-style:none;margin:0;padding:0;transition:transform .5s cubic-bezier(.2,.8,.2,1);will-change:transform}
.aws-slider-slide{flex:0 0 100%;min-width:0}
.aws-slide-meta{align-items:center;display:flex;gap:.6rem;margin-bottom:.8rem}
.aws-slide-pattern{color:var(--ink);font-family:Newsreader,serif;font-size:1.1rem;font-weight:600;letter-spacing:-.02em}
.aws-slide-tag{background:rgba(139,58,31,.12);border-radius:999px;color:var(--accent);font-family:JetBrains Mono,ui-monospace,monospace;font-size:.66rem;font-weight:800;letter-spacing:.1em;padding:.25rem .6rem;text-transform:uppercase}
.aws-slide-panes{display:grid;gap:.6rem}
.aws-pane{position:relative}
.aws-pane.before-card{background:rgba(255,255,255,.55);border:1px solid var(--line);border-radius:18px;padding:1rem 1.1rem 1.2rem}
.aws-pane.after-card{background:var(--paper);border:1px solid rgba(61,90,64,.18);border-radius:18px;padding:1rem 1.1rem 1.2rem;position:relative}
.aws-pane .ai-text{font-family:Newsreader,serif;font-size:1.02rem;line-height:1.42;margin:0}
.aws-pane.before-card .ai-text{color:#7a6750;text-decoration:line-through;text-decoration-color:rgba(139,58,31,.5);text-decoration-thickness:1.5px}
.aws-pane .ai-trim,.aws-pane .ai-check{font-family:JetBrains Mono,ui-monospace,monospace;font-size:.68rem;font-weight:800;letter-spacing:.14em;position:absolute;text-transform:uppercase}
.aws-pane .ai-trim{color:var(--accent);right:.9rem;top:.9rem;transform:rotate(-6deg)}
.aws-pane .ai-check{color:var(--accent-2);right:.9rem;top:.8rem}
.aws-slider-dots{align-items:center;display:flex;gap:.45rem;justify-content:center;margin-top:1.1rem}
.aws-slider-dot{background:rgba(26,20,12,.18);border:0;border-radius:999px;cursor:pointer;height:.45rem;padding:0;transition:background .2s,width .25s;width:.45rem}
.aws-slider-dot:hover{background:rgba(26,20,12,.32)}
.aws-slider-dot:focus-visible{outline:2px solid var(--accent);outline-offset:3px}
.aws-slider-dot.is-active{background:var(--accent);width:1.4rem}
@media (prefers-reduced-motion: reduce){.aws-reveal{opacity:1;transform:none;transition:none}.aws-button,.aws-card,.aws-source{transition:none !important}.aws-slider-track{transition:none}}
@media (max-width:880px){.aws-hero,.aws-why,.aws-pass{grid-template-columns:1fr}.aws-pass::before{display:none}.aws-topbar{flex-wrap:wrap}.aws-nav{flex-wrap:wrap;width:100%}}
@media (max-width:560px){.aws-meta-strip{font-size:.74rem}.aws-quote-card blockquote{font-size:1.15rem}.aws-slide-pattern{font-size:1rem}.aws-slider-head{flex-wrap:wrap;gap:.5rem}}`}
    </style>
  )
}

function landing(lang: "en" | "ru") {
  const s = STRINGS[lang]
  const root = lang === "en" ? ROOT_EN : ROOT_RU
  const heroL2Class = lang === "en" ? "aws-pen" : "aws-pen"

  return (
    <div class="aws-landing">
      <div class="aws-shell">
        <div class="aws-progress"></div>
        <header class="aws-topbar" id="aws-topbar">
          <a class="aws-brand-link" href={root + "/"} aria-label="agents-writing-skills home">
            <span class="aws-mark" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 19.5L7.5 16.5C5 14 5 11 7.5 8.5C11 5 16 5 19.5 8.5C22 11 22 14 19.5 16.5L16.5 19.5"></path>
                <path d="M14.2 9.8L9.8 14.2"></path>
              </svg>
            </span>
            <span class="aws-mark-name">agents-writing-skills</span>
          </a>
          <nav class="aws-nav" aria-label="primary">
            <a href={root + "/skills-overview"}>Skills</a>
            <a href={root + "/knowledge-base"}>Knowledge</a>
            <a href={root + "/getting-started"}>Install</a>
            <a href="https://github.com/11111000000/agents-writing-skills">GitHub</a>
            <span class="aws-lang" role="navigation" aria-label="language">
              <a class={"aws-lang en" + (lang === "en" ? " is-active" : "")} href={ROOT_EN} aria-label="English version">EN</a>
              <a class={"aws-lang ru" + (lang === "ru" ? " is-active" : "")} href={ROOT_RU} aria-label="Русская версия">RU</a>
            </span>
          </nav>
        </header>

        <section class="aws-hero aws-reveal">
          <div>
            <div class="aws-kicker">{s.kicker}</div>
            <h1>
              {s.hero_l1} <span class={heroL2Class}>{s.hero_l2}</span>
            </h1>
            <p class="aws-lead">{s.lead}</p>
            <div class="aws-actions">
              <a class="aws-button aws-button-primary" href={root + "/getting-started"}>
                {s.install}
              </a>
              <a class="aws-button aws-button-secondary" href={root + "/knowledge-base"}>
                {s.browse}
              </a>
            </div>
            <div class="aws-meta-strip">
              {s.metrics.map((m) => (
                <span>
                  <b>{m.split(" ")[0]}</b> {m.split(" ").slice(1).join(" ")}
                </span>
              ))}
            </div>
          </div>
          <div class="aws-compare aws-slider" aria-roledescription="carousel" aria-label={lang === "en" ? "Before and after examples" : "Примеры до и после"}>
            <div class="aws-slider-head">
              <div>
                <span class="aws-eyebrow">{s.examples_title}</span>
                <p class="aws-slider-sub">{s.examples_sub}</p>
              </div>
              <div class="aws-slider-nav" role="group" aria-label={lang === "en" ? "Slide navigation" : "Навигация по слайдам"}>
                <button class="aws-slider-btn" data-dir="-1" aria-label={s.examples_nav_prev} type="button">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 6l-6 6 6 6"></path></svg>
                </button>
                <button class="aws-slider-btn" data-dir="1" aria-label={s.examples_nav_next} type="button">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6l6 6-6 6"></path></svg>
                </button>
              </div>
            </div>
            <div class="aws-slider-viewport">
              <ul class="aws-slider-track" data-index="0">
                {s.examples.map((ex, i) => (
                  <li class="aws-slider-slide" data-slide={i} aria-roledescription="slide" aria-label={`${i + 1} / ${s.examples.length}`}>
                    <div class="aws-slide-meta">
                      <span class="aws-slide-pattern">{ex.pattern}</span>
                      <span class="aws-slide-tag">{ex.tag}</span>
                    </div>
                    <div class="aws-slide-panes">
                      <div class="aws-pane before-card">
                        <span class="ai-trim">{s.trim}</span>
                        <h3 class="before">{lang === "en" ? "Before" : "До"}</h3>
                        <p class="ai-text">{ex.before}</p>
                      </div>
                      <div class="aws-compare-divider">{s.divider}</div>
                      <div class="aws-pane after-card">
                        <span class="ai-check">{s.ok}</span>
                        <h3 class="after">{lang === "en" ? "After" : "После"}</h3>
                        <p class="ai-text">{ex.after}</p>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
            <div class="aws-slider-dots" role="tablist" aria-label={lang === "en" ? "Slide selector" : "Выбор слайда"}>
              {s.examples.map((ex, i) => (
                <button class={"aws-slider-dot" + (i === 0 ? " is-active" : "")} data-dot={i} role="tab" aria-selected={i === 0 ? "true" : "false"} aria-label={`${ex.pattern}`} type="button"></button>
              ))}
            </div>
          </div>
        </section>

        <section class="aws-section aws-reveal">
          <div class="aws-why">
            <div>
              <span class="aws-eyebrow">{s.eyebrow_ai_tells}</span>
              <h2>{s.tells_h}</h2>
              <p>{s.tells_b}</p>
            </div>
            <div class="aws-tells">
              <article class="aws-tell">
                <h4>
                  <span style="width:1.1rem;height:1.1rem;display:inline-flex;align-items:center;justify-content:center">{DASH(3.5)}</span>
                  {s.em_h}
                </h4>
                <p>
                  <span class="aws-strike">{s.em_strike}</span>
                </p>
                <p class="aws-redo">{s.em_redo}</p>
              </article>
              <article class="aws-tell">
                <h4>
                  <span style="width:1.1rem;height:1.1rem;display:inline-flex;align-items:center;justify-content:center">{CHART()}</span>
                  {lang === "en" ? "Restatement chain" : "Цепочки restatement"}
                </h4>
                <p>
                  <span class="aws-strike">{s.em_strike2}</span>
                </p>
                <p class="aws-redo">{s.em_redo2}</p>
              </article>
              <article class="aws-tell">
                <h4>
                  <span style="width:1.1rem;height:1.1rem;display:inline-flex;align-items:center;justify-content:center">{SWIRL()}</span>
                  {lang === "en" ? "Polite hedging" : "Вежливое hedging"}
                </h4>
                <p>
                  <span class="aws-strike">{s.em_strike3}</span>
                </p>
                <p class="aws-redo">{s.em_redo3}</p>
              </article>
            </div>
          </div>
        </section>

        <section class="aws-section aws-reveal">
          <div style="display:grid;gap:clamp(1.5rem,4vw,3rem);grid-template-columns:1.1fr 0.9fr;align-items:start">
            <div>
              <span class="aws-eyebrow">{s.from_bench}</span>
              <h2>{s.write_less}</h2>
              <p>{s.bench_body}</p>
            </div>
            <blockquote class="aws-quote-card">
              <p style="padding-left:1.6rem">{s.quote}</p>
              <cite style="display:block;font-size:.92rem;margin-top:1.1rem;padding-left:1.6rem;font-style:normal">{s.quote_author}</cite>
            </blockquote>
          </div>
        </section>

        <section class="aws-section aws-reveal">
          <div>
            <span class="aws-eyebrow">{s.skill_eyebrow}</span>
            <h2>{s.skill_h}</h2>
            <p>{s.skill_b}</p>
          </div>
          <div class="aws-grid">
            {SKILLS.map((k, i) => (
              <a class="aws-card" href={root + "/skills-overview#" + k.en.name} key={k.en.name}>
                <span class="aws-card-icon" aria-hidden="true">
                  {k.icon === "write" ? PencilIcon : k.icon === "edit" ? ScissorsIcon : k.icon === "loupe" ? LoupeIcon : PincersIcon}
                </span>
                <h3>{k[lang].name}</h3>
                <div class="aws-tag">{k[lang].tag}</div>
                <p>{k[lang].body}</p>
              </a>
            ))}
          </div>
        </section>

        <section class="aws-section aws-reveal">
          <div>
            <span class="aws-eyebrow">{s.pass}</span>
            <h2>{s.pass_h}</h2>
            <p>{s.pass_sub}</p>
          </div>
          <div class="aws-pass">
            <article class="aws-pass-step">
              <span class="aws-pass-num">P1</span>
              <div class="aws-sub">{s.pass1_s}</div>
              <h3>{s.pass1_h}</h3>
              <p>{s.pass1_b}</p>
              <div class="aws-metric">
                <strong>13</strong>
                <span>{s.pass1_k}</span>
              </div>
            </article>
            <article class="aws-pass-step">
              <span class="aws-pass-num">P2</span>
              <div class="aws-sub">{s.pass2_s}</div>
              <h3>{s.pass2_h}</h3>
              <p>{s.pass2_b}</p>
              <div class="aws-metric">
                <strong>12</strong>
                <span>{s.pass2_k}</span>
              </div>
            </article>
            <article class="aws-pass-step">
              <span class="aws-pass-num">P3</span>
              <div class="aws-sub">{s.pass3_s}</div>
              <h3>{s.pass3_h}</h3>
              <p>{s.pass3_b}</p>
              <div class="aws-metric">
                <strong>≤10%</strong>
                <span>{s.pass3_k}</span>
              </div>
            </article>
          </div>
        </section>

        <section class="aws-section aws-section-dark aws-reveal">
          <div>
            <span class="aws-eyebrow">{s.research_k}</span>
            <h2>{s.research_h}</h2>
            <p>{s.research_b}</p>
          </div>
          <div class="aws-research">
            {SOURCES.map((so, i) => (
              <div class="aws-source" key={i}>
                <span class="year">{so.year}</span>
                <small>
                  <b>{lang === "en" ? so.en[0] : so.ru[0]}</b>
                  <span>{lang === "en" ? so.en[1] : so.ru[1]}</span>
                </small>
              </div>
            ))}
          </div>
          <div class="aws-cta-row">
            <a class="aws-button aws-button-on-dark" href={root + "/knowledge-base"}>
              {s.open} →
            </a>
            <a class="aws-button aws-button-on-dark" href={root + "/limitations"}>
              {s.lim} →
            </a>
          </div>
        </section>

        <section class="aws-section aws-reveal">
          <div>
            <span class="aws-eyebrow">{s.install_k}</span>
            <h2>{s.install_h}</h2>
            <p>{s.install_b}</p>
          </div>
          <div class="aws-install">
            <div class="aws-install-head">
              <span class="aws-dot a"></span>
              <span class="aws-dot b"></span>
              <span class="aws-dot c"></span>
              <span>{s.install_t}</span>
            </div>
            <div class="aws-install-body">
              <span class="aws-line">
                <span class="aws-c">$</span> <span class="aws-p">clone</span>
              </span>
              <span class="aws-line">&nbsp;&nbsp;git clone https://github.com/11111000000/agents-writing-skills.git</span>
              <span class="aws-line">
                <span class="aws-c">$</span> <span class="aws-p">cd</span>
              </span>
              <span class="aws-line">&nbsp;&nbsp;cd agents-writing-skills</span>
              <span class="aws-line">
                <span class="aws-c">$</span> <span class="aws-p">copy</span>
              </span>
              <span class="aws-line">&nbsp;&nbsp;cp -r skills/humanize-writer       ~/.config/opencode/skills/</span>
              <span class="aws-line">&nbsp;&nbsp;cp -r skills/humanize-editor       ~/.config/opencode/skills/</span>
              <span class="aws-line">&nbsp;&nbsp;cp -r skills/anti-ai-auditor      ~/.config/opencode/skills/</span>
              <span class="aws-line">&nbsp;&nbsp;cp -r skills/ai-pattern-rewriter  ~/.config/opencode/skills/</span>
              <span class="aws-line">
                <span class="aws-c">$</span> <span class="aws-p">prompts</span>
              </span>
              <span class="aws-line">&nbsp;&nbsp;cp prompts/*.md ~/.pi/agent/prompts/</span>
            </div>
          </div>
          <div class="aws-cta-row">
            <a class="aws-button aws-button-primary" href={root + "/getting-started"}>
              {s.prompt_install}
            </a>
            <a class="aws-button aws-button-secondary" href="https://github.com/11111000000/agents-writing-skills/blob/main/manifest.json">
              {s.prompt_manifest}
            </a>
          </div>
        </section>

        <footer class="aws-footer">
          <small>agents-writing-skills v1.5 · MIT for code · CC-BY-SA-4.0 for notes</small>
          <small>
            <a href="https://github.com/11111000000/agents-writing-skills">GitHub</a> ·
            <a href={root + "/knowledge-base"}>{s.knowledge}</a> ·
            <a href={root + "/limitations"}>{s.limits}</a> ·
            <a href={root + "/contributing"}>{s.contributing}</a>
          </small>
        </footer>
      </div>
    </div>
  )
}

const afterDOMLoaded = `(() => {
  if(!document.querySelector) return;
  var root=document.querySelector(".aws-landing");
  if(!root) return;
  var progress=root.querySelector(".aws-progress");
  var shell=root.querySelector(".aws-shell");
  var topbar=root.querySelector(".aws-topbar");
  function tick(){
    if(!progress||!shell) return;
    var rect=shell.getBoundingClientRect();
    var total=shell.scrollHeight-window.innerHeight;
    var scrolled=Math.min(Math.max(-rect.top,0),total);
    var ratio=total>0?scrolled/total:0;
    shell.style.setProperty("--aws-scroll",ratio.toFixed(4));
    if(topbar){
      if(rect.top<-10) topbar.classList.add("scrolled");
      else topbar.classList.remove("scrolled");
    }
  }
  function raf(){if("requestAnimationFrame" in window) requestAnimationFrame(tick); else tick();}
  window.addEventListener("scroll",raf);
  window.addEventListener("resize",tick);
  tick();
  if("IntersectionObserver" in window){
    var io=new IntersectionObserver(function(es){
      es.forEach(function(e){if(e.isIntersecting){e.target.classList.add("is-in");io.unobserve(e.target);}});
    },{rootMargin:"-10% 0px",threshold:0.08});
    root.querySelectorAll(".aws-reveal").forEach(function(el){io.observe(el);});
  }else{
    root.querySelectorAll(".aws-reveal").forEach(function(el){el.classList.add("is-in");});
  }
  var slider=root.querySelector(".aws-slider");
  if(slider){
    var track=slider.querySelector(".aws-slider-track");
    var slides=slider.querySelectorAll(".aws-slider-slide");
    var dots=slider.querySelectorAll(".aws-slider-dot");
    var btns=slider.querySelectorAll(".aws-slider-btn");
    var total=slides.length;
    var current=0;
    var autoMs=6000;
    var autoTimer=null;
    var reduceMotion=window.matchMedia&&window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    function setIndex(i){
      if(!track||total===0) return;
      current=(i+total)%total;
      track.style.transform="translateX("+(-current*100)+"%)";
      track.setAttribute("data-index",String(current));
      dots.forEach(function(d,di){
        var on=di===current;
        d.classList.toggle("is-active",on);
        d.setAttribute("aria-selected",on?"true":"false");
      });
    }
    function next(){setIndex(current+1);}
    function prev(){setIndex(current-1);}
    function startAuto(){
      if(reduceMotion||total<=1) return;
      stopAuto();
      autoTimer=window.setInterval(next,autoMs);
    }
    function stopAuto(){if(autoTimer){window.clearInterval(autoTimer);autoTimer=null;}}
    dots.forEach(function(d){d.addEventListener("click",function(){var n=parseInt(d.getAttribute("data-dot")||"0",10);setIndex(n);startAuto();});});
    btns.forEach(function(b){b.addEventListener("click",function(){var dir=parseInt(b.getAttribute("data-dir")||"1",10);if(dir>0)next();else prev();startAuto();});});
    slider.addEventListener("mouseenter",stopAuto);
    slider.addEventListener("mouseleave",startAuto);
    slider.addEventListener("focusin",stopAuto);
    slider.addEventListener("focusout",startAuto);
    slider.addEventListener("keydown",function(e){
      if(e.key==="ArrowRight"){e.preventDefault();next();startAuto();}
      else if(e.key==="ArrowLeft"){e.preventDefault();prev();startAuto();}
    });
    if(total>0) startAuto();
  }
})();`

export default (() => {
  const C: QuartzComponent<Options> = (props: { fileData?: { frontmatter?: { lang?: string } } }) => {
    const lang: "en" | "ru" = props?.fileData?.frontmatter?.lang === "ru" ? "ru" : "en"
    return (
      <>
        {style()}
        {landing(lang)}
      </>
    )
  }
  C.displayName = "AWSLanding"
  C.afterDOMLoaded = afterDOMLoaded
  return C
}) satisfies QuartzComponentConstructor

declare global {
  type Options = void
}
