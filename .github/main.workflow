workflow "Build JSON From Push" {
  resolves = ["../action/"]
  on = "push"
}

workflow "Build JSON From Universe" {
  resolves = ["../action/"]
  on = "schedule(0 22 * * *)"
}

workflow "Build JSON From Universe Morning" {
  resolves = ["../action/"]
  on = "schedule(0 10 * * *)"
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
