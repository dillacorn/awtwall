# Awtwall Selection-Only Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a selection-only image picker interface to Awtwall for external consumers without changing desktop wallpaper state.

**Architecture:** Extend the existing single-file Awtwall TUI with explicit selection-only state and a result-file output path. Reuse the normal scan/navigation/thumbnail UI, but route the accept action to a pure selection function and suppress display/backend/apply/post-exec controls while selection-only mode is active.

**Tech Stack:** Bash, SIXEL/terminal UI, GitHub Actions shell validation.

**Spec:** `dillacorn/awtarchy:docs/superpowers/specs/2026-09-10-lockscreen-runtime-polish-design.md`

## Global Constraints

- Normal Awtwall behavior is unchanged when `--select-only` is absent.
- `--select-result FILE` is accepted only with `--select-only`.
- Selection-only mode never invokes wallpaper apply backends or mutates desktop/backend/per-output/post-exec state.
- Escape/q cancellation leaves the result absent or empty.
- No release or tag changes.

---

### Task 1: Selection-only regression

**Files:**
- Create: `tests/test-selection-only.sh`
- Modify: none

**Interfaces:**
- Consumes: current `awtwall` CLI and TUI functions.
- Produces: a regression contract for `--select-only`, `--select-result`, pure path acceptance, and backend isolation.

- [ ] **Step 1: Write the failing regression**

Create a shell regression that requires help/parser support for both flags, rejects result-file mode without selection-only, requires a dedicated selection acceptance function, and statically rejects routing that function through wallpaper apply/backend state functions.

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/test-selection-only.sh`
Expected: FAIL because the current Awtwall script has no selection-only interface.

- [ ] **Step 3: Commit the red regression**

Commit message: `test: define selection-only picker contract`

### Task 2: CLI and pure selection path

**Files:**
- Modify: `awtwall`
- Test: `tests/test-selection-only.sh`

**Interfaces:**
- Produces: `SELECTION_ONLY`, `SELECT_RESULT_FILE`, `selection_accept_path <absolute-path>`, and `selection_cancel`.

- [ ] **Step 1: Add parser/help state**

Add `--select-only` and `--select-result FILE`; validate their relationship after argument parsing.

- [ ] **Step 2: Add atomic result writing**

`selection_accept_path` validates that the selected value is an absolute readable file from the scanned library, writes one path plus newline to a temporary file in the destination directory, renames it atomically, prints the path to stdout, marks the UI stopped, and returns without entering the apply path.

- [ ] **Step 3: Route Space/Enter/mouse accept through selection mode**

When selection-only mode is active, the existing selected-file action calls `selection_accept_path` instead of any wallpaper apply function.

- [ ] **Step 4: Route q/Escape through selection cancellation**

Cancellation stops the picker without producing a selected result.

- [ ] **Step 5: Run the focused regression**

Run: `bash tests/test-selection-only.sh`
Expected: PASS.

### Task 3: Selection-only UI isolation

**Files:**
- Modify: `awtwall`
- Test: `tests/test-selection-only.sh`

**Interfaces:**
- Consumes: `SELECTION_ONLY`.
- Produces: selection-only rendering/input that omits display targeting, backend/apply/random/post-exec controls while keeping scan/search/navigation/thumbnails.

- [ ] **Step 1: Gate irrelevant controls and hotkeys**

Hide/disable display selector, backend selection, apply/random actions, transition controls, and post-exec configuration when `SELECTION_ONLY=1`.

- [ ] **Step 2: Preserve image filtering/navigation**

Keep `--type images`, find, paging, mouse navigation, thumbnail generation, and resume behavior available.

- [ ] **Step 3: Re-run focused regression and syntax**

Run: `bash -n awtwall && bash tests/test-selection-only.sh`
Expected: PASS.

### Task 4: Broad validation and test candidate

**Files:**
- Modify only if validation exposes a bug.

- [ ] **Step 1: Run ShellCheck when available**

Run: `shellcheck awtwall tests/test-selection-only.sh` when `shellcheck` exists.

- [ ] **Step 2: Verify exact branch diff and issue contract**

Confirm no normal apply path changed except selection-only guards and that issue #2 requirements are covered.

- [ ] **Step 3: Record exact commit SHA**

Use the final full commit SHA as the Awtwall test candidate; do not publish a release or tag.
