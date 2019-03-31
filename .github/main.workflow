workflow "New workflow" {
  resolves = ["../action/"]
  on = "fork"
}

action "../action/" {
  uses = "./action"
}
