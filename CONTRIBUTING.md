# Contributing to Kiratech Labs

This document outlines the structure, style, and quality requirements for
contributions.

## Repository Structure

The repository contains these kind of content:

- **Training course labs**: each course has its own directory, named after the
  course name (e.g., `Kubernetes-From-Scratch`, `OpenShift-On-The-Rocks`, etc.).
- **Common**: containing general purpose labs, that can be shared between
  different training courses, like
  [Common/Kubernetes-Configure-3-Kind-Clusters-MetalLB.md]().
- **Demo**: containing labs not strictly related to a training course, but
  useful to better understand different topics.
- **Workshops**: all workshops are placed inside the `Workshops` directory, with
  each workshop having its own subdirectory (e.g., `Workshops/ArgoCD`) and their
  `README.md` file.

## Content Format

- All content **must be written in Markdown** (`.md` files).
- The repository uses [a linter](https://github.com/markdownlint/markdownlint)
  to enforce style and formatting.
- Follow Markdown best practices:
  - Use proper headings (`#`, `##`, `###`) in order.
  - Keep lines short (preferably under 120 characters, best is 80).
  - Use fenced code blocks for commands and code snippets:

    ```bash
    echo "Example"
    ```

  - Avoid trailing spaces.
  - Use one blank line between headings, paragraphs, and lists.

## Markdownlint Rules

Below are the main linting rules enforced by this repository:

| Rule | Description |
|------|-------------|
| MD001 | Headings should increment by one level at a time. |
| MD003 | Heading style should be consistent (`#` ATX style). |
| MD004 | Unordered list style should be consistent (`-`). |
| MD009 | No trailing spaces at the end of a line. |
| MD012 | No multiple consecutive blank lines. |
| MD022 | Headings should be surrounded by blank lines. |
| MD025 | A single top-level heading (`# Title`) per document. |
| MD026 | No trailing punctuation in headings. |
| MD031 | Code blocks should be surrounded by blank lines. |
| MD032 | Lists should be surrounded by blank lines. |
| MD040 | Fenced code blocks should use language syntax highlighting. |

You can run `markdownlint` automatically before commit by setting up a
[pre-commit hook](https://pre-commit.com/).

## Lab Requirements

- **Reproducibility** is mandatory:  
  Labs and exercises should work on:
  - Any modern laptop (Linux, macOS, Windows with appropriate tooling).
  - Accessible online environments (e.g., free tier of
    [Google Colab](https://colab.research.google.com/), cloud trial accounts,
    public sandboxes).
  If a lab depends on unavailable, paid, or restricted technologies, it should
  be redesigned.
- **Structure**:  
  A lab typically follows this structure:
  1. **Title** – Clear and descriptive.
  2. **Description** – What the lab is about and its objectives.
  3. **Preparation** – Tools, accounts, or prerequisites needed.
  4. **Execution** – Step-by-step instructions.
  5. **Tests** – How to verify that the lab works as intended.
  6. **Conclusions** – Summary of what was learned.
- **Purpose**:  
  Labs are **not** exams or difficult challenges. They are guided, reproducible
  steps designed to help students understand the topic through hands-on
  practice.

## Commits

Each commit should be associated to a training course or a workshop. This means
that the commit message will be something like:

"[TTLG] Add Grafana instructions to Python test lab"
"[Demo] Remove residual file"
"[BC] Add notes about code coverage"
"[WACD] Make bonus stages not numbered"

The association between training/workshop name and code is:

- **CFS** - *Containers From Scratch*
- **KFS** - *Kubernetes From Scratch*
- **OOTR** - *OpenShift On The Rocks*
- **KO** - *Platforming Kubernetes with Operators*
- **IFS** - *IaC From Scratch*
- **MV** - *Mastering Versioning*
- **MB** - *Mastering Bash*
- **BC** - *Building Castles*
- **TTLG** - *Through The Looking Glass*
- **WAI** - *Artificial Intelligence* (Workshop)
- **WSGL** - *Create secure pipelines in GitLab* (Workshop)
- **WACD** - *Automate K8s deployments with Argo CD* (Workshop)
- **WKHV** - *Protect K8s with HashiCorp Vault* (Workshop)
- **WSTI** - *Use Terraform as an efficient IaC tool* (Workshop)

The only commits that can avoid the course code are the ones related to the
repository in general, like this file, or the main [README.md]().

**Important note**: remember to always put a long description in you commit, so
that other people are able to understand what has been done inside of it.

A good commit message could be something like:

```console
$ git commit -m "[WAI] Restructure folder position" -m "Since the AI stuff is composed by workshop labs, let's put it under Workshops dir."
[academy-ai b41918cb85af] [WAI] Restructure folder position
 35 files changed, 0 insertions(+), 0 deletions(-)
 ...
```

It's a matter of spending nothing more than 2 minutes, and will make life easier
for anyone who will work on the repository.

Remember that you can always use `git commit --amend` to add better descriptions
(under 80 chars per line).

## Contribution Workflow

- **Fork** the repository and create a feature branch.
- Add or update your lab following the guidelines above.
- Run `markdownlint` locally to ensure your files pass style checks.
- Submit a **Pull Request** with:
  - A clear description of the changes.
  - Any special considerations for reviewers.

## Review Process

- A reviewer will verify:
  - Markdown formatting and style.
  - Correct file placement (Training course root directory or `Workshops/`).
  - Reproducibility of steps.
  - Alignment with lab purpose (clear, guided, educational).

Once approved, your changes will be merged into the main branch.

---

If you have any questions, please open an **issue** before starting your
contribution.
