# GradyApp

A Rails 7.1 application for composing, reviewing, and publishing assessment content. It includes:
- Authenticated authoring flows for questions (MCQ and open-ended with rubrics)
- A blueprint module to define per-area targets and publish immutable snapshots
- A styleguide and shared UI primitives built on Tailwind v4 + shadcn tokens
- Host-based routing to separate marketing and app domains


## Tech Stack

- Ruby `3.3.0` (`.ruby-version`, Gemfile)
- Rails `~> 7.1.3`
- PostgreSQL (with `pgcrypto` for UUIDs)
- Devise for authentication
- Tailwind CSS v4 via `tailwindcss-rails`
- Design tokens/components via `shadcn-ui` (Rails helpers + ERB partials)
- Hotwire: Turbo + Stimulus with Importmap (no JS bundler)
- Sprockets asset pipeline (CSS compiled builds under `app/assets/builds`)
- Puma web server
- Docker multi-stage image


## Project Structure

- `app/models`: Core domain models (e.g., `Question`, `Blueprint`, rules/snapshots)
- `app/controllers`: RESTful controllers; Devise customization under `app/controllers/users`
- `app/services`: Use-case services (e.g., `QuestionCsvImporter`)
- `app/helpers`: View helpers, design-token helpers, Tailwind class merging
- `app/views/components/ui`: Reusable UI partials (dropdown, popover, tooltip, etc.)
- `app/javascript/controllers`: Stimulus controllers (form wizard, filters, dropdown, sidebar, etc.)
- `config/routes.rb`: Host-based constraints for marketing vs application
- `config/tailwind.config.js`: Tailwind v4 setup, extended via `config/shadcn.tailwind.js`
- `bin/dev`: Foreman-based dev runner (Rails + Tailwind watch)
- `Dockerfile`: Multi-stage build, non-root runtime, precompiled assets


## Features at a Glance

- Question authoring
  - MCQ with exactly five alternatives (A–E), single correct answer
  - Open-ended questions with 5-level rubric and percent mapping
  - Strong validations, defaults, and label helpers in the model
  - CSV import with a downloadable template
- Blueprints
  - Area/component definitions and targets (questions and points)
  - Automatic default rule seeding and validations
  - Publish flow that snapshots to an immutable JSON payload with checksum
- UX & UI
  - Tailwind v4 with shared tokens; helpers normalize Tailwind classes
  - Stimulus controllers for filters, multi-select, dropdowns, tooltips, and wizard flows
  - Self-hosted Inter fonts and accessible component patterns
- Hosting
  - Host-based routing for `www.grady.com.br` (marketing) and `app.grady.com.br` (app)


## Getting Started (Development)

### Prerequisites

- Ruby 3.3.0
- PostgreSQL 14+ (running locally)
- Node is optional; Tailwind plugins are installed via `package.json` but Tailwind is driven by the `tailwindcss-rails` gem

### Setup

```bash
git clone https://github.com/i-abq/GradyApp
cd GradyApp
bin/setup
```

This will install gems, prepare the database (`db:prepare`), and clear logs/tmp.

If you prefer manual steps:

```bash
bundle install
bin/rails db:create db:migrate
```

Seeds are currently optional and empty (`db/seeds.rb`).

### Run the app

Recommended for development (Rails + Tailwind watch):

```bash
bin/dev
```

Or run just Rails:

```bash
bin/rails server
```

### Host-based routing in dev

Routes are constrained by host (see `config/routes.rb`). To exercise the authenticated app flows, add entries to `/etc/hosts` so you can access the app via its subdomains locally:

```
127.0.0.1 app.grady.com.br
127.0.0.1 www.grady.com.br
```

- Marketing root is served under `www.grady.com.br`
- App (auth, questions, blueprints, etc.) is served under `app.grady.com.br`

Note: Dev environment sets default URL options to those hosts. After sign-in/out, Devise will redirect across domains intentionally.


## Environment Variables

Production (and sometimes dev) reads configuration from ENV. Notable variables:

- `MAILER_SENDER` (default: `noreply@grady.com.br`)
- `MAILGUN_SMTP_SERVER`, `MAILGUN_SMTP_PORT`, `MAILGUN_DOMAIN`, `MAILGUN_SMTP_USERNAME`, `MAILGUN_SMTP_PASSWORD`
- `RAILS_MASTER_KEY` (for credentials if required)
- `DATABASE_URL` (production)
- `RAILS_LOG_LEVEL` (default `info`)
- `WEB_CONCURRENCY` (optional, affects Puma workers in production)


