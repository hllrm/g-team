## Astro + React Islands — Combo Architecture Rules

These rules extend the base Astro and React profiles with patterns that only emerge when React components are used as Astro islands. Both the `astro` and `react` profiles must be installed alongside this combo.

**Island placement rule:** Interactive React components live in `src/islands/`, not `src/components/`. Static `.astro` components live in `src/components/`. The distinction is enforced by directory, not by convention alone — a React file in `src/components/` is a violation.

**Prop serialization contract:** Props passed from Astro pages to React islands must be JSON-serializable. Permitted: strings, numbers, booleans, plain objects, arrays, null. Forbidden: functions, class instances, Dates (convert to ISO string first), Maps, Sets, Symbols. A prop type that cannot survive `JSON.stringify → JSON.parse` will silently fail at runtime.

**Island isolation rule:** React Context does not cross island boundaries. Each React island is a separate React root — a Context.Provider in one island is invisible to all other islands on the page. Do not attempt to share context across islands.

**Cross-island state rule:** Reactive state that must be read or written by more than one island must use nanostores (`@nanostores/react`). Nanostores are framework-agnostic atoms that live outside any island boundary. An island subscribes with `useStore(atom)` — this is the only permitted cross-island state mechanism. Do not use window globals, localStorage polling, or custom events as a substitute.

**Hydration directive rule:** Apply the least aggressive `client:*` directive that meets the use case:
- `client:visible` — default for below-the-fold interactive islands
- `client:load` — above-the-fold islands that must be interactive immediately
- `client:idle` — islands that enhance but are not critical to the initial interaction
- `client:only="react"` — last resort for islands that cannot SSR at all; must have a fallback `<slot>` or skeleton

Never apply `client:load` to every island by default — it defeats Astro's partial hydration model.

**Data flow rule:** Islands receive data as props from Astro pages. Islands must not `fetch()` independently for data the server can provide via frontmatter. `fetch()` in an island is permitted only for user-triggered mutations or real-time updates that cannot be server-rendered.

**React-specific rules inside islands:** All React profile rules apply within island code — hooks, component composition, no business logic in render, etc. The island boundary is the limit; inside it, standard React conventions hold.
