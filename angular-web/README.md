# Angular JWT Client (Spring Boot)

Angular 16+ web app that consumes a Spring Boot REST API secured with JWT and role-based authorization.

## Backend

- Base URL: `http://localhost:8080`
- Auth:
	- `POST /api/auth/login` → `{ token, role }`
	- `POST /api/auth/register`
- User profile:
	- `GET/PUT/DELETE /api/users/me`
- Journal:
	- `POST /api/journal/create`
	- `GET /api/journal/all`
	- `PUT/DELETE /api/journal/{id}`
- Admin:
	- `GET /api/admin/users`
	- `PUT /api/admin/users/{id}/role?role=ADMIN|USER`

JWT is stored in `localStorage` and automatically attached to every request as `Authorization: Bearer <token>` by the interceptor.

## App Structure

- `src/app/auth/*` login/register + auth guard/service
- `src/app/core/jwt.interceptor.ts` attaches token + redirects on 401
- `src/app/users/*` profile UI + profile/admin user service
- `src/app/journal/*` emotion entry CRUD
- `src/app/admin/*` admin dashboard + user management
- `src/app/shared/models/*` strong-typed interfaces

## Run

1) Start your Spring Boot backend on `http://localhost:8080`
2) Install deps: `npm install`
3) Start Angular: `npm start`

Open `http://localhost:4200`.

## Notes

- Admin routes/UI are only visible/accessible when role is `ADMIN`.
- The project uses Bootstrap 5 for basic styling.