## Running Tests

```bash
bin/rails test
```

The repository uses Rails’ default Minitest structure (`test/`). Parallelization is enabled by default.


## Docker

This project ships a production-grade, multi-stage Dockerfile.

Build and run:

```bash
docker build -t gradyapp .
docker run -p 3000:3000 -e RAILS_ENV=production gradyapp
```

Highlights:
- Bootsnap precompilation (gems and app) for faster boot
- Asset precompilation with a dummy `SECRET_KEY_BASE` for build
- Non-root `rails` user at runtime
- Entrypoint runs `db:prepare` before booting Puma


## Conventions & Best Practices (Observed in Code)

- Security & robustness
  - `config.force_ssl = true` in production
  - Parameter filtering of secrets (`config/initializers/filter_parameter_logging.rb`)
  - Host allowlist configuration per environment
  - Devise used with explicit redirects across hosts and safe `allow_other_host`
  - Mail settings sourced from ENV and fail early if not present
  - CSP/Permissions Policy templates available for tightening when ready
- Domain modeling
  - Enumerations defined with string-backed `enum`s for readable persistence
  - Constants for allowed values (e.g., difficulties, levels, letters)
  - Rich validations and labeled helpers on models
  - Default values set in `before_validation` for safer creation flows
  - Numeric precision handled with `BigDecimal` where points/precision matter
  - UUIDs via Postgres `pgcrypto` where stable identifiers are needed
- Controller practices
  - `before_action :authenticate_user!` for protected areas
  - Strong parameters with nested attributes and safe conversions (e.g., booleans)
  - Eager loading (`includes`) to avoid N+1 queries and `scope :ordered`
  - Clean separation of filter preparation, pagination, and post-save branches
- Service objects
  - Encapsulation of CSV import logic into `QuestionCsvImporter` with a `Result` value-object and sample template generation
  - Consistent error collection per row; type coercion and normalization in one place
- View layer
  - Shared UI via ERB partials and helpers; Tailwind classes normalized using `tailwind_merge`
  - Stimulus controllers for interactive components (filters, wizard, dropdown, sidebar)
  - Accessible patterns: proper labels, aria attributes, keyboard interactions (Escape to close, etc.)
- Assets & styling
  - Tailwind v4 via `app/assets/tailwind/application.css` (`@import "tailwindcss"` and plugin directives)
  - Design tokens and component classes in `app/assets/stylesheets/*` and `config/shadcn.tailwind.js`
  - Self-hosted Inter fonts for performance/privacy
- Operations
  - Multi-stage Docker build, non-root runtime, STDOUT logging in production
  - `Procfile`/`Procfile.dev` to align local dev and deploy ergonomics


## CSV Import (Questions)

- Download a ready-made template from the UI (`GET /questions/import_template`).
- Upload via the Import screen (`/questions/import`) with a CSV that follows the headers in the template.
- The importer creates questions row-by-row and reports per-row errors without aborting the entire file.


## Frontend Notes

- Stimulus controllers are eager-loaded via Importmap (`config/importmap.rb`). No bundler is required.
- Some controllers use external libraries via JSPM URLs (e.g., Popper, `stimulus-use`).
- Tailwind tokens and variants are consolidated in helpers to keep markup consistent, with `tailwind-merge` to avoid class conflicts.


## Production Notes

- Force SSL is on; configure your reverse proxy accordingly.
- Assets are precompiled at build time; ensure `RAILS_MASTER_KEY` is available at runtime if your credentials are required.
- Mail delivery is configured for SMTP (Mailgun) and raises on failure.
- Logging goes to STDOUT and is tag-enriched (request_id).


## Roadmap Suggestions (Optional)

These are not present, but commonly added in projects like this:
- Static analysis and formatting (Rubocop + StandardRB)
- CI (e.g., GitHub Actions) to run tests and lint on PRs
- System/integration tests for core flows (authoring, import, publish)
- CSP and Permissions Policy tightened for your final asset/CDN choices
- Rate limiting and lock strategies for auth if needed


## License

Proprietary or TBD. Add a LICENSE file if applicable.
