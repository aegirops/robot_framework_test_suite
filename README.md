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

Dependencies are managed with [Poetry](https://python-poetry.org/), bound to
the project's existing `.venv` (Python 3.14):

```bash
poetry install
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

Plain `robot` also works if you prefer the standard runner directly:

```bash
poetry run robot tests/
```
