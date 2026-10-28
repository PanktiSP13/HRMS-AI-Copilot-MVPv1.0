# HRMS AI Copilot

**MVP v1.0 · Phase 1**

HRMS AI Copilot is a cross-platform HRMS application built as the first
working version of the larger product. Phase 1 establishes the core HRMS
foundation with backend-supported leave and policy workflows. The AI copilot
is the next planned phase, not the primary scope of this release.

## MVP scope

This release provides the HRMS base required for day-to-day leave and policy
operations: authenticated access, employee and department context, leave
requests and approvals, and policy document management. The Flutter client is
connected to versioned REST endpoints, so application state is backed by the
HRMS backend rather than limited to UI-only data.

## Tech stack

- **Client:** Flutter and Dart for Android, iOS, Web, and Desktop.
- **State and navigation:** Riverpod, Hooks Riverpod, Flutter Hooks, and
  GoRouter with authentication-aware redirects.
- **Networking and session security:** Dio with JWT bearer-token handling,
  token refresh, and Flutter Secure Storage.
- **Files:** File Picker, Image Picker, Path Provider, and Open FileX.
- **Backend:** FastAPI REST API under `/api/v1` with PostgreSQL.
- **Documents:** Multipart upload and cross-platform PDF download support.

## Application flow

```text
Sign in
  │
  ├── FastAPI authentication API
  ├── Access and refresh tokens stored securely
  └── Authenticated route opens the HRMS shell
           │
           ├── Dashboard and profile context
           ├── Leave workflow
           │     └── request → backend validation → review/status update → refreshed balance
           └── Policy workflow
                 └── browse/manage → upload or download document → backend storage
```

The network layer attaches the access token to authenticated requests. If a
request is unauthorized, it refreshes the session token once and retries the
request; a failed refresh clears the local session.

## Architecture

The client follows a feature-oriented, layered structure:

```text
UI screens
  ↓
Riverpod providers (screen state and actions)
  ↓
Repositories (domain-facing data access)
  ↓
ApiClient / Dio (authentication, retries, HTTP errors)
  ↓
FastAPI `/api/v1`
  ↓
PostgreSQL and document storage
```

```text
lib/
├── common/        Shared UI, theme, utilities, and responsive layout
├── core/          Routing, providers, network client, and secure storage
├── features/      Auth, dashboard, leave, policies, people, and profile screens
├── models/        JSON-serializable domain models
└── repositories/  API-backed data access
```

## Run locally

Requirements: Flutter SDK (Dart `>=3.3.3 <4.0.0`) and a running HRMS FastAPI
backend with PostgreSQL configured.

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

For the Android emulator, use the host alias:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Next phase: AI copilot with RAG

Phase 2 will add an AI copilot backed by Retrieval-Augmented Generation (RAG).
This will allow policy-aware answers grounded in approved HR documents, while
keeping the existing HRMS API and authorization model as the source of truth.


##