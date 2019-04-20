require "open-uri"
require "net/http"
require "uri"
require "json"
require "logger"
require "stringio"
require_relative "parser"

class Runner
  URL = "https://www.universe.com/users/push-comedy-theater-CT01HK/portfolio/current.json"
  LOG_LEVELS = {
    "info" => Logger::INFO,
    "warn" => Logger::WARN,
    "debug" => Logger::DEBUG,
  }
  STRIO = StringIO.new

  LOGGER ||= Logger.new(STRIO).tap do |logger|
    logger.level = LOG_LEVELS[ENV["LOG_LEVEL"]] || LOG_LEVELS["info"]
  end

  def initialize
    @cached_classes = JSON.load(File.read("cached_classes.json"))
    LOGGER.info("Initialized #{@cached_classes.count} cached classes")
    @cached_shows = JSON.load(File.read("cached_shows.json"))
    LOGGER.info("Initialized #{@cached_shows.count} cached shows")

    @classes_json = []
    @shows_json = []
  end

  def run
    doc = JSON.load(open(URL))
    doc["data"]["portfolio"]["hosting"].each do |item|
      parsed = Parser.parse_item(item, LOGGER)
      if parsed[:type] == "class"
        LOGGER.debug("Adding to @cached_classes (current #{@cached_classes.count})")
        @classes_json << parsed
        @cached_classes << parsed
      else
        LOGGER.debug("Adding to @cached_shows (current #{@cached_shows.count})")
        @shows_json << parsed
        @cached_shows << parsed
      end
    end

    uniq_classes = @cached_classes.uniq do |x|
      x["id"]
    end

    uniq_shows = @cached_shows.uniq do |x|
      x["id"]
    end

    LOGGER.info("uniq_classes (total #{uniq_classes.count})")
    LOGGER.info("uniq_shows (total #{uniq_shows.count})")

    File.open("cached_classes.json", "wb") { |file| file.write(JSON.dump(uniq_classes)) }
    File.open("cached_shows.json", "wb") { |file| file.write(JSON.dump(uniq_shows)) }

    File.open("current_classes.json", "wb") { |file| file.write(JSON.dump(@classes_json)) }
    File.open("current_shows.json", "wb") { |file| file.write(JSON.dump(@shows_json.sort_by { |hsh| hsh[:start_stamp] })) }
    return STRIO.string
  end
end

output = Runner.new.run

uri = URI.parse("https://api.mailgun.net/v3/pushcomedytheater.com/messages")
request = Net::HTTP::Post.new(uri)
request.basic_auth("api", ENV["MAILGUN_API_KEY"])

request.set_form_data(
  "from" => "GitHub Actions <mailgun@pushcomedytheater.com>",
  "to" => "patrick@pushcomedytheater.com",
  "subject" => "JSON Updates",
  "text" => output,
)

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
puts response.code
puts response.body
