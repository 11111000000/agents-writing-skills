---
title: Agents Writing Skills — Писать меньше, как модель
description: Skills, prompts и Obsidian-база для агентов, которые пишут, правят и проверяют прозу измеримыми AI-проверками.
tags: [home, landing, ru]
lang: ru
---

<style>
.aws-landing {
  --ink: #1a140c;
  --ink-2: #2c2418;
  --paper: #fbf7ed;
  --paper-2: #f0e9d6;
  --paper-3: #e7dec5;
  --muted: #6b5c47;
  --line: rgba(26, 20, 12, 0.16);
  --accent: #8b3a1f;
  --accent-2: #3d5a40;
  --dark: #14110d;
  --dark-2: #1f1a14;
  --code: #0f0c09;
  color: var(--ink);
  font-family: "Inter", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  margin: 0 auto 4rem;
  max-width: 1200px;
  padding: 0 clamp(1rem, 3vw, 2rem);
}

.aws-landing h1,
.aws-landing h2,
.aws-landing h3,
.aws-landing .aws-serif {
  font-family: "Newsreader", "IBM Plex Serif", Georgia, serif;
  font-feature-settings: "ss01", "ss02";
  letter-spacing: -0.02em;
}

.aws-shell {
  background:
    radial-gradient(1200px 600px at 5% -10%, rgba(139, 58, 31, 0.06), transparent),
    radial-gradient(900px 500px at 110% 12%, rgba(61, 90, 64, 0.07), transparent),
    linear-gradient(180deg, #fdfaef 0%, var(--paper) 38%, var(--paper-2) 100%);
  border: 1px solid var(--line);
  border-radius: 28px;
  box-shadow: 0 32px 80px -36px rgba(26, 20, 12, 0.32);
  overflow: hidden;
  position: relative;
}

.aws-shell::before {
  background:
    radial-gradient(circle at 25% 30%, rgba(26, 20, 12, 0.03), transparent 60%),
    radial-gradient(circle at 70% 60%, rgba(26, 20, 12, 0.04), transparent 55%),
    repeating-linear-gradient(
      45deg,
      transparent 0,
      transparent 4px,
      rgba(26, 20, 12, 0.012) 4px,
      rgba(26, 20, 12, 0.012) 5px
    );
  content: "";
  inset: 0;
  pointer-events: none;
  position: absolute;
}

.aws-shell > * {
  position: relative;
}

/* progress bar */
.aws-progress {
  background: linear-gradient(90deg, var(--accent), var(--accent-2));
  height: 2px;
  position: absolute;
  top: 0;
  transform-origin: left;
  transform: scaleX(var(--aws-scroll, 0));
  transition: transform 0.1s linear;
  width: 100%;
  z-index: 5;
}

/* sticky topbar */
.aws-topbar {
  align-items: center;
  border-bottom: 1px solid var(--line);
  display: flex;
  gap: 1rem;
  justify-content: space-between;
  padding: 1rem clamp(1rem, 4vw, 3rem);
  position: sticky;
  top: 0;
  z-index: 4;
  backdrop-filter: saturate(140%) blur(6px);
  background: rgba(251, 247, 237, 0.78);
}

.aws-topbar.scrolled {
  padding-block: 0.55rem;
}

.aws-topbar.scrolled .aws-mark,
.aws-topbar.scrolled .aws-mark-name {
  transform: scale(0.9);
  transform-origin: left;
}

.aws-brand {
  align-items: center;
  display: flex;
  gap: 0.7rem;
}

.aws-mark {
  align-items: center;
  background: var(--ink);
  border-radius: 14px;
  color: var(--paper);
  display: flex;
  height: 2.5rem;
  justify-content: center;
  transition: transform 0.25s ease;
  width: 2.5rem;
}

.aws-mark svg {
  height: 1.4rem;
  width: 1.4rem;
}

.aws-mark-name {
  font-weight: 800;
  letter-spacing: -0.04em;
  transition: transform 0.25s ease;
  font-size: 1.05rem;
}

.aws-nav {
  align-items: center;
  display: flex;
  gap: 0.5rem;
}

.aws-nav a {
  border-radius: 999px;
  color: var(--muted);
  font-size: 0.92rem;
  font-weight: 600;
  padding: 0.5rem 0.9rem;
  text-decoration: none;
  transition: color 0.18s ease, background 0.18s ease;
}

.aws-nav a:hover {
  color: var(--ink);
}

.aws-lang {
  align-items: center;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid var(--line);
  border-radius: 999px;
  display: flex;
  margin-left: 0.4rem;
  padding: 0.22rem;
}

.aws-lang a {
  border-radius: 999px;
  color: var(--ink);
  font-size: 0.84rem;
  font-weight: 700;
  letter-spacing: 0.03em;
  padding: 0.45rem 0.85rem;
  text-decoration: none;
}

.aws-lang a.is-active {
  background: var(--ink);
  color: var(--paper);
}

/* hero */
.aws-hero {
  display: grid;
  gap: clamp(1.5rem, 4vw, 4rem);
  grid-template-columns: minmax(0, 1.05fr) minmax(0, 0.95fr);
  padding: clamp(2.5rem, 6vw, 5rem) clamp(1.5rem, 4vw, 3rem) clamp(2rem, 4vw, 3rem);
}

.aws-kicker {
  color: var(--accent);
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.18em;
  margin-bottom: 1.5rem;
  text-transform: uppercase;
}

.aws-hero h1 {
  color: var(--ink);
  font-size: clamp(2.6rem, 7vw, 5.6rem);
  font-weight: 500;
  letter-spacing: -0.06em;
  line-height: 0.95;
  margin: 0;
}

.aws-hero h1 .aws-pen {
  background: linear-gradient(135deg, var(--accent), #c85a35);
  color: transparent;
  display: inline-block;
  font-style: italic;
  font-weight: 600;
  letter-spacing: -0.07em;
  padding-right: 0.04em;
  -webkit-background-clip: text;
  background-clip: text;
}

.aws-hero h1 .aws-no {
  color: var(--accent);
}

.aws-lead {
  color: var(--ink-2);
  font-size: clamp(1.05rem, 1.7vw, 1.3rem);
  line-height: 1.55;
  margin: 1.6rem 0 0;
  max-width: 38rem;
}

.aws-lead strong {
  color: var(--ink);
  font-weight: 700;
}

.aws-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.7rem;
  margin: 1.8rem 0 0;
}

.aws-button {
  align-items: center;
  border-radius: 999px;
  display: inline-flex;
  font-weight: 700;
  gap: 0.55rem;
  min-height: 2.95rem;
  padding: 0 1.3rem;
  text-decoration: none;
  transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
  will-change: transform;
}

.aws-button-primary {
  background: var(--ink);
  box-shadow: 0 12px 24px -10px rgba(26, 20, 12, 0.5);
  color: var(--paper);
}

.aws-button-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 20px 28px -10px rgba(26, 20, 12, 0.55);
}

