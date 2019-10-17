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
      next if parsed.nil?
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

    # for 666 only
    doc666 = JSON.load(open("https://www.universe.com/api/v2/listings/the-666-project-a-horror-anthology-show-tickets-norfolk-9Z4LSJ.json"))
    start_stamp = doc666["events"][0]["start_stamp"].to_i
    item = doc666["listing"]

    i = 1
    doc666["rates"].each do |rate|
      name = rate["name"]
      listing_id = rate["listing_id"]

      cost = rate["price"].to_i
      if cost == 0
        cost = "Free"
      else
        cost = "$%.2f" % cost
      end

      cover_photo_id = item["cover_photo_id"]
      image = doc666["images"].select { |e|
        e["id"] == cover_photo_id
      }.first

      parsed = {
        start_stamp: start_stamp + i,
        id: listing_id,
        title: item["title"].to_s.strip,
        date: name,
        image: image["url_160"],
        cost: cost,
        pageurl: "https://www.universe.com/events/#{item["slug_param"]}",
        description: item["description"].to_s,
        full_description: item["description_html"].to_s,
        type: "show"
      }
      i += 1
      @shows_json << parsed
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

    LOGGER.info("Checking for new classes")
    current_classes_id_list = JSON.load(File.read("current_classes.json")).map do |item|
      item["id"]
    end
    new_current_classes = @classes_json.reject do |item|
      current_classes_id_list.include?(item[:id])
    end
    new_classes_count = new_current_classes.count
    LOGGER.info("There are #{new_classes_count} new classes")

    LOGGER.info("Checking for new shows")
    current_shows_id_list = JSON.load(File.read("current_shows.json")).map do |item|
      item["id"]
    end
    new_current_shows = @shows_json.reject do |item|
      current_shows_id_list.include?(item[:id])
    end
    new_shows_count = new_current_shows.count
    LOGGER.info("There are #{new_shows_count} new shows")

    File.open("current_classes.json", "wb") { |file| file.write(JSON.dump(@classes_json)) }
    File.open("current_shows.json", "wb") { |file| file.write(JSON.dump(@shows_json.sort_by { |hsh| hsh[:start_stamp] })) }

    return STRIO.string, (new_classes_count > 0 || new_shows_count > 0)
  end
end

output, send_email = Runner.new.run
puts output
if send_email
  puts "Sending email"
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
else
  puts "No changes"
end
