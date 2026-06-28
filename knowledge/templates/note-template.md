---
type: template
tags: [template]
created: 2026-06-28
status: active
---

# Шаблон заметки (для копирования)

```markdown
---
type: <pattern|technique|reference|example|template|moc>
tags: [<tag1>, <tag2>]
created: YYYY-MM-DD
status: <draft|active|archived>
related: [<other-note-name>]
---

# Заголовок

> [!info] О чём заметка
> Одно-двух-строчное описание сути.

## Что это

...

## Как применять

> [!tip] Совет
> ...

## Пример

> ❌ Плохо: ...
> ✅ Хорошо: ...

## Связанные заметки

- [[другая-заметка]]
- [[ещё-одна]]
```

## Callout'ы (стандарт Obsidian)

```markdown
> [!note] Обычное примечание
> ...

> [!info] Информация
> ...

> [!tip] Совет
> ...

> [!warning] Предупреждение
> ...

> [!example] Пример
> ...

> [!quote] Цитата
> ...
```

## Конвенции

- Все имена файлов — `kebab-case`
- Связи — через `[[wikilinks]]`
- Теги — плоские, через дефис
- YAML frontmatter обязателен для всех заметок кроме MOC