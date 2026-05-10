## Astro + Vue Islands — Combo Architecture Rules

These rules extend the base Astro and Vue/Pinia profiles with patterns that only emerge when Vue 3 SFCs are used as Astro islands. Both the `astro` and `vue-pinia` profiles must be installed alongside this combo.

**Island placement rule:** Interactive Vue SFCs live in `src/islands/`, not `src/components/`. Static `.astro` components live in `src/components/`. A `.vue` file in `src/components/` is a violation — it implies it is a static component, which Vue files are not.

**Prop serialization contract:** Props passed from Astro pages to Vue islands must be JSON-serializable. Permitted: strings, numbers, booleans, plain objects, arrays, null. Forbidden: functions, class instances, Dates (convert to ISO string first), Maps, Sets, Symbols, reactive refs. Props are received as `defineProps()` in the SFC — the Composition API applies inside the island.

**Island isolation rule:** Each Vue island is a separate Vue application instance. A Pinia store created in one island is NOT accessible in another island — they run in separate `createApp()` roots, each with their own Pinia instance. Do not attempt to share Pinia state across islands.

**Cross-island state rule:** Reactive state shared between more than one island must use nanostores (`@nanostores/vue`). A nanostore atom is framework-agnostic and persists outside any Vue app boundary. Inside an island, subscribe with `useStore(atom)`. This is the only permitted cross-island state mechanism. Do not use window globals or localStorage polling as a substitute.

**Hydration directive rule:** Apply the least aggressive `client:*` directive:
- `client:visible` — default for below-the-fold interactive islands
- `client:load` — above-the-fold islands that must be interactive on page load
- `client:idle` — islands that enhance but are not critical to initial interaction
- `client:only="vue"` — last resort for islands that cannot SSR; must have a fallback slot or skeleton

Never apply `client:load` by default to all islands.

**Data flow rule:** Islands receive data as props from Astro pages. Islands must not call `$fetch` or `useFetch` for data the server can provide in frontmatter. Async data fetching inside a Vue island is permitted only for user-triggered mutations or real-time updates.

**Vue-specific rules inside islands:** All Vue/Pinia profile rules apply within island SFCs — Composition API only, `<script setup>`, props-in/events-out for child components, no `$fetch` in stores. The island boundary is the limit; inside it, standard Vue 3 conventions hold.
