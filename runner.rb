require "bundler/setup"
require "rubygems"
# require "nokogiri"
require "open-uri"
require "oj"
# require "action_view"
# require "pp"
require "logger"
# require "highline/import"
# require 'highline'
require "digest/sha1"
# require "benchmark"
# require 'pry'
# require "colorize"
require_relative "parser"
# require_relative "writer"

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
    @cached_classes = Oj.load(File.read("cached_classes.json"))
    LOGGER.info("Initialized #{@cached_classes.count} cached classes")
    @cached_shows = Oj.load(File.read("cached_shows.json"))
    LOGGER.info("Initialized #{@cached_shows.count} cached shows")

    @classes_json = []
    @shows_json = []
  end

  def run
    doc = Oj.load(open(URL))
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

    File.open("cached_classes2.json", "wb") { |file| file.write(Oj.dump(uniq_classes)) }
    File.open("cached_shows2.json", "wb") { |file| file.write(Oj.dump(uniq_shows)) }

    File.open("current_classes2.json", "wb") { |file| file.write(Oj.dump(@classes_json)) }
    File.open("current_shows2.json", "wb") { |file| file.write(Oj.dump(@shows_json.sort_by { |hsh| hsh[:start_stamp] })) }
  end
end

Runner.new.run
