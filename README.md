# HRMS AI Copilot

### MVP v1.0 · Phase 1 — Core HRMS

> A cross-platform Human Resource Management System that brings essential HR operations together in one connected application.

**HRMS AI Copilot** is the first working release of a larger product vision. MVP v1.0 focuses on delivering the core HRMS experience, with Flutter-powered interfaces connected to a FastAPI backend and PostgreSQL database.

The current release is a functional, end-to-end HRMS foundation. The conversational AI Copilot is planned for the next phase and is not an active feature in v1.0.

---

## Product at a glance

MVP v1.0 brings together the essential building blocks of everyday HR operations:

| Area | What it covers |
|---|---|
| **Authentication** | Sign-in, authenticated access, and secure session handling |
| **Dashboard & Profile** | A central landing experience with employee and profile context |
| **Employee & Department Context** | Access to people and organizational information |
| **Leave Management** | Leave requests, backend validation, review/status updates, and balance refresh |
| **Policy Management** | Browse and manage company policy documents, including document upload and download |

The Flutter client communicates with versioned REST API endpoints, so key application workflows are backed by the server rather than relying on UI-only or static data.

## Technology stack

The project uses a cross-platform Flutter client and a Python backend, with a relational database supporting HRMS data.

| Layer | Technology | Role in the project |
|---|---|---|
| **Cross-platform client** | Flutter, Dart | Shared application experience for Android, iOS, Web, and Desktop |
| **State management** | Riverpod, Hooks Riverpod, Flutter Hooks | Application state and UI interaction |
| **Navigation** | GoRouter | Declarative navigation with authentication-aware redirects |
| **Networking** | Dio | REST API communication and HTTP interceptors |
| **Authentication & storage** | JWT, Flutter Secure Storage | Bearer-token handling, refresh flow, and secure local session storage |
| **File handling** | File Picker, Image Picker, Path Provider, Open FileX | Cross-platform file selection and document operations |
| **Backend** | Python, FastAPI | Versioned REST API and backend workflows |
| **Database** | PostgreSQL | Persistent HRMS application data |
| **Document handling** | Multipart upload and PDF download | Policy document exchange between client and backend |

## How the application works

The application follows a client-to-server flow:

```text
User
  │
  ▼
Flutter Application
  │
  ├── Sign-in and authenticated navigation
  ├── Dashboard and profile context
  ├── Leave request and review workflow
  └── Policy document workflow
  │
  ▼
Riverpod State & Repositories
  │
  ▼
Dio API Client
  │
  ▼
FastAPI REST API (/api/v1)
  │
  ▼
PostgreSQL & Document Storage
```

### Session handling

Authenticated requests include the access token. When a request is unauthorized, the networking layer attempts to refresh the session once and retry the request. If refreshing fails, the local session is cleared.

## API documentation

Explore the backend endpoints and interactive API documentation:

**[HRMS API — Swagger UI](https://hrms-api-pankti.onrender.com/docs)**

The API is organized under the `/api/v1` route prefix.

## What's next — AI Copilot (v2.0)

The next planned release will introduce the AI Copilot experience, bringing conversational assistance into the HRMS app backed by Retrieval-Augmented Generation (RAG). This will allow policy-aware answers grounded in approved HR documents, while keeping the existing HRMS API and authorization model as the source of truth.


<img width="700" alt="HRMS AI Copilot MVP Banner" src="https://github.com/user-attachments/assets/7ec143ac-599f-4aea-ac25-d960d74c5145" />

---

**HRMS AI Copilot · MVP v1.0**  
*Core HR operations today. AI-powered HR assistance in the next phase.*