.aws-button-secondary {
  background: transparent;
  border: 1px solid var(--line);
  color: var(--ink);
}

.aws-button-secondary:hover {
  background: rgba(255, 255, 255, 0.5);
}

.aws-meta-strip {
  align-items: center;
  border-top: 1px dashed var(--line);
  color: var(--muted);
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem 1.4rem;
  margin: 2.5rem 0 0;
  padding-top: 1.4rem;
  font-family: "JetBrains Mono", ui-monospace, monospace;
  font-size: 0.82rem;
}

.aws-meta-strip b {
  color: var(--ink);
  font-weight: 700;
}

/* before/after compare */
.aws-compare {
  align-items: stretch;
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid var(--line);
  border-radius: 22px;
  display: grid;
  gap: 0.6rem;
  padding: 1.1rem 1.2rem 1.3rem;
  position: relative;
}

.aws-compare h3 {
  font-family: "JetBrains Mono", ui-monospace, monospace;
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.16em;
  margin: 0 0 0.35rem;
  text-transform: uppercase;
}

.aws-compare h3.before {
  color: var(--accent);
}

.aws-compare h3.after {
  color: var(--accent-2);
}

.aws-compare .ai-text {
  font-family: "Newsreader", serif;
  font-size: 1.05rem;
  line-height: 1.42;
  margin: 0;
}

.aws-compare .before-card .ai-text {
  color: #7a6750;
  text-decoration: line-through;
  text-decoration-color: rgba(139, 58, 31, 0.5);
  text-decoration-thickness: 1.5px;
}

.aws-compare .before-card {
  position: relative;
}

.aws-compare .ai-trim {
  color: var(--accent);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  position: absolute;
  right: 0.9rem;
  text-transform: uppercase;
  top: 1rem;
  transform: rotate(-6deg);
}

.aws-compare .after-card {
  background: var(--paper);
  border: 1px solid rgba(61, 90, 64, 0.18);
  border-radius: 16px;
  padding: 0.9rem 1rem;
  position: relative;
}

.aws-compare .ai-check {
  color: var(--accent-2);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  position: absolute;
  right: 0.9rem;
  text-transform: uppercase;
  top: 0.8rem;
}

