# FireSight Sports — Architecture Contract

## 1. Purpose

FireSight Sports is an AI-powered interactive sports viewing experience designed for Amazon Fire TV / Fire OS.

The hackathon prototype uses:
- A prerecorded sports match video.
- Structured match/event data owned by the project.
- A PostgreSQL database as the source of truth for events, players, statistics, highlights, rules, and match state.
- A Python FastAPI backend for APIs and AI orchestration.
- A React Native + TypeScript Fire TV client.
- An LLM for natural-language reasoning and presentation.
- A separate OpenCV + MediaPipe service for viewer hand gestures.

The AI does **not** need to understand the match directly from raw video. The structured sports database is the match-understanding layer.

## 2. Architecture Rules

These rules are authoritative.

1. Do not replace React Native, FastAPI, PostgreSQL, or the chosen CV stack without explicit approval.
2. Do not introduce Firebase, MongoDB, Next.js, Supabase, or other major platform substitutions.
3. Do not make the LLM the source of truth for match facts.
4. All match facts must come from structured match/event data.
5. AI responses must be grounded in backend-retrieved structured context.
6. Video synchronization uses `match_id` plus `timestamp_seconds`.
7. All feature behavior must be implemented according to the individual feature specification.
8. Feature specs may not silently change existing API contracts or database semantics.
9. Keep the hackathon implementation simple, deterministic, and demo-reliable.
10. Prefer explicit APIs and typed schemas over implicit cross-component coupling.
11. Do not expose secrets or LLM API keys to the Fire TV client.
12. Do not commit `.env`, private keys, or credentials.
13. Keep sport-specific fields extensible. Until a demo sport is finalized, use generic fields and JSONB metadata where needed.
14. The application must still function at a basic level if the AI provider is unavailable.
15. TV navigation must support D-pad focus and remote operation. Mouse/touch-only interaction is unacceptable.

## 3. System Context

```text
                         ┌─────────────────────┐
                         │       FIRE TV       │
                         │ React Native + TS   │
                         │                     │
                         │ Video Player        │
                         │ Match Context       │
                         │ Highlights          │
                         │ AI UI               │
                         │ Players / Stats     │
                         └──────────┬──────────┘
                                    │
                            REST / WebSocket
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │      FastAPI        │
                         │                     │
                         │ API Layer           │
                         │ Context Service     │
                         │ AI Orchestrator     │
                         │ Highlight Search    │
                         │ Recap / Insights    │
                         └──────┬──────┬───────┘
                                │      │
                  ┌─────────────┘      └─────────────┐
                  ▼                                  ▼
          ┌──────────────┐                   ┌──────────────┐
          │ PostgreSQL   │                   │ LLM Provider │
          │ matches      │                   │ Q&A          │
          │ events       │                   │ insights     │
          │ players      │                   │ recap        │
          │ stats        │                   │ intent parse │
          │ highlights   │                   └──────────────┘
          │ rules        │
          └──────────────┘

Viewer Camera
     │
     ▼
┌──────────────────┐
│ CV Gesture       │
│ OpenCV/MediaPipe │
└────────┬─────────┘
         │ WebSocket / REST
         ▼
      FastAPI
         │
         ▼
      Fire TV
```

## 4. Repository Structure

```text
FireSight-Sports/
├── README.md
├── architecture.md
├── docker-compose.yml
├── .gitignore
├── .env.example
│
├── frontend/
│   └── firetv-app/
│       ├── app/
│       ├── src/
│       │   ├── api/
│       │   ├── components/
│       │   ├── features/
│       │   ├── hooks/
│       │   ├── navigation/
│       │   ├── screens/
│       │   ├── state/
│       │   ├── types/
│       │   └── utils/
│       ├── assets/
│       ├── android/
│       ├── app.json
│       ├── package.json
│       └── tsconfig.json
│
├── backend/
│   └── api/
│       ├── app/
│       │   ├── api/
│       │   │   └── routes/
│       │   ├── core/
│       │   ├── db/
│       │   ├── models/
│       │   ├── schemas/
│       │   ├── services/
│       │   │   ├── ai/
│       │   │   ├── context/
│       │   │   ├── highlights/
│       │   │   └── stats/
│       │   └── main.py
│       ├── tests/
│       └── requirements.txt
│
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   └── migrations/
│
├── cv/
│   └── gesture-service/
│       ├── app/
│       ├── tests/
│       └── requirements.txt
│
├── data/
│   └── sample-match/
│       ├── match.json
│       ├── events.json
│       ├── players.json
│       ├── highlights.json
│       └── README.md
│
└── docs/
    └── specs/
        └── one markdown file per feature
```

## 5. Frontend Architecture

### Technology
- React Native
- TypeScript
- Expo development workflow
- Native Android project generated for Fire TV / Fire OS
- TV-focused navigation and focus management

