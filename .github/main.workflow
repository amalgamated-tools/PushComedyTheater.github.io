workflow "New workflow" {
  resolves = ["Deploy to GitHub Pages"]
  on = "push"
}

# action "../action/" {
#   uses = "./action"
#   secrets = ["TOKEN"]
#   env = {
#     PAGES_BRANCH = "master"
#   }
# }


action "Deploy to GitHub Pages" {
  uses = "maxheld83/ghpages@v0.2.1"
  env = {
    BUILD_DIR = "./"
  }
  secrets = ["GH_PAT"]
}