.aws-compare-divider {
  align-items: center;
  align-self: center;
  color: var(--muted);
  display: flex;
  font-family: "JetBrains Mono", monospace;
  font-size: 0.74rem;
  gap: 0.7rem;
  justify-content: flex-start;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.aws-compare-divider::after,
.aws-compare-divider::before {
  background: var(--line);
  content: "";
  flex: 1;
  height: 1px;
}

/* sections */
.aws-section {
  border-top: 1px solid var(--line);
  padding: clamp(2.5rem, 5vw, 4.2rem) clamp(1.5rem, 4vw, 3rem);
}

.aws-section h2 {
  font-size: clamp(1.7rem, 3.5vw, 2.6rem);
  letter-spacing: -0.05em;
  margin: 0 0 0.8rem;
  max-width: 16ch;
}

.aws-section .aws-eyebrow {
  color: var(--accent);
  display: block;
  font-family: "JetBrains Mono", monospace;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.18em;
  margin-bottom: 0.7rem;
  text-transform: uppercase;
}

.aws-section p {
  color: var(--ink-2);
  font-size: 1.05rem;
  line-height: 1.65;
  margin: 0;
  max-width: 56ch;
}

.aws-section.dark {
  background: var(--ink);
  color: var(--paper);
  border-top-color: var(--ink);
}

.aws-section.dark p {
  color: rgba(251, 247, 237, 0.78);
}

.aws-section.dark .aws-eyebrow {
  color: #d7b28b;
}

/* why */
.aws-why {
  display: grid;
  gap: clamp(1.5rem, 4vw, 3rem);
  grid-template-columns: minmax(0, 1.05fr) minmax(0, 0.95fr);
  margin-top: 2.2rem;
}

.aws-tells {
  display: grid;
  gap: 1rem;
}

.aws-tell {
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 1rem 1.1rem;
}

.aws-tell h4 {
  align-items: center;
  display: flex;
  font-family: "JetBrains Mono", monospace;
  font-size: 0.78rem;
  font-weight: 800;
  gap: 0.5rem;
  letter-spacing: 0.14em;
  margin: 0 0 0.4rem;
  text-transform: uppercase;
}

.aws-tell h4 svg {
  flex-shrink: 0;
  height: 1.1rem;
  stroke: var(--accent);
  width: 1.1rem;
}

.aws-tell p {
  font-family: "Newsreader", serif;
  font-size: 0.98rem;
  line-height: 1.45;
  margin: 0;
}

.aws-tell .aws-strike {
  color: #7a6750;
  text-decoration: line-through;
  text-decoration-color: rgba(139, 58, 31, 0.5);
  text-decoration-thickness: 1.5px;
}

.aws-tell .aws-redo {
  color: var(--accent-2);
  display: block;
  font-style: italic;
  margin-top: 0.35rem;
}

.aws-quote-card {
  background: var(--paper);
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 1.7rem 1.8rem;
  position: relative;
}

.aws-quote-card::before {
  color: var(--accent);
  content: "“";
  font-family: "Newsreader", serif;
  font-size: 5rem;
  left: 0.7rem;
  line-height: 0.6;
  position: absolute;
  top: 1.4rem;
}

.aws-quote-card blockquote {
  font-family: "Newsreader", serif;
  font-style: italic;
  font-size: 1.35rem;
  line-height: 1.45;
  margin: 0;
  padding-left: 1.6rem;
}

.aws-quote-card cite {
  display: block;
  font-size: 0.92rem;
  font-style: normal;
  margin-top: 1.1rem;
  padding-left: 1.6rem;
}

.aws-quote-card cite::before {
  content: "— ";
}

/* cards (skills) */
.aws-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  margin-top: 2rem;
}

