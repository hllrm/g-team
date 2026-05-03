## Vue 3 + Pinia Architecture Rules

**Layer map:**
- `src/views/` — route-level pages; thin orchestration only
- `src/components/` — reusable UI; props in, events out; no store imports
- `src/composables/` — shared logic; accesses stores and services
- `src/stores/` — Pinia setup stores; delegates HTTP to services
- `src/services/` — API calls and data transformation; no store or component imports
- `src/types/` — shared TypeScript interfaces; no runtime logic

**Import direction:** views → components → composables → stores → services. Never upward, never sideways across features.

**State rule:** Global state lives in Pinia stores only. Component-local state uses `ref`/`reactive`. No prop drilling beyond 2 levels.

**Store rule:** Setup store API only (no Options API). Stores call services, never HTTP clients directly.

**SFC rule:** `<script setup lang="ts">` required. Options API is banned in new files.
