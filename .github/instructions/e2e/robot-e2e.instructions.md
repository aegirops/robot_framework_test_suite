---
description: "Use when writing, reviewing, or fixing Robot Framework test suites (.robot/.resource files, robot.toml) for this project. Covers architecture, keyword design, API testing conventions, and tooling for web service (API) testing with RequestsLibrary."
applyTo: "**/*.robot,**/*.resource,robot.toml"
---

# Robot Framework test suite — best practices

This project is a Robot Framework **API/web-service test suite** for the Swagger
Petstore. It uses `RequestsLibrary` to call the REST API and assert on the
HTTP response. Follow these conventions when adding or changing tests.

## Tooling — use `robotcode`, not raw `robot` or grep

- Run, debug, discover and lint through the **RobotCode CLI** (`poetry run robotcode ...`),
  not by grepping `.robot` files or reading raw `output.xml`. See the `robotcode` skill.
- Before running: `poetry run robotcode analyze code` must be clean (0 errors/warnings).
- To see what exists: `poetry run robotcode discover tests` / `discover suites` / `discover tags`.
- To run one test/suite: select it by **longname** (`-bl "Tests.Pet.Add A New Pet To The Store"`),
  never by pointing at a single `.robot` file (it skips `tests/__init__.robot` setup/teardown).
- After a run: `poetry run robotcode results summary --failed` / `log` — never read `output.xml` directly.
- Dependencies are managed with Poetry (`poetry install`, `poetry add`), venv is the project's own `.venv`.

## Architecture — separate "what" (tests) from "how" (keywords)

```
robot.toml                     # paths, output-dir, variables (BASE_URL), profiles
tests/
  __init__.robot                # Suite Setup/Teardown shared by the whole run
  <resource>.robot               # one suite per API resource/tag (pet, store, user, ...)
resources/
  common.resource                # shared session handling
  <resource>_keywords.resource   # HTTP calls + payload builders for one API resource
```

- One `*** Test Cases ***` file per API resource/tag, mirroring the OpenAPI/Swagger
  `tags` so the suite structure matches the API surface.
- Tests read as a **business-level flow** (`Create Pet`, `Get Pet By Id`, `Status Should Be`).
  Push all HTTP/request/payload mechanics down into `resources/*.resource` keywords.
- Open the HTTP session **once** for the whole run via `Suite Setup`/`Suite Teardown`
  in `tests/__init__.robot` (`Create Petstore Session` / `Delete Petstore Session`),
  instead of creating a session per test or per suite.
- Config (base URL, output dir, profiles) lives in `robot.toml`, not hardcoded in
  `.resource` files or passed as ad-hoc CLI flags. Use `[profiles.*]` for
  environment variants (e.g. `ci`, `debug`).

## Keyword design (`resources/*.resource`)

- One keyword per HTTP operation (`Create Pet`, `Get Order By Id`, `Login User`),
  named after the action, wrapping the matching `RequestsLibrary` `*_On_Session` keyword.
- One payload-builder keyword per resource (`New Pet Payload`, `New Order Payload`,
  `New User Payload`) that returns a ready-to-send dictionary with a unique id —
  never inline a hand-built dict in a test.
- Return the raw `response` object from request keywords (`RETURN ${response}`)
  and assert in the test — keeps keywords reusable for both success and failure paths.
- Build query parameters with `Create Dictionary` + `&{params}`, not hand-built
  query strings.
- Random ids/usernames (`Evaluate ... modules=random`) avoid collisions on a
  shared/public API; never rely on fixed literal ids except where the API mandates
  a fixed range (e.g. Petstore order ids must stay within 1–10).

## Assertions

- For expected 2xx calls, let the implicit `RequestsLibrary` status check do its
  job, and still add an explicit `Status Should Be    200    ${response}` — it
  documents the expectation and keeps the test readable on its own.
- For calls expected to return an error status (404, etc.), pass
  `expected_status=any` on the request keyword so it doesn't raise, then assert
  the real code with `Status Should Be`.
- Assert on parsed JSON fields (`${response.json()}[field]`), not on raw text.
- Prefer `FOR`/`Should Be Equal As Strings` loops over collection assertions to
  keep failures readable (see `Find Pets By Status Returns Only Matching Pets`).

## Tagging

- Tag every suite with `Test Tags` matching its API resource (`pet`, `store`, `user`).
- Tag a representative test per resource with `smoke` so `-i smoke` gives a fast
  sanity run across the whole API.

## Security / hygiene

- Always verify TLS certificates on HTTP sessions (`Create Session ... verify=${True}`)
  — never disable certificate verification to silence warnings.
- Don't commit run artifacts (`results/`, `log.html`, `report.html`, `output.xml`)
  or personal Robot config (`.robot.toml`) — they're in `.gitignore`.
