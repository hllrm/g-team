## FastAPI Architecture Rules

**Layer map:**
- `app/routers/` — FastAPI route definitions; validate via Pydantic, call services, return schemas; no business logic
- `app/services/` — all business logic; calls repositories; framework-agnostic
- `app/repositories/` — database access only; SQLAlchemy queries; no business logic
- `app/schemas/` — Pydantic request/response models; separate Create and Response schemas
- `app/models/` — SQLAlchemy ORM models only; no Pydantic
- `app/dependencies/` — `Depends()` callables: auth, db session, pagination
- `app/core/` — config, logging, exception handlers; all `os.environ` / settings access goes here
- `app/utils/` — pure utility functions; no FastAPI or DB imports

**Import direction:** routers → services → repositories → models. Schemas and utils are leaves. Core is a leaf. Never upward.

**Schema rule:** Separate Pydantic schemas for request (Create/Update) and response. Never expose password fields in responses. Use `ConfigDict(from_attributes=True)` on ORM-backed response schemas.

**Async rule:** All endpoints doing I/O must be `async def`. DB sessions via `Depends(get_db)` only — never instantiate directly.

**Dependency rule:** Auth, DB session, and pagination go in `app/dependencies/`. Endpoint signatures declare them via `Depends()`. Business logic does not belong in dependencies.
