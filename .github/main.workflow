workflow "New workflow" {
  on = "push"
  resolves = ["../action/"]
}

action "../action/" {
  uses = "./action"
}
