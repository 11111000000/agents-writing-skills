# agents-writing-skills

<p align="center">

**Skills and prompts that make AI text read like a human wrote it.**

[**🌐 Website →**](https://11111000000.github.io/agents-writing-skills/) · [Getting Started](docs/getting-started.md) · [Skills Overview](docs/skills-overview.md) · [Knowledge Base Tour](docs/knowledge-base.md)

[🇬🇧 English](#english) · [🇷🇺 Русский](#русский)

</p>

---

<a id="english"></a>

**Skills and prompts for agents that write text without sounding like AI.**

This repository provides:

1. **Skills** for opencode, pi, Claude Code, Codex CLI, and other Agent Skills-compatible agents. Skills help the agent write, edit, and audit prose so it reads as human-authored.
2. **Prompt templates** for pi, exposed as `/humanize`, `/audit-ai`, etc.
3. **Knowledge base** — an Obsidian-formatted vault (41+ notes) documenting the patterns, techniques, and detection methods behind the skills.
4. **Benchmark script** — measure your text against AI-pattern metrics (AP, D, E, YapScore, burstiness, specificity).

> [!important] What this is NOT
> This is not a tool for evading AI detection. Skills help text **read as human** to human readers. They do not guarantee passing commercial detectors like GPTZero, Pangram, or Grammarly. See [`knowledge/05-References/limits-and-self-critique.md`](knowledge/05-References/limits-and-self-critique.md) for what works and what doesn't.

## ⚡ Install in one sentence

Tell your agent:

```
Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json
```

Works in any language, on any agent, any OS.

## 📦 What you get (v1.4)

### 4 production skills

| Skill | Purpose | Version |
|---|---|---|
| `humanize-writer` | Write new prose that avoids typical LLM patterns | v5 (3-pass) |
| `humanize-editor` | Rewrite existing text to read as human-authored | v5 (3-pass + Tighten) |
| `anti-ai-auditor` | Audit text for AI-pattern probability without rewriting | v4 (3-pass audit) |
| `ai-pattern-rewriter` | Surgical, line-level rewriting of specific AI-pattern phrases | v4 (3-pass surgical) |

### 12 levers in 4 phases

| Phase | What it does |
|---|---|
| 🧹 **STRIP** (1-9) | Remove AI tells (delve, leverage, hedging, em-dash...) |
| 📐 **TIGHTEN** (10) | Apply sufficiency / Grice submaxim 2 |
| 🧊 **RELY** (11) | Leave gaps, trust the reader (Hemingway iceberg) |
| 🇷🇺 **REBUILD** (12) | Russian brevity grammar (парцелляция, эллипсис, литота) |

### 41+ knowledge notes

- 43-pattern catalogue (from Aboudjem/humanizer-skill)
- Russian-specific patterns (деепричастия, парные синонимы, канцелярит)
- 5 academic papers on length bias (Park, Shen, Zhang, Lamparth, Huang)
- 13 worked examples with measured metrics
- Laconic prose models (Tolstoy, Dovlatov, Shklovsky, Bunin)
- Raw source-notes for every claim

### Validation tooling

```bash
bash scripts/validate-skills.sh    # CI gate
bash scripts/test-benchmark.sh    # smoke tests
bash scripts/benchmark-skill.sh file.txt  # measure YOUR text
```

## How to install

See [**Getting Started**](docs/getting-started.md) for three install methods:

1. **One-line** — tell your agent to clone + install
2. **Manual** — git clone + cp skills + prompts to agent directories
3. **Offline** — `./scripts/install-knowledge.sh` for air-gapped environments

## Documentation

| Resource | What it covers |
|---|---|
| [🌐 Website](https://11111000000.github.io/agents-writing-skills/) | Rendered knowledge base with full navigation |
| [Getting Started](docs/getting-started.md) | Three install methods + verification |
| [Skills Overview](docs/skills-overview.md) | 4 skills, 4 phases, 12 levers — when to use which |
| [Knowledge Base tour](docs/knowledge-base.md) | Walk through 41+ notes by category |
| [Limitations](docs/limitations.md) | What these skills can and cannot do |
| [Contributing](CONTRIBUTING.md) | How to add new skills, prompts, notes |

## License

- Skills and prompts: [MIT](LICENSE)
- Knowledge base notes: [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/)

---

<a id="русский"></a>

# agents-writing-skills *(RU)*

**Скилы и промпты, которые делают AI-текст читаемым как человеческий.**

В репозитории:

1. **Скилы** для opencode, pi, Claude Code и любых агентов с поддержкой [Agent Skills](https://agentskills.io). Помогают агенту писать, редактировать и аудировать прозу.
2. **9 промптов** для pi: `/humanize`, `/audit-ai`, `/audit-43` и др.
3. **Knowledge base** — Obsidian vault (41+ заметок) с паттернами, техниками, источниками.
4. **`benchmark-skill.sh`** — замеряет AI-метрики на вашем тексте.

> [!important] Что это НЕ
> Не инструмент для обхода AI-детекторов. Скилы помогают тексту **читаться как человеческому** для человеческих читателей. Не гарантируют прохождение GPTZero, Pangram, Grammarly.

## ⚡ Установка одной строкой

Скажите агенту:

```
Клонируй https://github.com/11111000000/agents-writing-skills и установи скилы из manifest.json
```

Работает на любом агенте с любой ОС.

## 📦 Что внутри (v1.4)

### 4 production скила

| Скил | Назначение | Версия |
|---|---|---|
| `humanize-writer` | Писать прозу без AI-маркеров | v5 (3-pass) |
| `humanize-editor` | Переписать существующий текст | v5 (3-pass + Tighten) |
| `anti-ai-auditor` | Диагностика без переписывания | v4 (3-pass аудит) |
| `ai-pattern-rewriter` | Хирургические правки конкретных spans | v4 (3-pass surgical) |

### 12 рычагов в 4 фазах

| Фаза | Что делают |
|---|---|
| 🧹 **STRIP** (1-9) | Удаляют AI-маркеры (delve, leverage, hedging, em-dash) |
| 📐 **TIGHTEN** (10) | Суффицентность / Grice submaxim 2 |
| 🧊 **RELY** (11) | Iceberg — оставлять пробелы |
| 🇷🇺 **REBUILD** (12) | Русские грамматические приёмы (парцелляция, эллипсис, литота) |

### Документация

| Ресурс | Что |
|---|---|
| [🌐 Сайт](https://11111000000.github.io/agents-writing-skills/) | Knowledge base с навигацией |
| [Getting Started](docs/getting-started.md) | 3 способа установки |
| [Skills Overview](docs/skills-overview.md) | 4 скила, 4 фазы, 12 рычагов |
| [Knowledge Base tour](docs/knowledge-base.md) | Тур по 41+ заметкам |
| [Limitations](docs/limitations.md) | Что могут и не могут скилы |
| [Contributing](CONTRIBUTING.md) | Как добавить новый скил |

## Credits

Built on research from:

- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) — 43-pattern catalogue (MIT)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) — 9 humanization levers (MIT)
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста) — Russian patterns
- Academic papers: Binoculars (ICML 2024), Watermarking (ICML 2023), MASH (ACL 2026), Park (2024), Shen (2023), Zhang (2024), Lamparth (2026), Huang (2024), Borisov YapBench (2026)