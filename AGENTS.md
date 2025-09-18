# Repository Guidelines

## Project Structure & Content Organization
- Root `*.qmd` — top-level pages (e.g., `index.qmd`, `about.qmd`).
- Section folders — `posts/`, `postsCN/`, `projects/`, `teaching/`, `presentation/`, `notes/`, etc.; each contains content `*.qmd` and assets.
- Quarto config — `_quarto.yml` (site options), `_publish.yml` (deploy), `_extensions/`.
- Build artifacts — `_site/` (output), `_freeze/` (cached results; keep versioned for reproducibility).
- Assets — `images/`, `assets/`, `fonts/`, `template.html`, `toggle.js`.

## Build, Preview, and Publish
- Preview: `quarto preview` — local server with live reload.
- Render all: `quarto render` — builds site to `_site/`.
- Render page: `quarto render path/to/file.qmd` — single page build.
- Publish: configure `_publish.yml`, then `quarto publish gh-pages` (or desired target).
- R environment: open `website-jihong.Rproj` in RStudio for integrated preview.

## Content & Coding Conventions
- Writing: concise, active voice; American English; headings in Title Case; wrap lines at ~100 chars.
- QMD front matter: include `title`, `description`, `categories`/`tags` when relevant.
- R code chunks: use named chunks and set seeds for reproducibility.
  - Example: 
    ```
    ```{r setup, include=FALSE}
    knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
    set.seed(123)
    ```
    ```
- Assets: reference with relative paths (e.g., `images/plot.png`); keep large data in `assets/`.

## LLM Assistance Guidelines
- Grammar/typo checks: ask for inline edits and retain author voice.
- R help: request minimal, runnable examples and short explanations tied to the page’s goal.
- Verification: execute suggested R code locally; keep data seeds and output stable.
- Citations: if an LLM introduces methods or sources, add references or remove.

## Quality & Review Checklist
- Build passes: `quarto render` completes without warnings; figures/links work.
- Reproducibility: chunks run cleanly; no hidden external state; cache only when necessary.
- Accessibility: provide alt text, semantic headings, and meaningful link text.
- Diff discipline: prefer smaller PRs per section or page.

## Commit & Pull Request Guidelines
- Commits: conventional prefixes — `content:`, `fix:`, `style:`, `refactor:`, `chore:`, `ci:`.
  - Example: `content(posts): add R dplyr join examples`.
- PRs: link issues, summarize changes, note pages affected, include before/after screenshots for UI changes.
- Keep `_quarto.yml` changes isolated and described; update navigation when adding sections.

## Security & Configuration Tips
- Do not commit secrets. Prefer `.Renviron` locally; document needed keys in a non-secret sample.
- Avoid fetching remote data during builds; cache or vendor sample datasets in `assets/`.
