---
name: g-team-specialize
description: Determine which stack profiles to apply by reading the project brief, roadmap, and dependency files. Handles multi-stack projects. Consults code-lead when the picture is ambiguous or risky. Installs architect agents and architecture rules. Supported stacks: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp, claude-plugin.
---

**Announce:** "Using g-team-specialize to apply the stack profile."

You are wiring stack-specific architect agents into this project. The agent files and rules will be project-native after this runs — no plugin dependency required.

## Step 1 — Gather context

Build a picture of the project's stack and integrations from all available sources. Read every source that exists — skip silently if a file is absent.

**Source 1 — project_brief.md (highest confidence)**

Read `project_brief.md` if it exists. Extract:
- The "Tech decisions" table — each row is a confirmed stack component
- The "Technical constraints" section if present
- Any stack names mentioned in the text

Note every distinct runtime/framework/language. A project might have multiple (e.g., Vue 3 frontend + FastAPI backend in a monorepo).

**Source 2 — ROADMAP.md**

Read `ROADMAP.md` if it exists. Look for tech mentions in milestone descriptions or backlog items that indicate planned stack additions not yet in deps.

**Source 3 — Dependency files**

Read whichever of these exist in the current working directory:

- `package.json` — check `dependencies` and `devDependencies`:
  - `vue` + `pinia` → **vue-pinia**
  - `next` → **next-js**
  - `nuxt` → **nuxt**
  - `@sveltejs/kit` → **sveltekit**
  - `@angular/core` → **angular**
  - `astro` → **astro**
  - `@remix-run/react` → **remix**
  - `react-native` or `expo` → **react-native**
  - `react` (no next/remix/native) → **react**
  - `express` → **express**
  - `@nestjs/core` → **nest-js**
  - `hono` → **hono**
  - `elysia` → **bun**
  - `electron` → **electron**
  - `@tauri-apps/api` → **tauri**
  - `@capacitor/core` → **capacitor**
  - `typescript` + (`express` or `fastify` or `koa`) without above → **node-ts**

- `requirements.txt` or `pyproject.toml` — read full contents:
  - `fastapi` → **fastapi**
  - `django` or `djangorestframework` → **django**
  - `flask` → note: flask has no G-Team profile yet
  - `textual` → **python-textual**
  - `click` or `typer` → **python-cli**
  - `torch` or `tensorflow` or `scikit-learn` → **python-ml**
  - `pandas` or `polars` or `sqlalchemy` (no web framework) → **python-data**

- `Cargo.toml` — read full contents:
  - `axum` → **rust-axum**
  - `clap` or `indicatif` or `dialoguer` (no axum) → **rust-cli**
  - `tauri` → **tauri** (Rust side of Tauri project)

- `build.gradle` or `pom.xml` or `build.gradle.kts`:
  - `spring-boot` / `org.springframework.boot` → **spring-boot**
  - `ktor` → **kotlin-ktor**
  - `androidx.compose` → **kotlin-android**

- `*.csproj` or `*.sln`:
  - `Microsoft.AspNetCore` → **asp-net-core**
  - `PresentationFramework` → **wpf-csharp**
  - `Microsoft.Maui` → **maui**

- `pubspec.yaml`:
  - `flutter:` SDK entry → **flutter**

- `CMakeLists.txt` — presence suggests **cpp-cmake**

- `*.gd` files or `project.godot`:
  - GDScript files → **godot-gdscript**
  - C# files in Godot project → **godot-csharp**

- `*.unity` or `Assets/` with `*.cs` files → **unity**

- `*.uproject` → **unreal**

- `Package.swift` with iOS targets → **swift-ios**

- `.claude-plugin/plugin.json` — if this file exists, this is a Claude Code plugin project → **claude-plugin**
- `plugin.json` — if the `$schema` field contains `claude-code-plugin` → **claude-plugin**

**Synthesise:**

