workflow "New workflow" {
  resolves = ["Deploy to GitHub Pages"]
  on = "push"
}

action "../action/" {
  uses = "./action"
  secrets = ["TOKEN"]
  env = {
    PAGES_BRANCH = "master"
  }
}
