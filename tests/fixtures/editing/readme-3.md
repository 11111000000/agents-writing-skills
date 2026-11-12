---
id: readme-3
language: ru
genre: readme
audience: developers
edit_mode: style
required_preservation:
  claims: ["в версии 1.4 время отклика снизилось с 400 до 250 мс", "поддерживает TTL и вытеснение по LRU", "устанавливается командой npm install cachelayer"]
  conditions: []
  exceptions: []
  uncertainty: []
  terminology: ["CacheLayer", "TTL", "LRU"]
forbidden_additions: ["p99 и RPS, которых нет в исходнике", "личный опыт", "бенчмарки на реальных данных"]
expected_issues: ["дублирование производной величины (150 мс вычислимо из 400 и 250)", "перечислительный тон"]
allow_major_rewrite: false
allow_number_drop: true
---

## Source
CacheLayer — библиотека кеширования для Node.js. Она хранит данные в памяти и на диске. В версии 1.4 время отклика снизилось с 400 до 250 мс — то есть на 150 мс. Библиотека поддерживает TTL и вытеснение по LRU. Устанавливается командой npm install cachelayer. Документация доступна в каталоге docs.

## Gold edit
CacheLayer — библиотека кеширования для Node.js: хранит данные в памяти и на диске, поддерживает TTL и вытеснение по LRU. В версии 1.4 время отклика снизилось с 400 до 250 мс. Установка: npm install cachelayer. Документация — в каталоге docs.