After reading all sources, build this picture:
```
Stacks detected:    [list — e.g. vue-pinia, fastapi]
Source confidence:  [brief / deps / roadmap / inferred]
Unsupported stacks: [list — e.g. django]
Conflicts:          [e.g. "brief says Vue 3, no package.json found yet"]
Profiles to apply:  [list of supported stacks to install]
```

## Step 2 — Handle edge cases before confirming

**If an explicit stack argument was provided** (e.g. `/g-team specialize vue-pinia`):
- Validate it is one of the 44 supported stacks listed in the description frontmatter. If not, say: "Unknown stack '[arg]'. Run `/g-team specialize` with no argument to auto-detect, or pick from the supported list." and stop.
- Use this as the confirmed profile list, skipping further detection.

**If no brief and no dependency files exist:**
- Ask the developer: "I couldn't find a project_brief.md or any dependency files. Which profile(s) should I apply? Supported stacks: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp."
- Wait for answer. Use it as the confirmed profile list.

**If unsupported stacks were detected (flask, etc.):**
- Note them in the confirmation: "I detected [stack] which doesn't have a G-Team profile yet. I'll skip that one."

**If the picture is ambiguous or there are conflicts:**

Ambiguous means: stacks detected from different sources that don't agree, or a brief that mentions a stack with no corresponding deps and no clear explanation.

Before asking the user, dispatch `code-lead` with:
- The synthesised picture from Step 1
- The relevant excerpt from project_brief.md (tech decisions table if present)
- The dependency file contents

Ask code-lead:
> "Based on this project's brief and dependencies, which G-Team stack profiles should be applied? The supported profiles are: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp. If the project is multi-stack, list all that apply. Flag anything that looks like a mismatch or a risky stack choice."

Present code-lead's response to the developer: "Here is code-lead's stack read — does this match what you're building?"

**If the brief lists a stack with a code-lead risk flag (Medium or High):**
- Surface it to the developer before proceeding: "code-lead flagged [stack choice] as [risk level]: [reason]. Do you want to proceed with this profile, or reconsider the stack first?"
- Wait for answer. Proceed only after confirmation.

## Step 3 — Confirm with developer

Present the full list of profiles to apply:

```
Based on [brief / deps / your input], I'll apply these profiles:

  • vue-pinia  →  vue-architect agent + Vue 3 + Pinia architecture rules
  • fastapi    →  fastapi-architect agent + FastAPI architecture rules

This will:
  ✦ Write [N] agent file(s) to .claude/agents/
  ✦ Append architecture rules for each stack to CLAUDE.md

Continue? (y/n)
```

Wait for confirmation before writing anything.

## Step 4 — Locate profile files

For each profile to apply:

**Check the current working directory first.** Use Glob to check if `profiles/<stack>/` exists locally:
```
profiles/<stack>/agents/*.md
```

If found, use these local files — this is the correct path when working inside the G-Team plugin repo itself. Skip the plugin cache lookup.

**If not found locally**, use Glob to find the plugin root in the cache:
```
~/.claude/plugins/cache/g-team/g-team/*/skills/g-team-init/SKILL.md
```

The parent of the `skills/` directory is the plugin root. For example, if Glob returns `/home/user/.claude/plugins/cache/g-team/g-team/0.3.3/skills/g-team-init/SKILL.md`, the plugin root is `/home/user/.claude/plugins/cache/g-team/g-team/0.3.3/` and the vue-pinia profile is at `/home/user/.claude/plugins/cache/g-team/g-team/0.3.3/profiles/vue-pinia/`.

If neither the local directory nor the plugin cache contain the profile, tell the developer: "Could not find the profile files for '[stack]'. If this is a new profile, ensure it exists under profiles/<stack>/. Otherwise run `/plugin update g-team` to refresh the cache." and stop.