.aws-card {
  background: rgba(255, 255, 255, 0.62);
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 1.4rem 1.4rem 1.5rem;
  position: relative;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.aws-card:hover {
  box-shadow: 0 24px 40px -22px rgba(26, 20, 12, 0.32);
  transform: translateY(-4px);
}

.aws-card-icon {
  align-items: center;
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid var(--line);
  border-radius: 14px;
  display: inline-flex;
  height: 3rem;
  justify-content: center;
  margin-bottom: 0.9rem;
  width: 3rem;
}

.aws-card-icon svg {
  height: 1.6rem;
  width: 1.6rem;
}

.aws-card h3 {
  font-size: 1.25rem;
  margin: 0;
}

.aws-card .aws-tag {
  color: var(--muted);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.7rem;
  letter-spacing: 0.1em;
  margin: 0.4rem 0 0.7rem;
  text-transform: uppercase;
}

.aws-card p {
  font-size: 0.95rem;
  line-height: 1.55;
  margin: 0;
}

/* 3-pass */
.aws-pass {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  margin-top: 2.2rem;
  position: relative;
}

.aws-pass::before {
  border-top: 1.5px dashed var(--line);
  content: "";
  left: 6%;
  position: absolute;
  right: 6%;
  top: 1.6rem;
  z-index: 0;
}

.aws-pass-step {
  background: var(--paper);
  border: 1px solid var(--line);
  border-radius: 22px;
  padding: 1.6rem 1.5rem 1.7rem;
  position: relative;
  z-index: 1;
}

.aws-pass-num {
  align-items: center;
  background: var(--ink);
  border-radius: 999px;
  color: var(--paper);
  display: inline-flex;
  font-family: "JetBrains Mono", monospace;
  font-size: 0.78rem;
  font-weight: 800;
  height: 2.4rem;
  justify-content: center;
  letter-spacing: 0.1em;
  margin-bottom: 1rem;
  width: 2.4rem;
}

.aws-pass-step h3 {
  font-size: 1.45rem;
  margin: 0 0 0.5rem;
}

.aws-pass-step .aws-sub {
  color: var(--accent);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  margin-bottom: 0.6rem;
  text-transform: uppercase;
}

.aws-pass-step p {
  font-size: 0.96rem;
  line-height: 1.55;
}

.aws-pass-step .aws-metric {
  align-items: baseline;
  display: flex;
  font-family: "JetBrains Mono", monospace;
  gap: 0.4rem;
  margin-top: 1rem;
}

.aws-pass-step .aws-metric strong {
  color: var(--accent);
  font-size: 1.4rem;
  font-weight: 800;
}

.aws-pass-step .aws-metric span {
  color: var(--muted);
  font-size: 0.78rem;
}

/* research */
.aws-research {
  display: grid;
  gap: 0.55rem;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  margin-top: 2rem;
}

.aws-source {
  align-items: center;
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid var(--line);
  border-radius: 14px;
  display: flex;
  gap: 0.7rem;
  padding: 0.75rem 0.9rem;
  transition: transform 0.2s ease;
}

.aws-source:hover {
  transform: translateY(-2px);
}

.aws-source span.year {
  color: var(--accent);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.1em;
  min-width: 3rem;
}

.aws-source small {
  color: var(--ink-2);
  font-size: 0.88rem;
  line-height: 1.2;
}

.aws-source small b {
  display: block;
  font-weight: 700;
}

.aws-source small span {
  color: var(--muted);
  font-size: 0.78rem;
}

/* install */
.aws-install {
  background: var(--code);
  border-radius: 22px;
  color: #e7d9c0;
  font-family: "JetBrains Mono", ui-monospace, monospace;
  font-size: 0.92rem;
  line-height: 1.7;
  margin-top: 2rem;
  overflow: hidden;
}

.aws-install-head {
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  font-size: 0.78rem;
  gap: 0.5rem;
  padding: 0.95rem 1.2rem;
  color: #c2af94;
}

.aws-install-head .aws-dot {
  border-radius: 999px;
  height: 0.7rem;
  width: 0.7rem;
}

.aws-install-head .aws-dot.a { background: #c96b4f; }
.aws-install-head .aws-dot.b { background: #c7a652; }
.aws-install-head .aws-dot.c { background: #6da071; }

.aws-install-body {
  padding: 1.3rem 1.4rem 1.5rem;
}

.aws-install-body .aws-line {
  display: block;
}

.aws-install-body .aws-c {
  color: #6da071;
}

.aws-install-body .aws-p {
  color: #d7b28b;
}

.aws-install-bullets {
  color: rgba(231, 217, 192, 0.7);
  font-family: "Inter", sans-serif;
  font-size: 0.9rem;
  margin: 1.2rem 0 0;
  padding-left: 1.4rem;
}

.aws-install-bullets li + li {
  margin-top: 0.35rem;
}

.aws-install-bullets code {
  background: rgba(255, 255, 255, 0.08);
  border-radius: 4px;
  font-family: inherit;
  padding: 0.05em 0.4em;
}

.aws-cta-row {
  align-items: center;
  display: flex;
  flex-wrap: wrap;
  gap: 0.8rem;
  margin-top: 1.4rem;
}

.aws-button-on-dark {
  background: var(--paper);
  color: var(--ink);
}

.aws-button-on-dark:hover {
  background: #fff;
  transform: translateY(-2px);
}

/* footer */
.aws-footer {
  align-items: center;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem 1.4rem;
  justify-content: space-between;
  padding: 1.5rem clamp(1.5rem, 4vw, 3rem) 1.7rem;
}

.aws-footer small {
  color: rgba(251, 247, 237, 0.7);
  font-family: "JetBrains Mono", monospace;
  font-size: 0.78rem;
}

.aws-footer a {
  color: var(--paper);
  font-weight: 700;
}

/* scroll reveal */
.aws-reveal {
  opacity: 0;
  transform: translateY(28px);
  transition: opacity 0.6s ease, transform 0.7s cubic-bezier(0.2, 0.8, 0.2, 1);
}

.aws-reveal.is-in {
  opacity: 1;
  transform: translateY(0);
}

@media (prefers-reduced-motion: reduce) {
  .aws-reveal {
    opacity: 1;
    transform: none;
    transition: none;
  }
  .aws-button,
  .aws-card,
  .aws-source,
  .aws-pass-step {
    transition: none !important;
  }
}

/* responsive */
@media (max-width: 880px) {
  .aws-hero,
  .aws-why,
  .aws-pass {
    grid-template-columns: 1fr;
  }

  .aws-pass::before {
    display: none;
  }

  .aws-topbar {
    flex-wrap: wrap;
  }

  .aws-nav {
    width: 100%;
    flex-wrap: wrap;
  }

  .aws-compare-divider {
    transform: rotate(0deg);
  }
}

@media (max-width: 560px) {
  .aws-meta-strip {
    font-size: 0.74rem;
  }

  .aws-quote-card blockquote {
    font-size: 1.15rem;
  }
}
</style>

<div class="aws-landing">
  <div class="aws-shell" style="--aws-scroll:0;">
    <div class="aws-progress"></div>

    <header class="aws-topbar" id="aws-topbar">
      <div class="aws-brand">
        <span class="aws-mark" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4 19.5L7.5 16.5C5 14 5 11 7.5 8.5C11 5 16 5 19.5 8.5C22 11 22 14 19.5 16.5L16.5 19.5" />
            <path d="M14.2 9.8L9.8 14.2" />
          </svg>
        </span>
        <span class="aws-mark-name">agents-writing-skills</span>
      </div>
      <nav class="aws-nav" aria-label="primary">
        <a href="skills-overview">Skills</a>
        <a href="knowledge-base">Knowledge</a>
        <a href="getting-started">Install</a>
        <a href="https://github.com/11111000000/agents-writing-skills">GitHub</a>
        <span class="aws-lang" role="navigation" aria-label="language">
          <a href="/" class="is-active">EN</a>
          <a href="/ru/">RU</a>
        </span>
      </nav>
    </header>

    <section class="aws-hero aws-reveal">
      <div>
        <div class="aws-kicker">Agent Skills · 2026 release</div>
        <h1>Skills that make text <span class="aws-pen">less like a model</span>.</h1>
        <p class="aws-lead">Four skills, nine prompts, and a <strong>41-note knowledge base</strong> for agents that write, rewrite, and audit prose with measurable AI-pattern checks.</p>
        <div class="aws-actions">
          <a class="aws-button aws-button-primary" href="getting-started">
            Install skills
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M13 5l7 7-7 7"/></svg>
          </a>
          <a class="aws-button aws-button-secondary" href="knowledge-base">
            Browse knowledge
          </a>
        </div>
        <div class="aws-meta-strip">
          <span><b>4</b> skills</span>
          <span><b>9</b> prompts</span>
          <span><b>12</b> levers</span>
          <span><b>41+</b> knowledge notes</span>
          <span><b>MIT</b></span>
        </div>
      </div>

      <div class="aws-compare" aria-label="before and after">
        <div class="before-card">
          <span class="ai-trim">trim</span>
          <h3 class="before">Before</h3>
          <p class="ai-text">It is worth noting that this comprehensive solution plays a crucial role in improving productivity, ensuring that teams can achieve operational excellence.</p>
        </div>
        <div class="aws-compare-divider">Bench → Tighter rewrite</div>
        <div class="after-card">
          <span class="ai-check">ok</span>
          <h3 class="after">After</h3>
          <p class="ai-text">47 tasks. Three projects. One config in <code>~/.config/genium/tasks.toml</code>.</p>
        </div>
      </div>
    </section>

    <section class="aws-section aws-why aws-reveal">
      <div>
        <span class="aws-eyebrow">What the rewrite does</span>
        <h2>AI text has tells. People notice.</h2>
        <p>Each LLM uses the same repertoire: em-dashes everywhere, the rule-of-three, hedging, negative parallelisms, polite congratulations. Readers spot them at a glance. Detectors flag them in seconds. The four skills collapse that repertoire back into sentences a person would have a reason to write.</p>
      </div>
      <div class="aws-tells">
        <article class="aws-tell">
          <h4>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M3 12h18"/><circle cx="12" cy="12" r="3.5"/></svg>
            Em-dash gravity
          </h4>
          <p><span class="aws-strike">This carefully designed system — built on a foundation of rigorous engineering — delivers value.</span></p>
          <p class="aws-redo">This system ships. p99 14 ms.</p>
        </article>
        <article class="aws-tell">
          <h4>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M4 18l6-6 4 4 6-10"/></svg>
            Restatement chain
          </h4>
          <p><span class="aws-strike">The new release is fast, efficient, and reliable — three qualities that matter.</span></p>
          <p class="aws-redo">p99 14 ms. 99.99% uptime. One binary.</p>
        </article>
        <article class="aws-tell">
          <h4>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M4 12c4 4 12 4 16 0"/><path d="M4 12c4-4 12-4 16 0"/></svg>
            Polite hedging
          </h4>
          <p><span class="aws-strike">Of course, I'd be happy to help with that — let's dive in.</span></p>
          <p class="aws-redo">Tail latency идёт в Postgres → 430 мс. Поставили Redis.</p>
        </article>
      </div>
    </section>

    <section class="aws-section aws-reveal">
      <div style="display:grid;gap:clamp(1.5rem,4vw,3rem);grid-template-columns:1.1fr 0.9fr;align-items:start;">
        <div>
          <span class="aws-eyebrow">From the bench</span>
          <h2>Write less. Trust the reader.</h2>
          <p>The Russian formalist Viktor Shklovsky showed in 1917 that form is what an artist uses to make the familiar strange again. Hemingway, Strunk, Williams all built the same lesson from the American side: trust the reader to fill the gaps, delete what is not needed, and stop at the turn. This repository translates that lesson into rules an agent can run on its own draft.</p>
        </div>
        <div class="aws-quote-card">
          <blockquote>If a writer of prose knows enough of what he is writing about, he may omit things that he knows, and the reader… will have a feeling of those things as strongly as though the writer had stated them.</blockquote>
          <cite>Ernest Hemingway, <em>Death in the Afternoon</em>, 1932</cite>
        </div>
      </div>
    </section>

    <section class="aws-section aws-reveal">
      <div>
        <span class="aws-eyebrow">The four skills</span>
        <h2>An editor, an author, an auditor, and a watchmaker.</h2>
        <p>Each one addresses a different stage of writing with the same vocabulary of measurement. Together they cover the common workflow without dragging in a 1,000-line prompt.</p>
      </div>
      <div class="aws-grid">
        <a class="aws-card" href="skills-overview#humanize-writer">
          <span class="aws-card-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#1a140c" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M5 19l4-1 9-9a2.5 2.5 0 0 0-3.5-3.5l-9 9z"/><path d="M14 6l3 3"/>
            </svg>
          </span>
          <h3>humanize-writer</h3>
          <div class="aws-tag">writer · Levers 1–12</div>
          <p>Drafts a README, an email, or a post. Counts em-dashes, hedges, restatements before the user sees them.</p>
        </a>
        <a class="aws-card" href="skills-overview#humanize-editor">
          <span class="aws-card-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#1a140c" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M6 4l12 12"/><path d="M8 2v2"/><path d="M16 20v2"/><circle cx="7" cy="7" r="2"/><circle cx="17" cy="17" r="2"/>
            </svg>
          </span>
          <h3>humanize-editor</h3>
          <div class="aws-tag">rewriter · Tighten + Iceberg</div>
          <p>Rewrites an AI draft in place. Holds on to every name, number, date, and claim — even after cutting length.</p>
        </a>
        <a class="aws-card" href="skills-overview#anti-ai-auditor">
          <span class="aws-card-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#1a140c" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="6"/><path d="M15 15l4 4"/>
            </svg>
          </span>
          <h3>anti-ai-auditor</h3>
          <div class="aws-tag">diagnostic · no rewrite</div>
          <p>Returns a structured report: per-pattern hit list, density metrics, and concrete priorities. <em>Does not</em> modify the text.</p>
        </a>
        <a class="aws-card" href="skills-overview#ai-pattern-rewriter">
          <span class="aws-card-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#1a140c" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
              <path d="M6 6l4 12 2-6 2 6 4-12"/><path d="M3 21h18"/>
            </svg>
          </span>
          <h3>ai-pattern-rewriter</h3>
          <div class="aws-tag">surgical · single span</div>
          <p>Touches one flagged phrase at a time. Keeps everything else verbatim. Useful when the rest of the document is fine.</p>
        </a>
      </div>
    </section>

    <section class="aws-section aws-reveal">
      <div>
        <span class="aws-eyebrow">How it works</span>
        <h2>Three passes. Same vocabulary.</h2>
        <p>Every skill runs the same loop. Count first. Rewrite second. Verify facts last. The skills differ in what they choose to keep — never in the loop.</p>
      </div>
      <div class="aws-pass">
        <article class="aws-pass-step">
          <span class="aws-pass-num">P1</span>
          <div class="aws-sub">Audit</div>
          <h3>Count the tells.</h3>
          <p>Compute AP, D, E, YapScore, burstiness, specificity, format bias and voice. Numbers, locations, severity.</p>
          <div class="aws-metric">
            <strong>13</strong>
            <span>metrics per pass</span>
          </div>
        </article>
        <article class="aws-pass-step">
          <span class="aws-pass-num">P2</span>
          <div class="aws-sub">Rewrite</div>
          <h3>Apply the 12 levers.</h3>
          <p>STRIP, TIGHTEN, RELY, REBUILD. Per-span preserve-facts check (Lamparth 2026). Russian-only rebuild for short Russian prose.</p>
          <div class="aws-metric">
            <strong>12</strong>
            <span>levers, 4 phases</span>
          </div>
        </article>
        <article class="aws-pass-step">
          <span class="aws-pass-num">P3</span>
          <div class="aws-sub">Verify</div>
          <h3>Hold the facts.</h3>
          <p>Pass 3 compares facts before and after. If 5–10 % of names, dates, numbers, paths disappear, the rewrite is rejected.</p>
          <div class="aws-metric">
            <strong>≤10 %</strong>
            <span>fact-loss budget</span>
          </div>
        </article>
      </div>
    </section>

    <section class="aws-section aws-section-dark aws-reveal">
      <div>
        <span class="aws-eyebrow" style="color:#d7b28b;">Research-grounded, not a vibes check</span>
        <h2>The rules in the skill are not ours.</h2>
        <p>Each lever traces back to a primary source — arXiv for length bias, ACL for detector ceilings, Wikipedia for Russian grammar, the formalists for Russian brevity. We collect, translate, version, and ship. We do not invent new writing theory.</p>
      </div>
      <div class="aws-research">
        <div class="aws-source"><span class="year">2026</span><small><b>YapBench</b><span>76 LLMs over-generate by 1–3×</span></small></div>
        <div class="aws-source"><span class="year">2026</span><small><b>Lamparth</b><span>single-axis mitigation → bias swap</span></small></div>
        <div class="aws-source"><span class="year">2026</span><small><b>MASH (ACL)</b><span>static rewrite, 92 % ASR ceiling</span></small></div>
        <div class="aws-source"><span class="year">2024</span><small><b>Binoculars</b><span>zero-shot detector baseline</span></small></div>
        <div class="aws-source"><span class="year">2024</span><small><b>Zhang</b><span>format bias under 1 % seed</span></small></div>
        <div class="aws-source"><span class="year">1917</span><small><b>Shklovsky</b><span>defamiliarization through form</span></small></div>
        <div class="aws-source"><span class="year">1970</span><small><b>Lotman</b><span>form carries information</span></small></div>
        <div class="aws-source"><span class="year">1984</span><small><b>Gasparov</b><span>measure rhythm, not mood</span></small></div>
      </div>
      <div class="aws-cta-row" style="margin-top:1.8rem;">
        <a class="aws-button aws-button-on-dark" href="knowledge-base">
          Open knowledge base
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M13 5l7 7-7 7"/></svg>
        </a>
        <a class="aws-button aws-button-on-dark" href="limitations">Read the limitations →</a>
      </div>
    </section>

    <section class="aws-section aws-reveal">
      <div>
        <span class="aws-eyebrow">Install</span>
        <h2>One line for the agent. Three files if you copy them yourself.</h2>
        <p>Tell your agent the manifest URL, or copy the directories yourself. Either way, in sixty seconds your agent has all four skills and nine prompts.</p>
      </div>
      <div class="aws-install" role="group">
        <div class="aws-install-head">
          <span class="aws-dot a"></span><span class="aws-dot b"></span><span class="aws-dot c"></span>
          <span>terminal · install one skill</span>
        </div>
        <div class="aws-install-body">
          <span class="aws-line aws-c">$</span> <span class="aws-p">clone</span>
          <span class="aws-line">&nbsp;&nbsp;git clone https://github.com/11111000000/agents-writing-skills.git</span>
          <span class="aws-line aws-c">$</span> <span class="aws-p">cd</span>
          <span class="aws-line">&nbsp;&nbsp;agents-writing-skills</span>
          <span class="aws-line aws-c">$</span> <span class="aws-p">copy</span>
          <span class="aws-line">&nbsp;&nbsp;cp -r skills/humanize-writer       ~/.config/opencode/skills/</span>
          <span class="aws-line">&nbsp;&nbsp;cp -r skills/humanize-editor       ~/.config/opencode/skills/</span>
          <span class="aws-line">&nbsp;&nbsp;cp -r skills/anti-ai-auditor      ~/.config/opencode/skills/</span>
          <span class="aws-line">&nbsp;&nbsp;cp -r skills/ai-pattern-rewriter  ~/.config/opencode/skills/</span>
          <span class="aws-line aws-c">$</span> <span class="aws-p">prompts</span>
          <span class="aws-line">&nbsp;&nbsp;cp prompts/*.md ~/.pi/agent/prompts/</span>
        </div>
      </div>
      <div class="aws-cta-row">
        <a class="aws-button aws-button-primary" href="getting-started">
          Step-by-step
        </a>
        <a class="aws-button aws-button-secondary" href="https://github.com/11111000000/agents-writing-skills/blob/main/manifest.json">
          View manifest.json
        </a>
      </div>
    </section>

    <footer class="aws-footer">
      <small>agents-writing-skills v1.5 · MIT for skills and prompts · CC-BY-SA-4.0 for notes</small>
      <small>
        <a href="https://github.com/11111000000/agents-writing-skills">GitHub</a> ·
        <a href="knowledge-base">Knowledge</a> ·
        <a href="limitations">Limits</a> ·
        <a href="contributing">Contributing</a>
      </small>
    </footer>
  </div>
</div>

<noscript>
  <div class="aws-landing" style="max-width:780px;margin-top:2rem;">
    <div class="aws-shell" style="padding:1.5rem 1.7rem;">
      <h2 style="font-family:Newsreader,serif;font-size:1.6rem;margin:0 0 0.6rem;">Read without JavaScript</h2>
      <p style="margin:0 0 0.6rem;">This landing relies on a small script for scroll reveals and a progress bar. Without JavaScript it still reads top-down; just without those touches.</p>
      <p style="margin:0;">
        Bypass the landing:
        <a href="skills-overview">Skills</a> ·
        <a href="knowledge-base">Knowledge</a> ·
        <a href="getting-started">Install</a> ·
        <a href="/ru/">Русская версия</a> ·
        <a href="https://github.com/11111000000/agents-writing-skills/blob/main/docs/index.md">Source on GitHub</a>
      </p>
    </div>
  </div>
</noscript>

<script>
(function () {
  if (!("IntersectionObserver" in window) && !("requestAnimationFrame" in window)) return;
  var root = document.querySelector(".aws-landing");
  if (!root) return;

  /* scroll progress bar */
  var progress = root.querySelector(".aws-progress");
  var shell = root.querySelector(".aws-shell");
  var topbar = root.querySelector(".aws-topbar");

  function tick() {
    if (!progress || !shell) return;
    var rect = shell.getBoundingClientRect();
    var total = shell.scrollHeight - window.innerHeight;
    var scrolled = Math.min(Math.max(-rect.top, 0), total);
    var ratio = total > 0 ? scrolled / total : 0;
    shell.style.setProperty("--aws-scroll", ratio.toFixed(4));
    if (topbar) {
      if (rect.top < -10) topbar.classList.add("scrolled");
      else topbar.classList.remove("scrolled");
    }
  }

  window.addEventListener("scroll", function () {
    if ("requestAnimationFrame" in window) requestAnimationFrame(tick);
    else tick();
  });
  window.addEventListener("resize", tick);
  tick();

  /* scroll reveal */
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          e.target.classList.add("is-in");
          io.unobserve(e.target);
        }
      });
    }, { rootMargin: "-10% 0px", threshold: 0.08 });
    root.querySelectorAll(".aws-reveal").forEach(function (el) { io.observe(el); });
  } else {
    root.querySelectorAll(".aws-reveal").forEach(function (el) {
      el.classList.add("is-in");
    });
  }
})();
</script>
