---
layout: page
title: "Ad-Hoc Analysis: User Segmentation for Partnership Reporting"
subtitle: Defining and quantifying student and graduate segments using multi-table SQL joins
---

## Project Summary

**Context:** A stakeholder needed an estimate of how many *students* and *unemployed graduates* engaged with a specific content partner’s materials for external reporting.

**My role:** Product Analytics Intern (metric definition + data source selection + segmentation logic + results + documentation)

**Turnaround:** ~3 days

> **Confidentiality note:** Company-specific schemas, field names, and internal segmentation implementation are intentionally omitted. The segmentation approach can be demonstrated in interview using mock datasets.

---

## Problem

There was no existing “student” or “unemployed graduate” segment readily available for this request, and user profiles can be incomplete or outdated. The analysis required a defensible definition with clear assumptions and limitations.

Additionally, an age-based request could not be completed because age data is not available in the analytics base.

---

## Approach (High Level)

1. **Clarified definitions & scope**
   - Confirmed what counts as “viewed content”
   - Agreed on conservative segment rules that avoid over-claiming

2. **Identified minimum data needed**
   - Content engagement signals (who viewed the partner content)
   - Education signals (student vs graduate)
   - Workforce signals (unemployed/new-to-workforce)

3. **Built segmentation rules**
   - **Student:** education in-progress + no work history signal
   - **Unemployed Graduate:** education completed + no work history signal + new-to-workforce
   - **Other:** everyone else

4. **Validated**
   - Spot-checked sample profiles and edge cases
   - Ensured segment % reconciled to 100% per reporting row
   - Reviewed outliers (especially low-volume markets)

5. **Delivered results**
   - Country × month breakdown, plus summary table for reporting
   - Included caveats on profile completeness and data freshness

---

## Results (Anonymized & Rounded)

*Note: Values are anonymized and rounded for confidentiality; percentages are recalculated from rounded figures, so totals may not sum to exactly 100.00% due to rounding.*

| Country | Total Content Viewers | Students | Unemployed Graduates | Other | % Students | % Unemployed Grads | % Other |
|---|---:|---:|---:|---:|---:|---:|---:|
| A | 82.5k | 4.8k | 3.5k | 74.2k | 5.82% | 4.24% | 89.94% |
| B | 90k | 13k | 1.5k | 75.5k | 14.44% | 1.67% | 83.89% |
| C | 50k | 7.1k | 4.0k | 38.9k | 14.20% | 8.00% | 77.80% |
| .. | .. | .. | .. | .. | .. | .. | .. |


---

## Deliverables

- Clear metric definitions (with assumptions + limitations)
- Country/month reporting breakdown suitable for external reporting
- Documentation for stakeholder reuse (how segments were defined and validated)

---

## Skills Demonstrated

- Translating ambiguous stakeholder requests into measurable metrics
- Segmentation design with conservative assumptions
- Multi-source analytical thinking (education + workforce + engagement signals)
- Validation and reconciliation checks
- Clear documentation and communication

**Tools:**
- SQL, Databricks, Excel

---

[← Back to Projects](/projects.md)
