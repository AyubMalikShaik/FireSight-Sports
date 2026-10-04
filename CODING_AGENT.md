# Coding Agent Instructions — FireSight Sports

Before writing code:

1. Read `/architecture.md` completely.
2. Read the requested feature specification in `/docs/specs/`.
3. Read every dependency spec referenced by that feature.
4. Inspect the existing repository and reuse existing patterns.
5. Do not introduce a new framework, database, state-management system, cloud platform, or AI architecture unless explicitly instructed.
6. Do not implement features that were not requested.
7. Keep all match facts grounded in PostgreSQL/structured project data.
8. Never put AI API keys or other secrets in the frontend.
9. Preserve Fire TV D-pad/remote usability.
10. Add tests for backend logic and provide manual Android TV/Fire TV emulator verification steps.

When finishing a feature, report:
- files created/changed
- API changes
- DB/migration changes
- tests run
- manual TV test steps
- remaining limitations
