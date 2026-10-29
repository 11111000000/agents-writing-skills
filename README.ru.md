# agents-writing-skills (на русском)

**Скилы и промпты для агентов, которые пишут текст, не похожий на AI.**

В репозитории:

1. **Скилы** для [opencode](https://opencode.ai), [pi](https://github.com/badlogic/pi-mono), Claude Code и других агентов, поддерживающих Agent Skills. Скилы помогают агенту писать, редактировать и проверять текст так, чтобы он читался как написанный человеком.
2. **Промпты** для [pi](https://github.com/badlogic/pi-mono): `/humanize`, `/audit-ai` и другие.
3. **База знаний** — Obsidian-хранилище, документирующее паттерны, техники и методы обнаружения.

> [!important] Чего это НЕ делает
> Это не инструмент для обхода AI-детекторов. Скилы помогают тексту читаться как человеческому для обычного читателя. Они не гарантируют прохождение GPTZero, Pangram, Grammarly. Подробнее: [`knowledge/05-References/limits-and-self-critique.md`](knowledge/05-References/limits-and-self-critique.md).

## Установка

Скажите агенту:

```
Клонируй https://github.com/11111000000/agents-writing-skills и установи скилы из manifest.json
```

Агент:
1. Клонирует репозиторий
2. Читает `manifest.json`
3. Копирует скилы в свою директорию
4. Регистрирует промпты, если нужно

Без скриптов. Без захардкоженных путей. Любой агент, любая ОС.

### Ручная установка

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/11111000000/agents-writing-skills.git
   ```

2. Прочитайте `manifest.json`, чтобы понять, что доступно.

3. Скопируйте скилы в директорию скилов вашего агента:
   - opencode: `~/.config/opencode/skills/`
   - pi: `~/.pi/agent/skills/`
   - claude-code: `~/.claude/skills/`

## Что вы получаете

### Скилы

| Скил | Назначение |
|---|---|
| `humanize-writer` | Написание нового текста без AI-паттернов |
| `humanize-editor` | Переписать готовый текст, чтобы он читался как человеческий |
| `anti-ai-auditor` | Диагностика текста без переписывания |
| `ai-pattern-rewriter` | Точечные правки AI-паттернов |

### Промпты для pi

| Команда | Назначение |
|---|---|
| `/humanize` | Переписать AI-текст на человеческий |
| `/audit-ai` | Проверить вероятность AI-генерации |
| `/audit-43` | Аудит по полному 43-паттерновому каталогу |
| `/humanize-9-levers` | Применить 9 рычагов из harshaneel |
| `/anti-thesis` | Обнаружить и переписать антитезисы (P9) |
| `/writer-voice` | Написать текст без AI-паттернов |
| `/clean-draft` | Лёгкая чистка черновика |
| `/rewrite-ai` | Точечная правка фразы |
| `/honest-check` | Проверка «стоит ли применять скил» |

### База знаний (Obsidian)

См. [`knowledge/README.md`](knowledge/README.md). Хранилище документирует 43 категории AI-паттернов (от Aboudjem), 12-рычажную систему (9 рычагов от harshaneel + суффицентность, айсберг, русская краткость), русскую специфику и методы обнаружения (Binoculars, MASH, watermarking).

## Как работают скилы

Скилы — это Markdown-файлы с YAML frontmatter. Они лежат в `~/.config/opencode/skills/<name>/SKILL.md` (или `~/.pi/agent/skills/<name>/SKILL.md`). Когда агент видит задачу, подходящую под `description` скила, он загружает скил автоматически.

Каждый скил содержит:

- **Жёсткие правила** — обязательные паттерны
- **Процесс работы** — пошаговый алгоритм
- **Связанные скилы** — когда комбинировать
- **Ограничения** — когда НЕ применять

Пример frontmatter:

```yaml
---
name: humanize-writer
description: Write new prose that avoids typical LLM patterns...
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-generation
  version: 2
---
```

## Документация

- **[База знаний](knowledge/README.md)** — паттерны, техники, примеры
- **[Contributing](CONTRIBUTING.md)** — как добавить скил или промпт
- **[Changelog](CHANGELOG.md)** — что изменилось
- **[Ограничения](knowledge/05-References/limits-and-self-critique.md)** — эпистемический анализ

## Лицензия

- Скилы и промпты: MIT
- Заметки базы знаний: CC-BY-SA-4.0
- См. [LICENSE](LICENSE).

## Участие в разработке

Принимаем контрибуции. См. [CONTRIBUTING.md](CONTRIBUTING.md). Для новых скилов используйте [`skills/template-skill/`](skills/template-skill/) как стартовую точку.

## Благодарности

Построено на основе исследований:

- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) — 43-паттерновый каталог (MIT)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) — 9 рычагов (MIT)
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — community-maintained patterns
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста) — русские паттерны
- Академические работы: Binoculars (ICML 2024), Watermarking (ICML 2023), MASH (ACL 2026)
