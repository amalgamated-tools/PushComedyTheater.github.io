require "open-uri"
require "net/http"
require "uri"
require "date"
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


    @shows_json << {
      start_stamp: 1584230401,
      id: "5e1f17846977fe00500f11bb",
      title: "The Unusual Suspects: An Improvised Murder Mystery",
      date: "Sat, Apr 11 at  8 -  9:30pm",
      image: "https://images.universe.com/76ef698a-21fc-4970-9604-f2eabad44510/-/format/jpeg/-/scale_crop/160x160/center/-/progressive/yes/-/inline/yes/",
      cost: "$15.00",
      pageurl: "https://www.universe.com/events/the-unusual-suspects-an-improvised-murder-mystery-tickets-D5P8VJ",
      description: "Who Dunnit: The Improvised Murder Mystery is now The Unusual Suspects... new name, same great show.\n\nThe hottest show in the history of the 757 is NOW A NATIONALLY TOURING SHOW!\n\nThe Unusual Suspects\n\nThere’s been a murder. Everyone is a suspect. The actors on stage. Even you.\n\nWelcome to The Unusual Suspects, an improvised murder mystery comedy.\n\nThroughout the night, the world’s greatest detective will interrogate a cast of unusual characters, from the wacky to the dastardly.\n\nYou’ll find yourself face to face with our notorious investigator. Could he be Sherlock, Columbo, Jessica Fletcher? Not exactly. The catch is, no one ever knows which detective will show up.\n\nNo one is above suspicion, including you and your guests.\n\nJoin us at the hit show that’s played to sold-out audiences for more than three years and counting. This isn’t your standard dinner detective fare; get ready for a wild and funny night that everyone will be talking about the next day, your family, your friends, and maybe even your priest.\n\nThe Unusual Suspects is brought to you by the writers and producers of the off-Broadway and national hit: Cuff Me: The Fifty Shades of Grey Musical Parody.\n\nThe Unusual Suspects: An Improvised Murder Mystery Comedy\n\nThe second Saturday of every month at the Push Comedy Theater\n\nThe show starts at 8pm, tickets are $15\n\nThe Push Comedy Theater only has 99 seats, so we recommend you get your tickets in advance.\n\n---\n\nThe Push Comedy Theater is a 99 seat venue in the heart of Norfolk's brand new Arts District. Founded by local comedy group The Pushers, the Push Comedy Theater is dedicated to bringing you live comedy from the best local and national acts.\n\nThe Push Comedy Theater hosts live sketch, improv and stand-up comedy on Friday and Saturday nights. During the week classes are offered in stand-up, sketch and improv comedy as well as acting.\n\nWhether you're a die-hard comedy lover or a casual fan... a seasoned performer or someone who's never stepped foot on stage... the Push Comedy Theater has something for you.\n",
      full_description: "<p>Who Dunnit: The Improvised Murder Mystery is now The Unusual Suspects... new name, same great show.\n</p>\n<p>The hottest show in the history of the 757 is NOW A NATIONALLY TOURING SHOW!\n</p>\n<p>The Unusual Suspects\n</p>\n<p>There’s been a murder. Everyone is a suspect. The actors on stage. Even you.\n</p>\n<p>Welcome to The Unusual Suspects, an improvised murder mystery comedy.\n</p>\n<p>Throughout the night, the world’s greatest detective will interrogate a cast of unusual characters, from the wacky to the dastardly.\n</p>\n<p>You’ll find yourself face to face with our notorious investigator. Could he be Sherlock, Columbo, Jessica Fletcher? Not exactly. The catch is, no one ever knows which detective will show up.\n</p>\n<p>No one is above suspicion, including you and your guests.\n</p>\n<p>Join us at the hit show that’s played to sold-out audiences for more than three years and counting. This isn’t your standard dinner detective fare; get ready for a wild and funny night that everyone will be talking about the next day, your family, your friends, and maybe even your priest.\n</p>\n<p>The Unusual Suspects is brought to you by the writers and producers of the off-Broadway and national hit: Cuff Me: The Fifty Shades of Grey Musical Parody.\n</p>\n<p>The Unusual Suspects: An Improvised Murder Mystery Comedy\n</p>\n<p>The second Saturday of every month at the Push Comedy Theater\n</p>\n<p>The show starts at 8pm, tickets are $15\n</p>\n<p>The Push Comedy Theater only has 99 seats, so we recommend you get your tickets in advance.\n</p>\n<p>---<br>\n</p>\n<p>The Push Comedy Theater is a 99 seat venue in the heart of Norfolk's brand new Arts District. Founded by local comedy group The Pushers, the Push Comedy Theater is dedicated to bringing you live comedy from the best local and national acts.\n</p>\n<p>The Push Comedy Theater hosts live sketch, improv and stand-up comedy on Friday and Saturday nights. During the week classes are offered in stand-up, sketch and improv comedy as well as acting.\n</p>\n<p>Whether you're a die-hard comedy lover or a casual fan... a seasoned performer or someone who's never stepped foot on stage... the Push Comedy Theater has something for you.\n</p>",
      type: "show"
    }
    @shows_json << {
      start_stamp: 1584230402,
      id: "5e1f17846977fe00500f11bc",
      title: "The Unusual Suspects: An Improvised Murder Mystery",
      date: "Sat, May 9 at  8 -  9:30pm",
      image: "https://images.universe.com/76ef698a-21fc-4970-9604-f2eabad44510/-/format/jpeg/-/scale_crop/160x160/center/-/progressive/yes/-/inline/yes/",
      cost: "$15.00",
      pageurl: "https://www.universe.com/events/the-unusual-suspects-an-improvised-murder-mystery-tickets-D5P8VJ",
      description: "Who Dunnit: The Improvised Murder Mystery is now The Unusual Suspects... new name, same great show.\n\nThe hottest show in the history of the 757 is NOW A NATIONALLY TOURING SHOW!\n\nThe Unusual Suspects\n\nThere’s been a murder. Everyone is a suspect. The actors on stage. Even you.\n\nWelcome to The Unusual Suspects, an improvised murder mystery comedy.\n\nThroughout the night, the world’s greatest detective will interrogate a cast of unusual characters, from the wacky to the dastardly.\n\nYou’ll find yourself face to face with our notorious investigator. Could he be Sherlock, Columbo, Jessica Fletcher? Not exactly. The catch is, no one ever knows which detective will show up.\n\nNo one is above suspicion, including you and your guests.\n\nJoin us at the hit show that’s played to sold-out audiences for more than three years and counting. This isn’t your standard dinner detective fare; get ready for a wild and funny night that everyone will be talking about the next day, your family, your friends, and maybe even your priest.\n\nThe Unusual Suspects is brought to you by the writers and producers of the off-Broadway and national hit: Cuff Me: The Fifty Shades of Grey Musical Parody.\n\nThe Unusual Suspects: An Improvised Murder Mystery Comedy\n\nThe second Saturday of every month at the Push Comedy Theater\n\nThe show starts at 8pm, tickets are $15\n\nThe Push Comedy Theater only has 99 seats, so we recommend you get your tickets in advance.\n\n---\n\nThe Push Comedy Theater is a 99 seat venue in the heart of Norfolk's brand new Arts District. Founded by local comedy group The Pushers, the Push Comedy Theater is dedicated to bringing you live comedy from the best local and national acts.\n\nThe Push Comedy Theater hosts live sketch, improv and stand-up comedy on Friday and Saturday nights. During the week classes are offered in stand-up, sketch and improv comedy as well as acting.\n\nWhether you're a die-hard comedy lover or a casual fan... a seasoned performer or someone who's never stepped foot on stage... the Push Comedy Theater has something for you.\n",
      full_description: "<p>Who Dunnit: The Improvised Murder Mystery is now The Unusual Suspects... new name, same great show.\n</p>\n<p>The hottest show in the history of the 757 is NOW A NATIONALLY TOURING SHOW!\n</p>\n<p>The Unusual Suspects\n</p>\n<p>There’s been a murder. Everyone is a suspect. The actors on stage. Even you.\n</p>\n<p>Welcome to The Unusual Suspects, an improvised murder mystery comedy.\n</p>\n<p>Throughout the night, the world’s greatest detective will interrogate a cast of unusual characters, from the wacky to the dastardly.\n</p>\n<p>You’ll find yourself face to face with our notorious investigator. Could he be Sherlock, Columbo, Jessica Fletcher? Not exactly. The catch is, no one ever knows which detective will show up.\n</p>\n<p>No one is above suspicion, including you and your guests.\n</p>\n<p>Join us at the hit show that’s played to sold-out audiences for more than three years and counting. This isn’t your standard dinner detective fare; get ready for a wild and funny night that everyone will be talking about the next day, your family, your friends, and maybe even your priest.\n</p>\n<p>The Unusual Suspects is brought to you by the writers and producers of the off-Broadway and national hit: Cuff Me: The Fifty Shades of Grey Musical Parody.\n</p>\n<p>The Unusual Suspects: An Improvised Murder Mystery Comedy\n</p>\n<p>The second Saturday of every month at the Push Comedy Theater\n</p>\n<p>The show starts at 8pm, tickets are $15\n</p>\n<p>The Push Comedy Theater only has 99 seats, so we recommend you get your tickets in advance.\n</p>\n<p>---<br>\n</p>\n<p>The Push Comedy Theater is a 99 seat venue in the heart of Norfolk's brand new Arts District. Founded by local comedy group The Pushers, the Push Comedy Theater is dedicated to bringing you live comedy from the best local and national acts.\n</p>\n<p>The Push Comedy Theater hosts live sketch, improv and stand-up comedy on Friday and Saturday nights. During the week classes are offered in stand-up, sketch and improv comedy as well as acting.\n</p>\n<p>Whether you're a die-hard comedy lover or a casual fan... a seasoned performer or someone who's never stepped foot on stage... the Push Comedy Theater has something for you.\n</p>",
      type: "show"
    }

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

    File.open("current_classes.json", "wb") { |file| file.write(JSON.pretty_generate(@classes_json)) }
    File.open("current_shows.json", "wb") { |file| file.write(JSON.pretty_generate(@shows_json.sort_by { |hsh| hsh[:start_stamp] })) }

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
