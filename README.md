# SueveySparrow

SueveySparrow is an online survey builder and results dashboard with an emphasis on a lightweight, local-first developer experience. This repository (Survey_Sparrow) contains a Vite + React frontend with a small client-side mock API backed by localStorage and optional server-side MySQL initialization for production deployments.

This README covers: features, quick start, environment & scripts, database modes, API reference (client-side), architecture, development tips, and troubleshooting.

---

## Key Features

- Visual survey builder with drag-and-drop question ordering (uses `@dnd-kit`).
- Local-first persistence (localStorage) for rapid development and demos.
- Survey CRUD: create, update, delete, list, and fetch individual surveys.
- Response collection and simple analytics built with `recharts`.
- Optional server-ready DB initialization using `schema.sql` for MySQL.
- Integration-ready for AI features (Gemini) via `@google/genai` — API key used at runtime for AI features.

---

## Quick Start (Local / Development)

Prerequisites

- Node.js (v18+ recommended)
- npm (or pnpm/yarn)

Install dependencies

```bash
npm install
```

Create a local environment file (optional)

- If you plan to use AI features, create `.env.local` and add:

```env
GEMINI_API_KEY=your_gemini_api_key_here
# Optional DB settings if you intend to run MySQL init locally
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=survey_sparrow
```

Run the app

```bash
npm run dev
```

Open http://localhost:5173 (Vite default) and the app will work out of the box using localStorage.

---

## Package Scripts

Scripts in `package.json` (as of this repo):

- `npm run dev` — start Vite dev server
- `npm run build` — build for production
- `npm run preview` — preview the production build
- `npm run init-db` — runs `node scripts/init-db.js` (server-side MySQL initialization)

Use these scripts for typical development and deployment workflows.

---

## Database Modes

This project supports two modes of persistence:

1. Browser / Local Mode (default)

   - The app uses a simple mock database stored in `localStorage` (see `services/api.ts`).
   - This is ideal for local development, demos, and rapid prototyping.

2. MySQL Mode (server deployment)
   - The repository includes `schema.sql` and `services/dbInit.ts` which can create the necessary schema on a MySQL server.
   - To run DB initialization on a host with Node and MySQL access:

```bash
# install MySQL driver if needed
npm install mysql2

# ensure env vars are set (.env or environment)
npm run init-db
```

Notes:

- The DB initializer uses `schema.sql` and expects environment variables (or defaults) defined in `services/dbInit.ts`.
- When running in a browser (local dev), the initializer detects `window` and keeps using localStorage — no remote DB is created.

---

## Client-side API (services/api.ts) — quick reference

The app exposes a small client-side service module (`services/api.ts`) that simulates async API calls (with a delay) and persists to `localStorage`.

Important exported functions (examples):

- Authentication / user

  - `getCurrentUser(): Promise<User>`

- Surveys

  - `getSurveys(): Promise<Survey[]>` — returns all surveys sorted by createdAt desc
  - `getSurvey(id: string): Promise<Survey | undefined>`
  - `createSurvey(surveyData): Promise<Survey>` — create survey (server-like API)
  - `updateSurvey(id, surveyData): Promise<Survey>`
  - `deleteSurvey(id): Promise<void>`

- Users

  - `getUsers(): Promise<User[]>`
  - `addUser(userData): Promise<User>`
  - `updateUser(id, userData): Promise<User>`
  - `deleteUser(id): Promise<void>`

- Responses
  - `getResponses(surveyId?: string): Promise<SurveyResponse[]>`

Implementation notes

- The client API simulates latency with `simulateApi` and deep-copies data before returning to avoid accidental direct mutation of stored data.
- The mock DB is stored under `localStorage` key `surveySparrowDb` and seeded with a default admin user.

If you plan to implement a backend, this module serves as a concise contract of endpoints you can implement server-side.

---

## Types and Data Shapes

Types live in `types.ts` (Survey, User, Question, SurveyResponse, etc.). Basic contracts used by the client API:

- Survey: { id, title, description, createdAt, responsesCount, questions: Question[], ... }
- Question: { id, text, type: QuestionType, options? }
- SurveyResponse: { id, surveyId, answers: { questionId, answer }[], createdAt }

Refer to `types.ts` for exact fields.

---

## Architecture & Folder Structure

Top-level files/folders (high level):

- `index.html`, `index.tsx`, `App.tsx` — React + Vite entry
- `services/` — client services and DB initialization
  - `api.ts` — localStorage-backed mock API used by the frontend
  - `dbInit.ts` — server-side DB initialization helper (reads `schema.sql`)
  - `geminiService.ts` — AI / Gemini integration helpers
- `schema.sql` — SQL schema for server deployment (MySQL)
- `scripts/init-db.js` — lightweight script that calls DB initialization

---

## Development Tips

- Local-first: develop and test using `npm run dev` — the app will use `localStorage` and is reset by clearing localStorage.
- To inspect the mock DB: open DevTools → Application → Local Storage → `surveySparrowDb`.
- If you implement a real backend, keep the client API method names and semantics from `services/api.ts` to maintain compatibility.

AI (Gemini) features

- The project includes `@google/genai` in dependencies. If you enable AI-driven features, set `GEMINI_API_KEY` in `.env.local` or your environment.

---

## Deployment

Typical static-site deployment steps:

1. Build the frontend

```bash
npm run build
```

2. Serve the `dist` contents from a static hosting provider (Netlify, Vercel, S3 + CloudFront, etc.) or with a static server.

Server-backed deployment (optional)

- If you deploy with a Node server and MySQL, ensure `DB_*` env vars are set and run `npm run init-db` to create schema before starting any server that expects the DB.

---

## Troubleshooting

- App doesn't persist data across reloads: verify `localStorage` is enabled and check `surveySparrowDb` in DevTools.
- `init-db` errors: ensure `mysql2` is installed and DB credentials are correct; the initializer will attempt to connect to MySQL and run `schema.sql` using multiple statements.
- Gemini/Ai calls fail: verify `GEMINI_API_KEY` is set and valid.

---

## Contributing

- Fork the repo and open a PR. Keep changes small and focused.
- Add/modify unit or integration tests for new functionality.

Suggested contribution areas:

- Replace client mock API with a real backend (API + DB) while preserving the client contract.
- Add authentication flows and permissions for multi-user setups.
- Add e2e tests using Playwright or Cypress for survey flows.

---

## License & Credits

This project is provided as-is. Add a LICENSE file to specify a license (MIT is common for demos).

Icons and libraries:

- Built with React, Vite, Recharts, @dnd-kit, and lucide-react.

---

If you want, I can:

- Add a short `CONTRIBUTING.md` or `DEVELOPMENT.md` with step-by-step setup for new contributors.
- Convert `services/api.ts` to call a real REST API (create a small Express server) while keeping the current frontend unchanged.

If you'd like either of those, tell me which and I’ll implement it next.