Stack → file mapping (agent file + rules file):
- `angular`         → `profiles/angular/agents/angular-architect.md`               + `profiles/angular/rules/architecture.md`
- `asp-net-core`    → `profiles/asp-net-core/agents/asp-net-core-architect.md`     + `profiles/asp-net-core/rules/architecture.md`
- `astro`           → `profiles/astro/agents/astro-architect.md`                   + `profiles/astro/rules/architecture.md`
- `bun`             → `profiles/bun/agents/bun-architect.md`                       + `profiles/bun/rules/architecture.md`
- `c-embedded`      → `profiles/c-embedded/agents/c-embedded-architect.md`         + `profiles/c-embedded/rules/architecture.md`
- `capacitor`       → `profiles/capacitor/agents/capacitor-architect.md`           + `profiles/capacitor/rules/architecture.md`
- `cpp-cmake`       → `profiles/cpp-cmake/agents/cpp-cmake-architect.md`           + `profiles/cpp-cmake/rules/architecture.md`
- `django`          → `profiles/django/agents/django-architect.md`                 + `profiles/django/rules/architecture.md`
- `electron`        → `profiles/electron/agents/electron-architect.md`             + `profiles/electron/rules/architecture.md`
- `express`         → `profiles/express/agents/express-architect.md`               + `profiles/express/rules/architecture.md`
- `fastapi`         → `profiles/fastapi/agents/fastapi-architect.md`               + `profiles/fastapi/rules/architecture.md`
- `flutter`         → `profiles/flutter/agents/flutter-architect.md`               + `profiles/flutter/rules/architecture.md`
- `go-fiber`        → `profiles/go-fiber/agents/go-fiber-architect.md`             + `profiles/go-fiber/rules/architecture.md`
- `go-gin`          → `profiles/go-gin/agents/go-gin-architect.md`                 + `profiles/go-gin/rules/architecture.md`
- `godot-csharp`    → `profiles/godot-csharp/agents/godot-csharp-architect.md`     + `profiles/godot-csharp/rules/architecture.md`
- `godot-gdscript`  → `profiles/godot-gdscript/agents/godot-gdscript-architect.md` + `profiles/godot-gdscript/rules/architecture.md`
- `hono`            → `profiles/hono/agents/hono-architect.md`                     + `profiles/hono/rules/architecture.md`
- `kotlin-android`  → `profiles/kotlin-android/agents/kotlin-android-architect.md` + `profiles/kotlin-android/rules/architecture.md`
- `kotlin-ktor`     → `profiles/kotlin-ktor/agents/kotlin-ktor-architect.md`       + `profiles/kotlin-ktor/rules/architecture.md`
- `laravel`         → `profiles/laravel/agents/laravel-architect.md`               + `profiles/laravel/rules/architecture.md`
- `maui`            → `profiles/maui/agents/maui-architect.md`                     + `profiles/maui/rules/architecture.md`
- `nest-js`         → `profiles/nest-js/agents/nest-architect.md`                  + `profiles/nest-js/rules/architecture.md`
- `next-js`         → `profiles/next-js/agents/next-architect.md`                  + `profiles/next-js/rules/architecture.md`
- `node-ts`         → `profiles/node-ts/agents/node-architect.md`                  + `profiles/node-ts/rules/architecture.md`
- `nuxt`            → `profiles/nuxt/agents/nuxt-architect.md`                     + `profiles/nuxt/rules/architecture.md`
- `phoenix-liveview`→ `profiles/phoenix-liveview/agents/phoenix-architect.md`      + `profiles/phoenix-liveview/rules/architecture.md`
- `python-cli`      → `profiles/python-cli/agents/python-cli-architect.md`         + `profiles/python-cli/rules/architecture.md`
- `python-data`     → `profiles/python-data/agents/python-data-architect.md`       + `profiles/python-data/rules/architecture.md`
- `python-ml`       → `profiles/python-ml/agents/python-ml-architect.md`           + `profiles/python-ml/rules/architecture.md`
- `python-textual`  → `profiles/python-textual/agents/python-textual-architect.md` + `profiles/python-textual/rules/architecture.md`
- `rails`           → `profiles/rails/agents/rails-architect.md`                   + `profiles/rails/rules/architecture.md`
- `react`           → `profiles/react/agents/react-architect.md`                   + `profiles/react/rules/architecture.md`
- `react-native`    → `profiles/react-native/agents/react-native-architect.md`     + `profiles/react-native/rules/architecture.md`
- `remix`           → `profiles/remix/agents/remix-architect.md`                   + `profiles/remix/rules/architecture.md`
- `rust-axum`       → `profiles/rust-axum/agents/rust-architect.md`                + `profiles/rust-axum/rules/architecture.md`
- `rust-cli`        → `profiles/rust-cli/agents/rust-cli-architect.md`             + `profiles/rust-cli/rules/architecture.md`
- `spring-boot`     → `profiles/spring-boot/agents/spring-architect.md`            + `profiles/spring-boot/rules/architecture.md`
- `sveltekit`       → `profiles/sveltekit/agents/sveltekit-architect.md`           + `profiles/sveltekit/rules/architecture.md`
- `swift-ios`       → `profiles/swift-ios/agents/swift-ios-architect.md`           + `profiles/swift-ios/rules/architecture.md`
- `tauri`           → `profiles/tauri/agents/tauri-architect.md`                   + `profiles/tauri/rules/architecture.md`
- `unity`           → `profiles/unity/agents/unity-architect.md`                   + `profiles/unity/rules/architecture.md`
- `unreal`          → `profiles/unreal/agents/unreal-architect.md`                 + `profiles/unreal/rules/architecture.md`
- `vue-pinia`       → `profiles/vue-pinia/agents/vue-architect.md`                 + `profiles/vue-pinia/rules/architecture.md`
- `wpf-csharp`      → `profiles/wpf-csharp/agents/wpf-architect.md`               + `profiles/wpf-csharp/rules/architecture.md`
- `claude-plugin`   → `profiles/claude-plugin/agents/claude-plugin-architect.md`   + `profiles/claude-plugin/rules/architecture.md`

