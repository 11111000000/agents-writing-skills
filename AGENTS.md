<!-- math-coding:begin -->
## math-coding in this project

Редактура текста сохраняет смысл: факты, условия и оговорки не теряются и не выдумываются

12 claim(s).

```sh
mathc run
```

Every verb: mathc help mathc init mathc goal mathc add mathc run mathc map mathc next mathc context mathc waive mathc record mathc install mathc doctor mathc adopt mathc import-adr mathc import-junit mathc authorize mathc re-evaluate mathc review-source mathc mcp
<!-- math-coding:end -->

## Task recording for the Math Coding field pilot

This project takes part in a measurement of the method itself. A task that ends
with a handoff is recorded in the field lab; without that record the pilot has
no data and the method cannot be judged.

At the end of the task, create a draft — the machine fields are filled for you:

```sh
~/Projects/math-coding-field-lab/scripts/record draft agents-writing-skills --kind <kind> --base <revision-at-task-start>
```

Fill the fields marked `TODO`: the model, the time, the counters. Leave `outcome`
as `pending` and `accepted_by` empty — the owner decides the outcome and records
the acceptance, and that is not the agent's call. Then write the record:

```sh
~/Projects/math-coding-field-lab/scripts/record commit agents-writing-skills --task-id <id>
```

Rules: do not choose tasks by their result, do not rewrite a written record to
make it look better, and do not drop unsuccessful ones — the pilot publishes
every outcome. The lab records every task that starts after the declared rule:
it never stops asking and it never filters by result. If the lab is not
available, finish the task as usual: a missing record is a gap in the
measurement, not a reason to change the work.
