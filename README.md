# Robot Framework - PetStore Test Suite

- https://petstore.swagger.io
- https://petstore.swagger.io/v2/swagger.json

Web service (API) test suite for the Swagger Petstore, written with
[Robot Framework](https://robotframework.org) and
[RequestsLibrary](https://github.com/MarketSquare/robotframework-requests).
Every test calls the live REST API (`pet`, `store`, `user` resources) and
verifies the HTTP response.

## Project layout

```
robot.toml                     # RobotCode/Robot Framework configuration & profiles
pyproject.toml                 # Poetry-managed dependencies (Python 3.14 venv)
tests/
  __init__.robot                # Suite-level setup/teardown: opens/closes the HTTP session
  pet.robot                     # /pet endpoint tests
  store.robot                   # /store endpoint tests (orders, inventory)
  user.robot                    # /user endpoint tests
resources/
  common.resource               # Shared session handling (Base URL, session alias)
  pet_keywords.resource         # Keywords wrapping /pet requests + payload builders
  store_keywords.resource       # Keywords wrapping /store requests + payload builders
  user_keywords.resource        # Keywords wrapping /user requests + payload builders
swagger/
  swagger.json                  # OpenAPI/Swagger spec of the API under test
```

## Setup

Prerequisites: **Python 3.14** (see `.python-version`) and
[Poetry](https://python-poetry.org/) installed on your machine
(`curl -sSL https://install.python-poetry.org | python3 -`, or `brew install poetry`).

### Getting Python 3.14 with pyenv (optional)

If you don't already have Python 3.14 installed, [pyenv](https://github.com/pyenv/pyenv)
picks it up automatically from `.python-version`:

```bash
pyenv install 3.14    # installs the latest 3.14.x if not already present
pyenv local 3.14       # only needed if .python-version isn't already committed
python --version       # -> Python 3.14.x, once pyenv is on your PATH
```

Dependencies are managed with Poetry, bound to a **project-local virtual
environment** (`.venv/`) instead of Poetry's default cache location.

1. **Create the virtual environment** (skip if `.venv/` already exists):

   ```bash
   python3.14 -m venv .venv
   ```

2. **Tell Poetry to use an in-project `.venv` and bind it to that
   interpreter** (`poetry.toml` already commits `virtualenvs.in-project = true`
   for the whole team; this step points Poetry at the actual interpreter):

   ```bash
   poetry env use .venv/bin/python
   ```

3. **Install the dependencies** (main deps: `robotframework`,
   `robotframework-requests`; dev dep: `robotcode`) from the committed
   `poetry.lock`:

   ```bash
   poetry install
   ```

4. **Verify**:

   ```bash
   poetry env info      # should point at ./.venv, Python 3.14.x
   poetry run robotcode discover info
   ```

## Running the tests

Using the [RobotCode](https://robotcode.io) CLI (installed as a dev dependency):

```bash
poetry run robotcode robot                     # run everything (paths come from robot.toml)
poetry run robotcode robot -i smoke            # run only the smoke-tagged tests
poetry run robotcode robot -i pet              # run only the pet-related tests
poetry run robotcode discover tests            # list all tests
poetry run robotcode analyze code              # static analysis (no execution)
```

Results (`log.html`, `report.html`, `output.xml`) are written to `results/`.

Plain `robot` also works, but it does not read `robot.toml` (paths/output-dir),
so pass them explicitly:

```bash
poetry run robot --outputdir results tests/
```