### Frontend responsibilities
- Render video.
- Track current playback timestamp.
- Display contextual match information.
- Navigate with Fire TV remote/D-pad.
- Display AI answers, insights, recaps, statistics, players, and highlights.
- Send user requests to backend.
- Receive asynchronous commands/events via WebSocket when needed.
- Seek video to timestamp for highlights and smart navigation.

### Frontend must not
- Query PostgreSQL directly.
- Call LLM provider directly.
- Store API secrets.
- Infer match facts independently.

### Suggested state domains
- `playback`
- `match`
- `context`
- `ai`
- `highlights`
- `players`
- `stats`
- `voice`
- `gestures`
- `preferences`

Avoid introducing a heavy global state library unless necessary. Start with React context/hooks or a minimal state solution.

## 6. Backend Architecture

### Technology
- Python 3.x
- FastAPI
- Pydantic
- SQLAlchemy
- PostgreSQL
- REST
- WebSocket where real-time interaction is needed

### Service boundaries

#### Match Service
Retrieves match metadata, score, teams, current phase/state.

#### Event Service
Retrieves events around a video timestamp.

#### Context Service
Builds compact structured context for UI or AI.

#### Highlight Service
Finds important moments and searchable highlights.

#### Player Service
Retrieves player metadata and statistics.

#### Stats Service
Returns match/player statistics and derived comparisons.

#### AI Orchestrator
- Receives user intent.
- Fetches authoritative context from services/database.
- Calls the LLM.
- Validates output.
- Returns presentation-ready response or structured actions.

#### Rule Service
Retrieves sport rule explanations from project-owned rule content.

## 7. Database Model

Core entities:

### matches
- id
- external_id nullable
- title
- sport
- venue nullable
- start_time nullable
- duration_seconds nullable
- home_team_id nullable
- away_team_id nullable
- status
- metadata JSONB

### teams
- id
- name
- short_name nullable
- metadata JSONB

### players
- id
- team_id
- name
- role nullable
- jersey_number nullable
- metadata JSONB

### events
This is the most important synchronization table.

- id
- match_id
- timestamp_seconds
- event_type
- team_id nullable
- player_id nullable
- secondary_player_id nullable
- description
- importance
- metadata JSONB

### highlights
- id
- match_id
- event_id nullable
- timestamp_seconds
- duration_seconds
- title
- description
- importance
- thumbnail_url nullable
- metadata JSONB

### player_stats
- id
- match_id
- player_id
- stats JSONB

### match_stats
- id
- match_id
- team_id nullable
- stats JSONB

### rules
- id
- sport
- rule_key
- title
- explanation
- examples JSONB nullable
- metadata JSONB

### favorites
Prototype/local-user support.
- id
- user_key
- entity_type
- entity_id
- metadata JSONB

## 8. Timestamp Synchronization

The Fire TV client periodically knows:

```json
{
  "match_id": 1,
  "timestamp_seconds": 412
}
```

Backend context query:
- Find recent events before timestamp.
- Find nearby event at timestamp.
- Find next major event when needed.
- Retrieve score/state at or before timestamp.
- Retrieve relevant player/team facts.

Recommended time windows:
- "What just happened?" → previous 15–30 seconds.
- Current context → previous 60 seconds + current state.
- Catch-up → interval between last watched timestamp and current timestamp.
- Next big moment → first future event above importance threshold.

All thresholds must be configurable.

## 9. AI Architecture

### Principle
LLM = reasoning/presentation layer, not data source.

### Pipeline

```text
User request
→ classify/parse intent
→ retrieve authoritative data
→ build structured context
→ LLM
→ validate structured result
→ return answer/action
```

### Example request

User:
`What just happened?`

Backend context:
```json
{
  "match": {...},
  "timestamp_seconds": 412,
  "recent_events": [...],
  "score": {...},
  "relevant_players": [...]
}
```

LLM output:
```json
{
  "answer": "Player X scored after...",
  "related_event_ids": [19],
  "suggested_actions": []
}
```

### Safety/quality constraints
- Never fabricate player names, events, scores, or statistics.
- If context is insufficient, return an explicit insufficient-context response.
- Prefer concise TV-readable output.
- AI calls must be behind backend APIs.
- AI output should be validated with Pydantic schemas.
- For deterministic actions like seeking video, the backend should return structured timestamps, not prose-only instructions.

## 10. API Conventions

Base:
`/api/v1`

Core endpoints may include:

```text
GET  /health
GET  /matches/{match_id}
GET  /matches/{match_id}/context?timestamp_seconds=
GET  /matches/{match_id}/events
GET  /matches/{match_id}/highlights
GET  /matches/{match_id}/stats
GET  /matches/{match_id}/players
GET  /matches/{match_id}/players/{player_id}
POST /matches/{match_id}/ai/ask
POST /matches/{match_id}/ai/insights
POST /matches/{match_id}/ai/recap
POST /matches/{match_id}/highlights/search
GET  /rules
POST /voice/intent
WS   /ws/control
```

Standard success wrapper is optional; consistency matters more than abstraction.

Standard error body:
```json
{
  "error": {
    "code": "MATCH_NOT_FOUND",
    "message": "Match not found",
    "details": null
  }
}
```

