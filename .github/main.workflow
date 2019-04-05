workflow "Build JSON From Universe" {
  resolves = ["../action/"]
  on = "push"
}

action "../action/" {
  uses = "./action"
  secrets = [
    "TOKEN",
    "MAILGUN_API_KEY",
  ]
  env = {
    PAGES_BRANCH = "master"
  }
}
