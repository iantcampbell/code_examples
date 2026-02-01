# Project Portfolio

## Course Provisioning Automation

Fully automated the semester setup for OnRamps, a UT program offering dual-credit courses to high school students. Replaced a manual process for 150+ courses per semester with an ETL script that read instructor data from a CSV, created courses from templates, assigned instructor roles, published content, and generated enrollment links.

- `onramps.rb`

## Student Assessment & Outcomes Improvement

Led improvements to the UT Math Assessment, which placed incoming students into algebra and calculus course levels. Developed tools to analyze exam timing, grade distributions, and participation patterns. These and other data-driven changes substantially increased first-year student success rates in calculus.

- `utca_exam_time.rb`
- `readiness_atype_data.rb`
- `utca_exam_data.rb`
- `utma_grades.rb`
- `utma_participation.rb`

## Bug Fixes & Production Features

Scripts written to solve specific problems, many of which were refined and incorporated into the production codebase.

- `missing_instances.rb` - detected students missing assignment instances and generated them; incorporated into production
- `give_credit_for_second_answer.rb` - awarded full or partial credit for alternate correct answers on exams; incorporated into production
- `retire_duplicate_modsessions.rb` - resolved duplicate learning module sessions by retaining the highest score; monitoring incorporated into production
- `duplicate_exam_versions.rb` - detected students incorrectly assigned multiple versions of the same exam; monitoring incorporated into production
- `grades_available_dates_2.rb` - caught unreleased grade dates that would exclude assignments from grade reporting; iterated through several versions and incorporated into production
- `c_to_js.rb` - migrated legacy C-language question code to JavaScript
- `find_unit_brackets.rb` - fixed questions broken by nested brackets in unit notation
- `find_dot_notation.rb` - fixed questions broken by a deprecated randomization function
- `fix_math_links.rb` - bulk-updated broken resource links after a server migration
- `move_course_to_current_semester.rb` - migrated courses to current semesters for various operational needs

## Content Quality Improvement

Led a student worker team to audit and clean up physics question explanations. One of the projects focused on cleaning up syntax issues and adding keyword tags for instructors. The other project focused on identifying physics questions solvable with algebra that only included calculus-based explanations, then building tools to parse, categorize, and extract question content at scale.

- `sort_phy_questions.rb`
- `phy_items_logic.rb`
- `phy_choice_logic.rb`
- `ut_items.rb`
- `phy_algebra_questions.rb`
- `phy_calc_explanations.rb`
- `find_vector_notation.rb`
- `onramps_items.rb`

## Data Collection & Monitoring

Reporting and investigative scripts, several of which evolved into self-service dashboards in production.

- `stats_no_bubble.rb` - platform-wide usage statistics across courses, users, and response volumes
- `malicious_script_finder.rb` - detected XSS injection attempts in student essay submissions after an incident was identified
- `onramps_data.rb` - detailed exam response export for OnRamps program; evolved into a self-service CSV dashboard with additional reports
- `upcoming_exams.rb` - tracked upcoming university exams; incorporated into production as a dashboard and shared calendar
- `highschool_instructors.rb` - generated multi-year enrollment trend reports for partner high schools
- `get_incorrect_algfr_answers.rb` - investigated formatting issues in algebraic free-response submissions; led to expanding accepted answer syntax in production
- `find_one_free_try_atypes.rb` - usage research on a new scoring feature
