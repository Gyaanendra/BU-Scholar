# Contributing to BU Scholar

Thanks for helping grow the BU Scholar question paper archive! This guide explains how to add new papers so they show up in the app.

## ⚠️ Important

A valid contribution requires **two** things in the same PR:

1. A new entry in [`pyq-data.json`](pyq-data.json) — the manifest the app reads at startup
2. The PDF placed flat in [`pyqs/`](pyqs/) with a filename that matches the entry's `paper_id`

Open the PR against the **`dev`** branch. `main` is the production branch and only receives merges after content is verified — the deployed web app fetches from `main` in production and from `dev` for preview deployments and local development.

## 📋 Table of Contents

- [How the data is structured](#-how-the-data-is-structured)
- [Adding a paper to an existing course](#-adding-a-paper-to-an-existing-course)
- [Same course, different code](#-same-course-different-code)
- [Adding a brand-new course](#-adding-a-brand-new-course)
- [PDF requirements](#-pdf-requirements)
- [PR checklist](#-pr-checklist)
- [Common mistakes](#-common-mistakes)

## 🗂️ How the data is structured

[`pyq-data.json`](pyq-data.json) is the single source of truth. Every course is one object with a list of papers:

```json
{
    "course_num": 19,
    "name": "Microprocessor And Computer Architecture",
    "course_id": ["CSET203"],
    "papers": [
        {
            "paper_name": "End Semester",
            "paper_suffix": "2023",
            "paper_id": "19-1.pdf",
            "paper_num": 1
        }
    ]
}
```

### Field reference

| Field | Type | Description |
|-------|------|-------------|
| `course_num` | int | Globally unique. Prefix for every `paper_id` in this course. |
| `name` | string | Display name in Title Case (e.g. `"Operating Systems"`). |
| `course_id` | string[] | One or more course codes (e.g. `["CSET203"]` or `["CSET211", "CSAI333"]`). Use multiple entries when the same course has been offered under different codes — see [Same course, different code](#-same-course-different-code). Rendered comma-separated in the UI. |
| `paper_name` | string | The category label shown to users. See [accepted values](#accepted-paper_name-values). |
| `paper_suffix` | string | Free-form qualifier rendered after `paper_name`. Use a 4-digit year for exams (`"2024"`), `"Week N"` for assignment series, etc. |
| `paper_id` | string | PDF filename — **must** equal `"<course_num>-<paper_num>.pdf"`. |
| `paper_num` | int | Unique within the course, sequential starting from 1. |

### File layout

PDFs live flat in [`pyqs/`](pyqs/) with no subfolders:

```
pyqs/
├── 1-1.pdf
├── 1-2.pdf
├── 19-1.pdf
├── 19-2.pdf
└── 19-4.pdf   # paper_id "19-4.pdf" in pyq-data.json
```

### Accepted `paper_name` values

Use one of these where applicable. If you have a genuinely new category, add it and mention it in the PR description so we can review:

- `End Semester`
- `Mid Semester`
- `Makeup Examination`
- `Supplementary Examination`
- `NPTEL Assignment`

### Display order

The app sorts papers within a course as follows:
1. Papers whose `paper_suffix` parses as a 4-digit year sort by year **descending** (newest first), then by `paper_name` alphabetically.
2. Papers with non-numeric suffixes (e.g. `"Week 0"`) appear after the year-based papers, sorted by `paper_num` ascending.

So if you're adding a Week series, pick `paper_num` values in the order you want them displayed.

## ➕ Adding a paper to an existing course

Suppose you want to add **Mid Semester 2026** for Operating Systems (`course_num: 23`). The course currently has 2 papers (`paper_num` 1 and 2), so the next free `paper_num` is `3`.

**1.** Add an entry inside that course's `papers` array in `pyq-data.json`:

```json
{
    "paper_name": "Mid Semester",
    "paper_suffix": "2026",
    "paper_id": "23-3.pdf",
    "paper_num": 3
}
```

**2.** Copy your PDF to `pyqs/23-3.pdf` — the filename must equal `paper_id` exactly.

That's it.

## 🔀 Same course, different code

Sometimes the same course is offered under a different code in a later semester (curriculum revision, department reshuffle, cross-listing across programs, etc.). **Don't create a new course entry for this** — that would split the same papers across two cards and confuse search.

Instead, add the new code to the existing course's `course_id` array.

**Example:** Statistical Machine Learning is `CSET211`, and a later batch sees it offered as `CSAI333`. Update the existing course in place:

```diff
 {
     "course_num": 27,
     "name": "Statistical Machine Learning",
-    "course_id": ["CSET211"],
+    "course_id": ["CSET211", "CSAI333"],
     "papers": [ ... ]
 }
```

The card will now render `CSET211, CSAI333` and search will match either code. All existing papers stay attached, and any new papers you add use the same `course_num` (27) regardless of which code the paper was offered under.

### When to add a code vs create a new course

| Scenario | Action |
|---|---|
| Same syllabus and content, just renamed/recoded | Add code to existing course |
| Cross-listed under two codes simultaneously | Add code to existing course |
| Genuinely different course that happens to share a name | Create a new course (see below) |

If you're unsure, mention it in the PR description and a maintainer will help decide.

## 🆕 Adding a brand-new course

1. Pick the next unused `course_num` (look at the highest existing one in `pyq-data.json` and add 1).
2. Add a new course object to the top-level `courses` array.
3. Start `paper_num` at `1`.
4. Drop the PDFs in `pyqs/` using the `<course_num>-<paper_num>.pdf` convention.

Example for `course_num: 29`:

```json
{
    "course_num": 29,
    "name": "Cloud Computing",
    "course_id": ["CSET330"],
    "papers": [
        {
            "paper_name": "End Semester",
            "paper_suffix": "2026",
            "paper_id": "29-1.pdf",
            "paper_num": 1
        }
    ]
}
```

## 📄 PDF requirements

✅ **DO:**
- Use clear, readable scans (or original digital PDFs)
- Ensure pages are properly oriented (no upside-down or sideways scans)
- Keep file sizes reasonable — compress before uploading if needed
- Verify the PDF opens correctly
- Name the file `<course_num>-<paper_num>.pdf` to match the `paper_id`

❌ **DON'T:**
- Upload a PDF without a matching `pyq-data.json` entry (or vice versa)
- Use the old folder structure (`pyqs/<course-name>_CODE/...`) — it's no longer supported
- Submit blurry or unreadable scans
- Upload duplicate papers (check if the entry already exists)

## ✅ PR checklist

Before opening your PR, verify:

- [ ] PR targets the **`dev`** branch
- [ ] Both the JSON entry and the PDF are committed in the same PR
- [ ] Each PDF filename matches its `paper_id` exactly
- [ ] `paper_num` is unique within the course and sequential
- [ ] `paper_id` follows the `<course_num>-<paper_num>.pdf` convention
- [ ] `paper_suffix` is a **string** — note the quotes around year values (`"2024"`, not `2024`)
- [ ] PDFs are flat in `pyqs/` (no subdirectories)
- [ ] No duplicate entries
- [ ] PDFs are readable and properly oriented
- [ ] PR description lists every course and paper added

## ❌ Common mistakes

```
❌ pyqs/operating-systems_CSET209/mid_2024.pdf
   (old folder structure — flat pyqs/ only)

❌ pyqs/Mid_Sem_OS_2024.pdf
   (filename must match paper_id like 23-3.pdf)

❌ { "paper_suffix": 2024 }
   (must be a string: "2024")

❌ Adds 23-3.pdf to the folder but forgets the JSON entry
   (both are required)

❌ Creates a second course entry for the same syllabus under a new code
   (add the code to the existing course's course_id array instead)

✅ pyqs/23-3.pdf  +  matching entry in pyq-data.json
```

## 📞 Support

- Open an issue on GitHub
- Maintainer: M4dhav

Thanks for contributing! 🎓✨
