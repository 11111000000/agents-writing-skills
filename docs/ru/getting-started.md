---
title: Установка
description: Установите agents-writing-skills в opencode, pi, Claude Code или любой агент с поддержкой Agent Skills.
---

[← На главную](index)

# 🚀 Установка

> Три способа. Выберите подходящий для вашего агента.

<br>

## ⚡ Вариант 1: одной фразой (рекомендуется)

Скажите агенту, на любом языке:

> **EN:** "Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json"
>
> **RU:** «Клонируй https://github.com/11111000000/agents-writing-skills и установи скилы из manifest.json»

Агент сделает:
1. Клонирует репозиторий
2. Прочитает `manifest.json` (каталог скилов в машиночитаемом виде)
3. Скопирует каждый `skills/<name>/SKILL.md` в свою папку скилов
4. Зарегистрирует промпты (если pi)

Никаких shell-скриптов. Никаких захардкоженных путей. Работает на любой ОС с любым агентом, поддерживающим Agent Skills.

<br>

## 🔧 Вариант 2: ручная установка

```bash
# Клонируем
git clone https://github.com/11111000000/agents-writing-skills.git
cd agents-writing-skills

# Смотрим манифест
cat manifest.json | head -30

# Устанавливаем скилы (пример для opencode)
mkdir -p ~/.config/opencode/skills
cp -r skills/humanize-writer/    ~/.config/opencode/skills/
cp -r skills/humanize-editor/    ~/.config/opencode/skills/
cp -r skills/anti-ai-auditor/    ~/.config/opencode/skills/
cp -r skills/ai-pattern-rewriter/ ~/.config/opencode/skills/

# Для pi — копируем ещё промпты
cp prompts/*.md ~/.pi/agent/prompts/
```

### Куда класть скилы по агенту

| Агент | Путь к скилам | Путь к промптам |
|---|---|---|
| **opencode** | `~/.config/opencode/skills/` | n/a |
| **pi** | `~/.pi/agent/skills/` | `~/.pi/agent/prompts/` |
| **Claude Code** | `~/.claude/skills/` | n/a |
| **Codex CLI** | per docs | вручную |
| **Другой** | смотрите документацию агента | вручную |

<br>

## 📦 Вариант 3: офлайн-установка

```bash
# 1. Установите скилы (как выше)

# 2. Установите базу знаний локально
./scripts/install-knowledge.sh
# Клонирует в ~/.cache/agents-writing-skills-knowledge

# 3. Задайте переменную окружения
export KNOWLEDGE_PATH="$HOME/.cache/agents-writing-skills-knowledge/knowledge"

# 4. Замените GitHub-ссылки в скилах на $KNOWLEDGE_PATH/ (если нужен полный офлайн)
```

> [!tip] Когда использовать офлайн
> Только если агент работает без интернета. В 99% случаев GitHub-ссылки достаточно.

<br>

## ✅ Проверка установки

### 1. Тест benchmark-skill.sh

```bash
bash scripts/benchmark-skill.sh <(echo "В современном мире важно понимать, что...")
# Должен выдать YapScore > 1.5 (из-за over-generation)
```

### 2. Спросите агента

> **EN:** "Help me write a README"
>
> **RU:** «Помоги написать README»

Агент должен сам подгрузить `humanize-writer`. Если нет — у агента нет поддержки Agent Skills, смотрите [Совместимость](#совместимость).

<br>

## 🎯 Первые сценарии

### Переписать AI-черновик

```bash
# В pi:
> /humanize это: [вставить AI-блог-пост]
> /audit-ai /path/to/my-draft.md
> /audit-43 /path/to/my-draft.md   # полный аудит по 43 паттернам
```

### Написать новый текст

```
> Помоги написать лендинг для новой CLI-тулы
> Набросай блог-пост про X
> Напиши письмо Y о том, почему надо сдвинуть дедлайн
```

### Диагностика

```
> Это слишком AI? [вставить текст]
> Почему мой черновик звучит так generic?
> Сравни версию A и версию B по AI-маркерам
```

<br>

## 🔄 Обновление

```bash
cd agents-writing-skills
git pull
```

Агент подхватит изменения при следующей загрузке скила.

<br>

## 📚 Дальше

| Документ | Что внутри |
|---|---|
| [Обзор скилов](skills-overview) | 4 скила, 4 фазы, 12 рычагов, когда какой |
| [База знаний](knowledge-base) | Тур по 41+ заметкам (паттерны, техники, источники) |
| [Ограничения](limitations) | Что эти скилы могут и чего не могут |
| [Contributing](contributing) | Добавить новые скилы, промпты, заметки |

<br>

[← На главную](index) · [Далее: Обзор скилов →](skills-overview)
