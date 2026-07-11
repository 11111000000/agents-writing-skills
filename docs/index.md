---
title: Agents Writing Skills
description: Skills, prompts, and a knowledge base for agents that edit prose with measurable AI-pattern checks.
tags: [home, landing]
---

<style>
.aws-landing {
  --ink: #221b16;
  --muted: #756b62;
  --paper: #fff8ef;
  --paper-2: #f4eadc;
  --line: rgba(47, 35, 27, 0.16);
  --accent: #8f4a2f;
  --accent-2: #3a5f55;
  --dark: #201814;
  --dark-2: #2a211c;
  --code: #15110e;
  color: var(--ink);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  margin: -1rem auto 0;
  max-width: 1180px;
}

.aws-landing input[name="aws-lang"] {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.aws-shell {
  background:
    radial-gradient(circle at 10% 0%, rgba(143, 74, 47, 0.18), transparent 32rem),
    radial-gradient(circle at 88% 12%, rgba(58, 95, 85, 0.16), transparent 30rem),
    linear-gradient(180deg, var(--paper), #fffdf8 46%, var(--paper-2));
  border: 1px solid var(--line);
  border-radius: 28px;
  box-shadow: 0 24px 70px rgba(42, 33, 28, 0.12);
  overflow: hidden;
}

.aws-topbar {
  align-items: center;
  border-bottom: 1px solid var(--line);
  display: flex;
  gap: 1rem;
  justify-content: space-between;
  padding: 1rem clamp(1rem, 4vw, 3rem);
}

.aws-brand {
  align-items: center;
  display: flex;
  gap: 0.75rem;
  font-weight: 700;
  letter-spacing: -0.03em;
}

.aws-mark {
  background: var(--dark);
  border-radius: 12px;
  color: #f4eadc;
  display: grid;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  height: 2.25rem;
  place-items: center;
  width: 2.25rem;
}

.aws-lang-switch {
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid var(--line);
  border-radius: 999px;
  display: flex;
  padding: 0.25rem;
}

.aws-lang-switch label {
  border-radius: 999px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 700;
  padding: 0.55rem 0.85rem;
  transition: background 0.16s ease, color 0.16s ease;
}

#aws-en:checked ~ .aws-shell label[for="aws-en"],
#aws-ru:checked ~ .aws-shell label[for="aws-ru"] {
  background: var(--dark);
  color: #fff8ef;
}

.aws-panel {
  display: none;
}

#aws-en:checked ~ .aws-shell .aws-panel-en,
#aws-ru:checked ~ .aws-shell .aws-panel-ru {
  display: block;
}

.aws-hero {
  display: grid;
  gap: clamp(1.5rem, 4vw, 4rem);
  grid-template-columns: minmax(0, 1.05fr) minmax(280px, 0.95fr);
  padding: clamp(2rem, 6vw, 5rem) clamp(1rem, 4vw, 3rem) clamp(1.5rem, 4vw, 3rem);
}

.aws-kicker {
  color: var(--accent);
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  margin-bottom: 1.25rem;
  text-transform: uppercase;
}

.aws-hero h1 {
  color: var(--ink);
  font-size: clamp(3rem, 8vw, 6.8rem);
  letter-spacing: -0.08em;
  line-height: 0.88;
  margin: 0;
  max-width: 10ch;
}

.aws-hero h1 span {
  color: var(--accent-2);
  display: block;
}

.aws-lead {
  color: var(--muted);
  font-size: clamp(1.05rem, 2vw, 1.35rem);
  line-height: 1.55;
  margin: 1.4rem 0 0;
  max-width: 42rem;
}

.aws-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.8rem;
  margin-top: 1.7rem;
}

.aws-button {
  align-items: center;
  border-radius: 999px;
  display: inline-flex;
  font-weight: 800;
  justify-content: center;
  min-height: 2.9rem;
  padding: 0 1.15rem;
  text-decoration: none;
}

.aws-button-primary {
  background: var(--dark);
  color: #fff8ef;
}

.aws-button-secondary {
  border: 1px solid var(--line);
  color: var(--ink);
}

.aws-button:hover {
  transform: translateY(-1px);
}