Read both files for each profile before writing anything.

## Step 5 — Write agents to .claude/agents/

Create `.claude/agents/` directory if it does not exist.

For each profile:

Write the agent file content to `.claude/agents/[agent-name].md`.

Agent filename: use the filename of the agent file from the stack → file mapping above (e.g. `vue-architect.md`, `fastapi-architect.md`, `react-architect.md`). Write it to `.claude/agents/<filename>`.

If the file already exists, read it first. If the `name:` field in frontmatter matches, tell the developer: "[agent-name] is already installed. Overwrite? (y/n)" and wait for confirmation before proceeding.

## Step 6 — Append architecture rules to CLAUDE.md

Read `CLAUDE.md` in the current project root. If it does not exist, create it with just a `# [Project]` header first.

For each profile, check whether rules are already present by searching for `<!-- G-Team [stack] Architecture Rules -->`. If found, tell the developer: "Architecture rules for [stack] already in CLAUDE.md. Skipping." and skip that profile's rules.

For each profile whose rules are not yet present, append:

```
<!-- G-Team [stack] Architecture Rules — injected by /g-team specialize. Do not edit manually. -->
[full content of profiles/[stack]/rules/architecture.md]
<!-- End G-Team [stack] Architecture Rules -->
```

## Step 7 — Report

```
Stack profiles applied ✓

  ✓ .claude/agents/vue-architect.md    — vue-pinia architect installed
  ✓ .claude/agents/fastapi-architect.md — fastapi architect installed
  ✓ CLAUDE.md — Vue 3 + Pinia architecture rules appended
  ✓ CLAUDE.md — FastAPI architecture rules appended

These agents are now project-native. They will appear in Claude Code's agent list.
Dispatch them during any review or planning task that touches their stack.
```

List only the profiles that were actually applied.

## Rules
- Never write any file before the developer confirms in Step 3.
- Never overwrite an existing agent without user confirmation.
- Profile files are read from the plugin directory — never embedded or hardcoded here.
- If the plugin directory cannot be located, tell the developer the expected path and ask them to verify the plugin is installed.
- code-lead is consulted only when the picture is ambiguous or a brief flags a risky stack choice — not on every run.
- If the developer provides an explicit stack arg, skip all detection and go straight to Step 3.
