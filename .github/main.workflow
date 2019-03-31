workflow "New workflow" {
  resolves = ["../action/"]
  on = "push"
}

action "../action/" {
  uses = "./action"
}
