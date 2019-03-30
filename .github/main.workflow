workflow "New workflow" {
  on = "schedule(0 2 * * *)"
  resolves = ["Filters for GitHub Actions"]
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@3c98a2679187369a2116d4f311568596d3725740"
}
