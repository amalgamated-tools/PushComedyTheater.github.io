require "open-uri"
require "json"
require "logger"
require_relative "parser"

class Runner
  URL = "https://www.universe.com/users/push-comedy-theater-CT01HK/portfolio/current.json"
  LOG_LEVELS = {
    "info" => Logger::INFO,
    "warn" => Logger::WARN,
    "debug" => Logger::DEBUG,
  }
  LOGGER ||= Logger.new(STDOUT).tap do |logger|
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
  end
end

Runner.new.run
