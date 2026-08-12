---

editor_options: 
  markdown: 
    wrap: 72
---

# Monthly Budget Pipeline

Once a month, the City of Fort Collins requests a breakdown of costs for both projects (PWQN & UCLP). These files are designed to make this process easier and standardized

## Files

| File | Purpose |
|------------------------------------|------------------------------------|
| `00_config.R` | **You shouldn't need to touch this monthly.** File paths, per-project settings. Shared logic (rates, hours, field notes, IDC/totals). Function to create monthly boxplots |
| `01_check_hours.Rmd` | Reconcile logged hours & \$ against Symphony billing, across both projects, before/after editing the xlsx. |
| `02_prep_charges_report_gen.Rmd` | Prep the charges CSV + field-notes CSV for **one** project (set `project_select` at the top). Generate the monthly Word summary for **one** project (set `project_select` at the top). Run once per project. |

## Monthly steps

1.  **Knit `01_check_hours.Rmd`** : Set `month_select`, `year_select`, and paste in this month's Symphony 53-account \$ amounts per person. Check hours-logged-so-far vs. \$ billed. This tells you what's missing from the timeclock sheet.
    - You can also run this before updating the `xlsx` file so that you can get a sense of the \# of billed hours are needed per person
2.  **Update `pwqn_budget_reporting.xlsx`**: (staff_timeclock / equipment_charges / travel sheets) to match.
3.  **Run `01_check_hours.Rmd`**: Confirm `remaining_hours` and `remaining_amount` are \~0 for everyone, and note the previewed `final_totals` (personnel + equipment + travel + IDC) per project.
4.  **`02_prep_charges_report_gen.Rmd`**: Set `project_select, month_select and year_select`, knit. Each project run writes:
    - `.../monthly_budget/charges_final/charges_final_<M>_<Y>.csv`
    - `.../monthly_budget/field_summary/field_summary_<M>_<Y>.csv`
    - Produces the Word doc for each project (fill in the "General Outline of Work" bullets after knitting but before sending).
5.  **Save the Word doc and send to Fort Collins project PI**
    - Save to file formats:
      - PWQN: '.../docs/pwqn/docs/monthly_budget/summaries/budget_summary\_<Y><M>.docx'
      - UCLP: '.../docs/uclp_dss/docs/monthly_budget/summaries/uclp_dss_fc_budget_summary<Y>\_<M>.docx'

<!-- -->

6.  **Update the CSU Invoicing Expenditures spreadsheet** with the final totals from `01_check_hours.Rmd` totals
