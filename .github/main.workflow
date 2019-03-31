workflow "New workflow" {
  resolves = ["../action/"]
  on = "schedule(0 2 * * *)"
}

action "../action/" {
  uses = "./action"
}
