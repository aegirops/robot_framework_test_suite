# How this repository was built with AI

This document explains **how** this repository was created, the **methodology**
followed during the AI-assisted session(s), and the concrete **division of
labor** between the human operator and the AI coding agent (GitHub Copilot /
Claude Sonnet 4.5 in VS Code's agent mode). It is meant as a transparency
record for a training project, so anyone reviewing the repo understands what
was generated, what was decided by a human, and what should still be reviewed.

## Starting point

The repository started nearly empty: a `README.md` with two links (Swagger
Petstore site + its OpenAPI spec) and an empty `swagger/` folder, plus a
pre-existing Python 3.14 virtual environment (`.venv`, `.python-version`) with
nothing installed in it. There was no Robot Framework code, no dependency
manifest, and two empty instruction files under `.github/instructions/`.

## Methodology

The project was built through an **iterative, conversational workflow** with
the AI agent, not a single one-shot generation:

1. **State the goal, not the implementation.** The operator described the
   intent ("learn Robot Framework by testing the Petstore API, use Python 3.14
   already in the venv, latest compatible Robot Framework, follow best
   practices") and let the agent figure out the concrete architecture.
2. **Agent grounds itself before writing code.** Before generating anything,
   the agent inspected the real repository state (existing files, venv Python
   version, installed packages) instead of assuming, and pulled in the
   project-specific **`robotcode` skill** (bundled with the RobotCode VS Code
   extension) as the authoritative source for Robot Framework tooling,
   configuration (`robot.toml`) and conventions, rather than relying purely on
   generic/pretrained knowledge.
3. **Agent asks before making structural decisions.** Whenever a choice would
   materially shape the project (dependency manager, HTTP testing library,
   whether to install extra CLI tooling as a shared/team dependency), the
   agent paused and asked the operator explicit multiple-choice questions
   instead of silently picking a default.
4. **Verify library/keyword facts instead of guessing.** For Robot Framework
   keyword signatures (e.g. `RequestsLibrary`'s `GET On Session`,
   `Status Should Be`, `Create Session`), the agent queried `robotcode libdoc`
   against the actually-installed library version rather than recalling
   arguments from memory — the same "fact-grounded" principle applied
   consistently.
5. **Validate continuously, against the real target.** After scaffolding the
   suite, the agent ran static analysis (`robotcode analyze code`), suite
   discovery (`robotcode discover tests`), and then executed the tests for
   real against the live public Petstore API — catching and fixing an actual
   assertion bug and an insecure TLS-verification default this way, rather
   than trusting the code to be correct just because it "looked right".
6. **Human reviews and steers between iterations.** After the initial
   scaffold, the operator reviewed the result in the editor, made small
   manual/tooling edits (e.g. Poetry re-normalized `pyproject.toml`, a
   `.gitignore` tweak), and issued follow-up, narrowly-scoped requests
   (fill in the instructions file, fix the `.gitignore`) which the agent
   picked up by first re-reading the current file contents (never assuming
   its previous edits were still the latest state).
7. **Persist reusable knowledge, not just code.** Conventions that emerged
   during the session (architecture, tagging scheme, security choices) were
   written back both as project documentation (`README.md`,
   `.github/instructions/e2e/robot-e2e.instructions.md`) and as the agent's
   own repository-scoped memory, so future sessions on this repo stay
   consistent without re-deriving the same decisions.

## Step-by-step narrative

1. **Discovery.** Read the empty instruction files, the existing `README.md`,
   listed the workspace, confirmed the `.venv` was Python 3.14.3 with no
   packages installed.
2. **API contract.** The agent needed the Petstore OpenAPI contract to design
   realistic tests; the operator supplied the local `swagger/swagger.json`
   directly instead of letting the agent fetch it from the internet.
3. **Clarify scope with the operator.** Three quick multiple-choice questions
   were asked and answered:
   - Dependency management → **Poetry**, reusing the existing `.venv`
     (`poetry config virtualenvs.in-project true --local` +
     `poetry env use .venv/bin/python`).
   - HTTP client → **RequestsLibrary** (the community-standard Robot Framework
     wrapper around `requests`), over the more "black-box" OpenAPI-driven
     alternative, to keep the hand-written-keyword learning value.
   - Tooling → install **`robotcode[runner,analyze,repl]`** as a Poetry **dev
     dependency** so the whole team gets the CLI used for running, debugging
     and linting the suite.
4. **Scaffold the architecture** (see `README.md` → _Project layout_ for the
   current tree): `robot.toml` for configuration/profiles, `tests/__init__.robot`
   for a single shared HTTP session (`Suite Setup`/`Suite Teardown`), one test
   suite per Swagger tag (`pet.robot`, `store.robot`, `user.robot`), and one
   `resources/*_keywords.resource` file per API resource wrapping the HTTP
   calls and building request payloads (with randomized ids/usernames to avoid
   collisions on the shared public demo server).
5. **Validate against reality.**
   - `robotcode analyze code` → found and fixed a duplicate library import.
   - `robotcode robot` (full run against `https://petstore.swagger.io/v2`) →
     15/16 passed; one real bug found (asserting on the whole login JSON
     response instead of its `message` field) and fixed, then re-verified.
   - Noticed `RequestsLibrary` defaults to `verify=False`; changed the shared
     session keyword to `verify=${True}` so TLS certificates are actually
     checked (an OWASP-relevant fix, not just a style choice).
6. **Documentation & housekeeping.**
   - Wrote the _Project layout_, _Setup_ and _Running the tests_ sections of
     `README.md`.
   - Filled `.github/instructions/e2e/robot-e2e.instructions.md` with the
     concrete conventions the suite follows (tooling via `robotcode`, the
     tests/resources split, keyword design rules, assertion patterns, tagging,
     TLS/hygiene rules) so both the agent and human contributors have a single
     source of truth for future changes.
   - Found and removed `log.html` / `output.xml` / `report.html` that had been
     accidentally committed at the repo root (produced by a plain `robot`
     invocation that ignores `robot.toml`'s `output-dir`), and fixed the
     README snippet that suggested that command.
   - Tightened an over-broad `*.html` / `*.xml` `.gitignore` pattern (added by
     an external edit) down to the specific Robot Framework artifact names, so
     unrelated future HTML/XML files in the repo aren't silently ignored.

## Who did what

| Responsibility                                                                                  | Human operator | AI agent                                      |
| ----------------------------------------------------------------------------------------------- | -------------- | --------------------------------------------- |
| Define the goal & constraints (learn RF, test the Petstore API, Python 3.14, "best practices")  | ✅             |                                               |
| Choose dependency manager, HTTP library, tooling scope                                          | ✅ (decided)   | ✅ (asked the question, presented trade-offs) |
| Explore the repo/environment state before acting                                                |                | ✅                                            |
| Design the test architecture (suite/resource split, session lifecycle, tagging)                 |                | ✅ (proposed & implemented)                   |
| Verify keyword signatures against the installed library (`libdoc`) instead of guessing          |                | ✅                                            |
| Write all `.robot` / `.resource` / `robot.toml` / config files                                  |                | ✅                                            |
| Run the suite against the real API and fix failures/security defaults found                     |                | ✅                                            |
| Review generated files, trigger follow-up/refinement requests                                   | ✅             |                                               |
| Provide the OpenAPI spec used to design the tests                                               | ✅             |                                               |
| Keep documentation (`README.md`, instructions file, this file) in sync with the real repo state |                | ✅ (on request)                               |

## What to keep in mind

This suite was generated by an AI agent and **validated by actually running it
against the live Petstore demo API** — it is not speculative code. That said,
as with any AI-assisted contribution, a human should still review new
Robot Framework changes going forward (e.g. via `robotcode analyze code` and a
real test run) before trusting them, since the demo API's behavior on edge
cases (invalid ids, validation errors) is not always exactly what the Swagger
spec formally promises.
