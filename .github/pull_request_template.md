## 📚 What's in this PR

### Courses and papers added

List every course and paper this PR adds, one bullet per paper. Use the format
`Course name (COURSECODE) — paper_name paper_suffix → paper_id`.

**Example:**
- Operating Systems (CSET209) — Mid Semester 2026 → `pyqs/23-3.pdf`
- Cloud Computing (CSET330, NEW course) — End Semester 2026 → `pyqs/29-1.pdf`
- Microprocessor And Computer Architecture (CSET203) — NPTEL Assignment Week 13 → `pyqs/19-17.pdf`

**Your additions:**
- 

---

## ✅ Pre-submission checklist

Verify ALL of the following before submitting:

### Branch
- [ ] This PR is opened against the **`dev`** branch (not `main`)

### `pyq-data.json` entry
- [ ] Added a JSON entry for every PDF in this PR
- [ ] `paper_id` matches the PDF filename exactly
- [ ] `paper_num` is unique within the course and sequential
- [ ] `paper_suffix` is a **quoted string** (e.g. `"2024"`, `"Week 0"`, never `2024` as int)
- [ ] For a new course: picked an unused `course_num`

### PDF files
- [ ] Each PDF is flat in `pyqs/` (no subdirectories)
- [ ] Filename follows the `<course_num>-<paper_num>.pdf` convention
- [ ] PDFs open correctly without errors
- [ ] Scans are readable and properly oriented
- [ ] PDFs are from Bennett University

### Quality
- [ ] No duplicates of existing entries
- [ ] Course code matches the current curriculum

---

## 📝 Additional notes

(Optional) Anything reviewers should know — new `paper_name` category, unusual course numbering, etc.

---

## ⚠️ Important reminder

PRs that add a PDF without the matching `pyq-data.json` entry — or add an entry without the PDF — will not be accepted. See [CONTRIBUTIONS.md](../CONTRIBUTIONS.md) for the full data model and walkthroughs.

Thank you for contributing to BU Scholar! 🎓✨