.aws-terminal {
  align-self: stretch;
  background: linear-gradient(180deg, var(--dark), var(--dark-2));
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 24px;
  box-shadow: 0 24px 60px rgba(32, 24, 20, 0.28);
  color: #f6eadf;
  display: flex;
  flex-direction: column;
  min-height: 28rem;
  overflow: hidden;
}

.aws-terminal-head {
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  color: #bba99a;
  display: flex;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.82rem;
  gap: 0.45rem;
  padding: 0.9rem 1rem;
}

.aws-dot {
  border-radius: 999px;
  height: 0.68rem;
  width: 0.68rem;
}

.aws-dot:nth-child(1) { background: #c96b4f; }
.aws-dot:nth-child(2) { background: #c7a652; }
.aws-dot:nth-child(3) { background: #6da071; }

.aws-code {
  display: grid;
  gap: 0.85rem;
  padding: 1.3rem;
}

.aws-code-line {
  align-items: start;
  display: grid;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: clamp(0.82rem, 1.3vw, 0.95rem);
  gap: 0.8rem;
  grid-template-columns: 5.6rem 1fr;
  line-height: 1.45;
}

.aws-code-line strong {
  color: #d7b28b;
  font-weight: 700;
}

.aws-code-line span:last-child {
  color: #f6eadf;
}

.aws-code-bad span:last-child {
  color: #ffb5a3;
}

.aws-code-good span:last-child {
  color: #b8e0c2;
}

.aws-meter {
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  display: grid;
  gap: 0.75rem;
  margin-top: auto;
  padding: 1.15rem 1.3rem 1.35rem;
}

.aws-meter-row {
  display: grid;
  gap: 0.75rem;
  grid-template-columns: 5rem 1fr 3.5rem;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.78rem;
}

.aws-bar {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 999px;
  overflow: hidden;
}

.aws-bar i {
  background: linear-gradient(90deg, #c96b4f, #d7b28b, #6da071);
  display: block;
  height: 100%;
}

.aws-section {
  padding: clamp(2rem, 5vw, 4rem) clamp(1rem, 4vw, 3rem);
}

.aws-section-dark {
  background: var(--dark);
  color: #fff8ef;
}

.aws-section h2 {
  font-size: clamp(2rem, 4vw, 3.4rem);
  letter-spacing: -0.06em;
  line-height: 0.95;
  margin: 0 0 1rem;
  max-width: 14ch;
}

.aws-section p {
  color: var(--muted);
  font-size: 1.05rem;
  line-height: 1.6;
  max-width: 48rem;
}

.aws-section-dark p {
  color: #cbbcaf;
}

.aws-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  margin-top: 1.8rem;
}

.aws-card {
  background: rgba(255, 255, 255, 0.64);
  border: 1px solid var(--line);
  border-radius: 22px;
  padding: 1.15rem;
}

.aws-section-dark .aws-card {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.12);
}

.aws-card h3 {
  font-size: 1.05rem;
  letter-spacing: -0.02em;
  margin: 0 0 0.65rem;
}

.aws-card p {
  font-size: 0.92rem;
  margin: 0;
}

.aws-flow {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  margin-top: 1.8rem;
}

.aws-step {
  background: #fff8ef;
  border: 1px solid var(--line);
  border-radius: 24px;
  padding: 1.35rem;
  position: relative;
}

.aws-step small {
  color: var(--accent);
  display: block;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.75rem;
  font-weight: 800;
  margin-bottom: 0.75rem;
  text-transform: uppercase;
}

.aws-step h3 {
  font-size: 1.35rem;
  letter-spacing: -0.04em;
  margin: 0 0 0.55rem;
}

.aws-step p {
  font-size: 0.94rem;
  margin: 0;
}

.aws-stats {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  margin-top: 1.8rem;
}

.aws-stat {
  border-left: 1px solid var(--line);
  padding-left: 1rem;
}

.aws-stat strong {
  display: block;
  font-size: clamp(1.8rem, 4vw, 3rem);
  letter-spacing: -0.07em;
  line-height: 1;
}

.aws-stat span {
  color: var(--muted);
  font-size: 0.92rem;
}

.aws-install {
  background: #11100f;
  border-radius: 22px;
  color: #f6eadf;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  line-height: 1.6;
  margin-top: 1.5rem;
  overflow-x: auto;
  padding: 1.25rem;
}

.aws-docs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.7rem;
  margin-top: 1.3rem;
}

.aws-docs a {
  border: 1px solid var(--line);
  border-radius: 999px;
  color: var(--ink);
  font-weight: 800;
  padding: 0.65rem 0.9rem;
  text-decoration: none;
}

.aws-footer {
  align-items: center;
  border-top: 1px solid var(--line);
  color: var(--muted);
  display: flex;
  flex-wrap: wrap;
  gap: 0.8rem;
  justify-content: space-between;
  padding: 1.2rem clamp(1rem, 4vw, 3rem);
}

.aws-footer a {
  color: var(--ink);
  font-weight: 800;
}

@media (max-width: 900px) {
  .aws-hero,
  .aws-grid,
  .aws-flow,
  .aws-stats {
    grid-template-columns: 1fr;
  }

  .aws-terminal {
    min-height: auto;
  }
}

@media (max-width: 560px) {
  .aws-topbar {
    align-items: flex-start;
    flex-direction: column;
  }

  .aws-lang-switch {
    width: 100%;
  }

  .aws-lang-switch label {
    flex: 1;
    text-align: center;
  }

  .aws-code-line,
  .aws-meter-row {
    grid-template-columns: 1fr;
  }
}
</style>

<div class="aws-landing">
  <input id="aws-en" name="aws-lang" type="radio" checked>
  <input id="aws-ru" name="aws-lang" type="radio">
  <div class="aws-shell">
    <div class="aws-topbar">
      <div class="aws-brand"><span class="aws-mark">A</span><span>agents-writing-skills</span></div>
      <div class="aws-lang-switch" aria-label="Language switcher">
        <label for="aws-en">English</label>
        <label for="aws-ru">Русский</label>
      </div>
    </div>

    <section class="aws-panel aws-panel-en">
      <div class="aws-hero">
        <div>
          <div class="aws-kicker">Agent skills for prose</div>
          <h1>Write less <span>like a model.</span></h1>
          <p class="aws-lead">Four skills, 9 pi prompts, and a 41-note knowledge base for agents that write, rewrite, and audit prose with measurable AI-pattern checks.</p>
          <div class="aws-actions">
            <a class="aws-button aws-button-primary" href="getting-started">Install skills</a>
            <a class="aws-button aws-button-secondary" href="knowledge-base">Browse knowledge</a>
          </div>
        </div>
        <div class="aws-terminal" aria-label="Example audit panel">
          <div class="aws-terminal-head"><span class="aws-dot"></span><span class="aws-dot"></span><span class="aws-dot"></span><span>benchmark-skill.sh</span></div>
          <div class="aws-code">
            <div class="aws-code-line aws-code-bad"><strong>before</strong><span>It is worth noting that this comprehensive solution plays a crucial role in improving productivity.</span></div>
            <div class="aws-code-line aws-code-good"><strong>after</strong><span>47 tasks. Three projects. One config in ~/.config/genium/tasks.toml.</span></div>
            <div class="aws-code-line"><strong>check</strong><span>AP, D, E, YapScore, burstiness, specificity, format bias, voice.</span></div>
          </div>
          <div class="aws-meter">
            <div class="aws-meter-row"><span>YapScore</span><span class="aws-bar"><i style="width: 72%"></i></span><span>1.18</span></div>
            <div class="aws-meter-row"><span>Facts</span><span class="aws-bar"><i style="width: 88%"></i></span><span>4/para</span></div>
            <div class="aws-meter-row"><span>Voice</span><span class="aws-bar"><i style="width: 64%"></i></span><span>human</span></div>
          </div>
        </div>
      </div>

      <div class="aws-section">
        <h2>The system</h2>
        <p>The repository packages a writing workflow agents can load on demand: greenfield writing, full rewrite, diagnostic audit, and surgical line edits.</p>
        <div class="aws-grid">
          <div class="aws-card"><h3>humanize-writer</h3><p>Drafts README sections, emails, posts, and announcements with voice, facts, and density checks.</p></div>
          <div class="aws-card"><h3>humanize-editor</h3><p>Rewrites AI-sounding drafts while preserving names, dates, numbers, commands, and claims.</p></div>
          <div class="aws-card"><h3>anti-ai-auditor</h3><p>Returns a diagnosis only: pattern hits, risk score, metrics, and concrete priorities.</p></div>
          <div class="aws-card"><h3>ai-pattern-rewriter</h3><p>Fixes one phrase or paragraph without reshaping the whole document.</p></div>
        </div>
      </div>

      <div class="aws-section aws-section-dark">
        <h2>How it works</h2>
        <p>Every skill follows the same operating loop. Count first. Rewrite second. Verify facts last.</p>
        <div class="aws-flow">
          <div class="aws-step"><small>Pass 1</small><h3>Audit</h3><p>Find em-dashes, hedging, rule-of-three, negative parallelisms, low burstiness, weak specificity.</p></div>
          <div class="aws-step"><small>Pass 2</small><h3>Rewrite</h3><p>Apply 12 levers: STRIP, TIGHTEN, RELY, REBUILD. Russian text gets парцелляция, эллипсис, литота.</p></div>
          <div class="aws-step"><small>Pass 3</small><h3>Verify</h3><p>Check fact loss, YapScore, density, and whether the result reads like a person had a reason to write it.</p></div>
        </div>
      </div>

      <div class="aws-section">
        <h2>Research-grounded</h2>
        <p>The rules come from Aboudjem's 43-pattern catalogue, harshaneel's 9 base levers, YapBench, MASH, Binoculars, Lamparth 2026, Hemingway, Grice, Shklovsky, Tolstoy, Dovlatov, and Russian brevity grammar.</p>
        <div class="aws-stats">
          <div class="aws-stat"><strong>4</strong><span>agent skills</span></div>
          <div class="aws-stat"><strong>9</strong><span>pi prompt templates</span></div>
          <div class="aws-stat"><strong>12</strong><span>writing levers</span></div>
          <div class="aws-stat"><strong>41+</strong><span>knowledge notes</span></div>
        </div>
      </div>

      <div class="aws-section">
        <h2>Install</h2>
        <p>Tell an agent to read the manifest, or copy the directories yourself.</p>
        <pre class="aws-install">git clone https://github.com/11111000000/agents-writing-skills.git
cd agents-writing-skills
cp -r skills/humanize-writer ~/.config/opencode/skills/
cp -r skills/humanize-editor ~/.config/opencode/skills/
cp -r skills/anti-ai-auditor ~/.config/opencode/skills/
cp -r skills/ai-pattern-rewriter ~/.config/opencode/skills/</pre>
        <div class="aws-docs">
          <a href="getting-started">Getting started</a>
          <a href="skills-overview">Skills overview</a>
          <a href="limitations">Limits</a>
          <a href="contributing">Contributing</a>
        </div>
      </div>
    </section>

    <section class="aws-panel aws-panel-ru">
      <div class="aws-hero">
        <div>
          <div class="aws-kicker">Скилы для агентского письма</div>
          <h1>Пишите меньше <span>как модель.</span></h1>
          <p class="aws-lead">Четыре скила, 9 pi-промптов и база из 41+ заметок для агентов, которые пишут, редактируют и проверяют прозу по измеримым AI-маркерам.</p>
          <div class="aws-actions">
            <a class="aws-button aws-button-primary" href="getting-started">Установить</a>
            <a class="aws-button aws-button-secondary" href="knowledge-base">Открыть базу</a>
          </div>
        </div>
        <div class="aws-terminal" aria-label="Панель аудита текста">
          <div class="aws-terminal-head"><span class="aws-dot"></span><span class="aws-dot"></span><span class="aws-dot"></span><span>benchmark-skill.sh</span></div>
          <div class="aws-code">
            <div class="aws-code-line aws-code-bad"><strong>до</strong><span>Стоит отметить, что данное комплексное решение играет ключевую роль в повышении эффективности.</span></div>
            <div class="aws-code-line aws-code-good"><strong>после</strong><span>47 задач. Три проекта. Один конфиг в ~/.config/genium/tasks.toml.</span></div>
            <div class="aws-code-line"><strong>замер</strong><span>AP, D, E, YapScore, burstiness, конкретика, format bias, голос.</span></div>
          </div>
          <div class="aws-meter">
            <div class="aws-meter-row"><span>YapScore</span><span class="aws-bar"><i style="width: 72%"></i></span><span>1.18</span></div>
            <div class="aws-meter-row"><span>Факты</span><span class="aws-bar"><i style="width: 88%"></i></span><span>4/абз</span></div>
            <div class="aws-meter-row"><span>Голос</span><span class="aws-bar"><i style="width: 64%"></i></span><span>живой</span></div>
          </div>
        </div>
      </div>

      <div class="aws-section">
        <h2>Система</h2>
        <p>Репозиторий упаковывает рабочий процесс для агентов: новый текст, полный rewrite, диагностический аудит и точечные правки строк.</p>
        <div class="aws-grid">
          <div class="aws-card"><h3>humanize-writer</h3><p>Пишет README, письма, посты и анонсы с голосом, фактами и проверкой плотности.</p></div>
          <div class="aws-card"><h3>humanize-editor</h3><p>Переписывает AI-черновик, сохраняя имена, даты, числа, команды и claims.</p></div>
          <div class="aws-card"><h3>anti-ai-auditor</h3><p>Даёт только диагноз: найденные паттерны, риск, метрики и приоритеты правки.</p></div>
          <div class="aws-card"><h3>ai-pattern-rewriter</h3><p>Правит одну фразу или абзац, не перестраивая весь документ.</p></div>
        </div>
      </div>

      <div class="aws-section aws-section-dark">
        <h2>Как работает</h2>
        <p>У каждого скила один цикл. Сначала счёт. Потом rewrite. В конце проверка фактов.</p>
        <div class="aws-flow">
          <div class="aws-step"><small>Pass 1</small><h3>Audit</h3><p>Ищем em-dash, hedging, rule-of-three, negative parallelisms, низкую burstiness, слабую конкретику.</p></div>
          <div class="aws-step"><small>Pass 2</small><h3>Rewrite</h3><p>Применяем 12 рычагов: STRIP, TIGHTEN, RELY, REBUILD. Для русского — парцелляция, эллипсис, литота.</p></div>
          <div class="aws-step"><small>Pass 3</small><h3>Verify</h3><p>Проверяем потерю фактов, YapScore, плотность и ощущение: текст написал человек с причиной.</p></div>
        </div>
      </div>

      <div class="aws-section">
        <h2>Основано на источниках</h2>
        <p>Правила собраны из 43-pattern catalogue Aboudjem, 9 базовых levers harshaneel, YapBench, MASH, Binoculars, Lamparth 2026, Hemingway, Grice, Шкловского, Толстого, Довлатова и русской грамматики краткости.</p>
        <div class="aws-stats">
          <div class="aws-stat"><strong>4</strong><span>agent skill’а</span></div>
          <div class="aws-stat"><strong>9</strong><span>pi-промптов</span></div>
          <div class="aws-stat"><strong>12</strong><span>рычагов письма</span></div>
          <div class="aws-stat"><strong>41+</strong><span>заметка в базе</span></div>
        </div>
      </div>

      <div class="aws-section">
        <h2>Установка</h2>
        <p>Скажите агенту прочитать manifest или скопируйте директории вручную.</p>
        <pre class="aws-install">git clone https://github.com/11111000000/agents-writing-skills.git
cd agents-writing-skills
cp -r skills/humanize-writer ~/.config/opencode/skills/
cp -r skills/humanize-editor ~/.config/opencode/skills/
cp -r skills/anti-ai-auditor ~/.config/opencode/skills/
cp -r skills/ai-pattern-rewriter ~/.config/opencode/skills/</pre>
        <div class="aws-docs">
          <a href="getting-started">Getting started</a>
          <a href="skills-overview">Skills overview</a>
          <a href="limitations">Ограничения</a>
          <a href="contributing">Contributing</a>
        </div>
      </div>
    </section>

    <div class="aws-footer">
      <span>agents-writing-skills v1.4.0</span>
      <span><a href="https://github.com/11111000000/agents-writing-skills">GitHub</a> · <a href="knowledge-base">Knowledge base</a> · <a href="limitations">Limits</a></span>
    </div>

    <noscript>
      <div class="aws-shell" style="margin:1.5rem auto;padding:1.25rem;">
        <h2 style="margin-top:0;">Read without JavaScript</h2>
        <p>This page relies on radio buttons to switch the language. If you have JavaScript off, you can <a href="knowledge-base">browse the knowledge base</a> directly or <a href="https://github.com/11111000000/agents-writing-skills/blob/main/docs/index.md">read the source on GitHub</a>.</p>
      </div>
    </noscript>
  </div>
</div>
