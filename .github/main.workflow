workflow "Build JSON From Push" {
  resolves = ["../action/"]
  on = "push"
}

# workflow "Build JSON From Universe" {
#   resolves = ["../action/"]
#   on = "schedule(0 22 * * *)"
# }

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
