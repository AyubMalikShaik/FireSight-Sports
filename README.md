# FireSight Sports Documentation Pack

This pack contains:
- `architecture.md` — authoritative system architecture contract.
- `docs/specs/` — one implementation specification per feature.

Recommended coding-agent workflow:
1. Read `architecture.md`.
2. Read the feature spec to implement.
3. Read all specs listed under that feature's Dependencies section.
4. Inspect existing code before changing files.
5. Implement only the requested feature.
6. Run tests and provide manual Fire TV verification steps.
7. Do not modify architecture unless explicitly instructed.

Important:
- The project deliberately keeps sport-specific fields generic until the demo sport is finalized.
- The LLM is not a source of truth.
- PostgreSQL structured match data is the factual source of truth.
