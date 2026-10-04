# Player Intelligence

**Tier:** Core  
**Primary areas:** Frontend, Backend, Database, AI

## Objective

Display grounded player information, current-match performance, and AI-assisted short analysis.

## Ownership

**Primary Owner:** Member 3 — AI  
**Supporting Owner:** Member 2 — Backend; Member 1 — Fire TV  
**Android Dependency:** None for AI/backend development/testing  
**Development Classification:** Integration  

**Testing Responsibility:** Member 3 owns player reasoning. Member 2 owns player data APIs. Member 1 own the TV player-intelligence UI.

## Architectural Authority

Read `architecture.md` before implementation. This spec is subordinate to the architecture contract and must not introduce incompatible frameworks, storage systems, or service boundaries.

## Dependencies

- `03-match-event-context.md`

## User Experience

The feature must be designed for a television environment:
- readable from viewing distance
- operable using Fire TV remote/D-pad
- clear focused state
- minimal text entry
- no mouse-only or touch-only critical interaction
- graceful loading and error states

## Feature-Specific Contract

Player detail should combine:
- static player metadata
- current-match stats
- relevant events
- optional short AI summary

All factual numbers come from PostgreSQL.

## Frontend Requirements

Where applicable:
- Place feature code under `frontend/firetv-app/src/features/10-player-intelligence/` or a similarly clear feature folder.
- Reuse shared TV focusable primitives.
- Use typed request/response interfaces.
- Keep API calls in the frontend API layer rather than directly inside UI components.
- Expose loading, success, empty, and error states.
- Do not embed backend secrets.
- Avoid feature-specific hacks inside unrelated screens.

## Backend Requirements

Where applicable:
- Add routes under `backend/api/app/api/routes/`.
- Put business logic in services, not route handlers.
- Define Pydantic request/response schemas.
- Validate `match_id`, timestamps, entity IDs, and user inputs.
- Prefer deterministic database queries before AI.
- Return structured errors using the project error convention.
- Log failures without logging secrets.

## Database Requirements

Where applicable:
- Reuse canonical tables defined in `architecture.md`.
- Add migrations only when the existing schema cannot represent the feature.
- Do not create duplicate concepts in new tables.
- Keep sport-specific detail in JSONB until the demo sport is finalized where appropriate.
- Add useful indexes for `match_id`, `timestamp_seconds`, `player_id`, and frequently queried fields.

## AI Requirements

Where applicable:
- Backend retrieves authoritative context first.
- Prompt must clearly state that supplied context is the only factual authority.
- Validate LLM outputs with Pydantic.
- The feature must have a non-hallucinatory failure path.
- Never accept LLM-produced event IDs, scores, player identities, or timestamps unless they are validated against backend data.
- Mock the LLM in automated tests.

## API Contract

Define or update the endpoint(s) needed by this feature. The coding agent must document final request/response schemas in code and keep them stable for dependent features.

Use `/api/v1` as the base prefix.

If no new endpoint is needed, reuse an existing service contract rather than creating a redundant API.

## Error Cases

Handle at minimum:
- match not found
- invalid timestamp or ID
- no relevant data
- backend/network unavailable
- malformed request
- AI unavailable or malformed AI response where applicable
- playback/seek failure where applicable

The app must not crash.

## Testing Requirements

### Backend
- Unit/service test for core logic.
- API test for successful request.
- API test for at least one error case.
- Mock external AI/provider calls.

### Frontend
- Test pure transformation helpers where useful.
- Manually verify D-pad focus.
- Manually verify loading, empty, and error states.
- Manually verify on Android TV emulator.

### Integration
Verify the feature against the seeded demo match.

## Acceptance Criteria

Implementation is complete only when:
1. The core user action works end-to-end.
2. The feature uses authoritative structured match data for factual information.
3. D-pad/remote navigation works for all interactive controls.
4. Loading and error states are visible and recoverable.
5. No secrets are stored in frontend code.
6. Required automated tests pass.
7. The feature works using seeded local demo data.
8. Existing implemented features continue to work.
9. No unrelated architectural rewrite was introduced.

## Files Expected to Change

The exact filenames may vary, but changes should be limited to relevant areas such as:
- `frontend/firetv-app/src/features/...`
- `frontend/firetv-app/src/api/...`
- `frontend/firetv-app/src/types/...`
- `backend/api/app/api/routes/...`
- `backend/api/app/services/...`
- `backend/api/app/schemas/...`
- `backend/api/tests/...`
- `database/...`
- `cv/gesture-service/...` when this feature is CV-related

## Out of Scope

- Replacing the system architecture.
- Building production-scale authentication.
- Building a full live sports ingestion platform.
- Training a large custom ML model unless explicitly required by this spec.
- Adding unrelated features.
- Adding cloud infrastructure solely for architectural elegance.

## Definition of Done

The coding agent must provide:
- implemented code
- any new migrations/seed changes
- tests
- brief notes on API/schema changes
- manual verification steps for Fire TV emulator
- no unresolved TODO that blocks the feature's primary demo path
