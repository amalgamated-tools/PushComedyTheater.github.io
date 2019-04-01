require "sinatra"
require "json"
require "git"

post "/" do
  # dir = "/tmp/jekyll"
  # username = ENV["GH_USER"] || ""
  # password = ENV["GH_PASS"] || ""
  # url = "https://github.com/PushComedyTheater/PushComedyTheater.github.io.git"
  # url["https://"] = "https://" + username + ":" + password + "@"

  # FileUtils.rm_rf dir
  # puts "cloning into " + url
  # g = Git.clone(url, dir)

  # File.open("#{dir}/blsss.json", "wb") { |file| file.write("{}") }

  # puts "succesfully built; commiting..."
  # begin
  #   g.config("user.name", "Patrick Veverka")
  #   g.config("user.email", "pushbot@veverka.net")
  #   g.add("#{dir}/blsss.json")
  #   puts g.commit_all("[JekyllBot] Building JSON files")
  # rescue Git::GitExecuteError => e
  #   puts e.message
  # else
  #   puts "pushing"
  #   puts g.push
  #   puts "pushed"
  # end
end