## 11. WebSocket Contract

Use WebSocket only where asynchronous commands materially help:
- Gesture service → backend → Fire TV.
- Potential voice/event notifications.
- Key-moment alerts.

Suggested message:

```json
{
  "type": "CONTROL_ACTION",
  "source": "gesture",
  "action": "NEXT_HIGHLIGHT",
  "payload": {},
  "timestamp": "ISO-8601"
}
```

The Fire TV client must validate supported actions before executing them.

## 12. CV Architecture

Pipeline:

```text
Laptop Webcam
→ OpenCV
→ MediaPipe Hands
→ Gesture Classifier
→ Debounce / confidence check
→ Control action
→ WebSocket
→ FastAPI
→ Fire TV
```

Initial supported gestures:
- Open palm → open/activate FireSight overlay.
- Swipe right → next highlight/card.
- Swipe left → previous highlight/card.
- Optional thumbs-up → select/confirm.

Reliability is more important than gesture count.

## 13. Voice Architecture

Prototype pipeline:
```text
Voice input
→ speech-to-text mechanism
→ backend intent parsing
→ deterministic action or AI request
→ Fire TV result
```

Examples:
- "What just happened?"
- "Show me Player X."
- "Compare Player X and Player Y."
- "Show the best highlights."
- "Skip to the next big moment."

A voice request that maps to a deterministic command should not require an LLM response if simple parsing is sufficient.

## 14. Error Handling

Every feature must define:
- Loading state.
- Empty state.
- API failure state.
- Invalid match state.
- AI unavailable state if applicable.
- Retry behavior when reasonable.

The video player must remain usable even if AI features fail.

## 15. Logging

Backend:
- request id
- route
- match id
- user intent type
- AI latency
- database latency where useful
- exceptions

Never log secrets or full API keys.

Frontend:
- development logging only for network failures, playback errors, and unsupported control actions.

## 16. Environment Configuration

Root `.env.example` should document required variables.

Example:

```env
DATABASE_URL=postgresql+psycopg://firesight:firesight@localhost:5432/firesight
AI_PROVIDER=gemini
GEMINI_API_KEY=
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
```

Frontend should have only public/non-secret configuration, for example backend base URL.

## 17. Docker

Prefer Docker Compose for PostgreSQL only at first.

Do not containerize the Fire TV app.

Backend containerization is optional for the hackathon if local Python development is faster.

## 18. Testing Strategy

### Frontend
- Unit-test pure helpers.
- Test focus/navigation logic where feasible.
- Manually verify D-pad behavior on Android TV emulator.
- Manually verify playback/seek.

### Backend
Use pytest.
Test:
- context retrieval around timestamps
- highlight search
- player/stat queries
- AI request validation
- error responses

### AI
Use mocked LLM responses for automated tests.
Do not make tests depend on paid/live AI calls.

### CV
Test gesture classifier mappings separately from camera capture when possible.

## 19. Performance Requirements

Hackathon goals:
- Non-AI API response: target under 500 ms locally.
- UI navigation must feel immediate.
- Seeking to highlight should be deterministic.
- AI latency must show a visible loading state.
- Avoid unnecessary polling; current playback timestamp is local frontend state.

## 20. Security

- Never commit secrets.
- LLM key remains backend-side.
- Validate all input.
- Use parameterized ORM/database access.
- CORS only as needed for development.
- Do not expose database ports publicly.

## 21. Future Production Migration

Hackathon:
```text
Prerecorded video
+ project-owned structured event data
→ PostgreSQL
→ FireSight
```

Production:
```text
Live sports video
+ sports data provider/event feed
→ ingestion/normalization
→ same canonical event model
→ FireSight
```

The presentation, backend service contracts, AI orchestration, and Fire TV UI should remain largely reusable.

## 22. Implementation Order

1. Fire TV shell and D-pad focus
2. Sports video playback
3. Backend skeleton and health API
4. PostgreSQL schema and sample data
5. Match/event context API
6. Highlight timeline
7. Contextual AI Q&A
8. Proactive AI insights
9. Player intelligence
10. Player comparison
11. Interactive stats
12. Natural-language highlight search
13. AI recap
14. Voice
15. Gesture control
16. Smart catch-up
17. Key moment alerts
18. Favorites
19. Predictive/what-if insights
20. Multi-language insights
21. Explain rule
22. Momentum graph
23. Voice skip-to-next-big-moment
24. Share moment

Feature specs define the exact implementation contract.

## 23. Definition of Project-Wide Done

The hackathon demo is ready when:
- Fire TV app launches in TV emulator / target Fire TV.
- D-pad navigation works.
- Demo match video plays.
- Playback timestamp maps to structured events.
- Context screen reflects current match state.
- Highlights can seek to exact timestamps.
- At least the core AI flows are grounded in database context.
- Remote navigation works.
- Voice or gesture input demonstrates multimodal interaction.
- No API keys are embedded in frontend or committed.
- Demo can be started from documented setup instructions.
