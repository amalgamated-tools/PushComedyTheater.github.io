class Parser
  Oj.default_options = {:mode => :compat}
  DEBUG = false
  SHOWNAMES = ["Fake News The Musical"]
  SHOWREGEXES = [/Storytelling Night/i, /IMPROVAGEDDON/i, /Improvised Fairy Tale/i, /Date Night/i, /Monocle/i, /Tales from the Campfire/i, /SKETCHMAGEDDON/i, /The Unusual Suspects/i, /Improv Riot/i, /Class Dismissed/i, /Girl-Prov/i, /Second Saturday Stand-Up/i, /3 on 3 Improv Tournament/i, /Teacher's Pet/i]
  CLASSNAMES = {
    "Acting 101 with Brant Powell" => "acting101",
    "Improv 101 with Brad McMurran" => "improv101",
    "Improv 101:  Introduction to Improvisation" => "improv101",
    "Improv 201 at the Push Comedy Theater" => "improv201",
    "Improv 201: Foundations of the Harold" => "improv201",
    "Improv 201: Foundations of the Harold: Game and Second Beats" => "improv201",
    "Improv 301 : The Harold Openers and Group Games" => "improv301",
    "Improv 301: The Harold Openers and Group Games" => "improv301",
    "Improv 401: Advanced Harold" => "improv401",
    "Improv 501: Improv Studio (Advanced Harold Study)" => "improv501",
    "Improv 501: Improv Studio with Brad McMurran" => "improv501",
    "Improv 501: Improv Studio" => "improv501",
    "Improv Comedy 101" => "improv101",
    "Improv for Kids at the Push Comedy Theater" => "preteen_101",
    "Improv for Pre-Teens" => "teen_improv",
    "Improv for Teens at the Push Comedy Theater" => "teen_improv",
    "Improv for Teens" => "teen_improv",
    "KidProv at the Push Comedy Theater" => "preteen_101",
    "Musical Improv 101" => "music_improv101",
    "Musical Improv 201" => "music_improv201",
    "Musical Improv Studio" => "music_improve_studio",
    "Pre-Teen Improv Camp" => "kidprovcamp1",
    "Pre-Teen Improv at the Push Comedy Theater" => "preteen_101",
    "Pre-teen Improvisation Comedy Camp Session 2" => "preteen_101",
    "Sketch Comedy Writing 101" => "sketch101",
    "Sketch 101 at the Push Comedy Theater" => "sketch101",
    "Sketch 101: Introduction to Sketch Comedy Writing" => "sketch101",
    "Sketch 301: Sketch Studio" => "sketch201",
    "Sketch Comedy Writing 101 at the Push Comedy Theater" => "sketch101",
    "Sketch Comedy Writing 201: Advanced Sketch Writing" => "sketch201",
    "Stand Up 101" => "standup101",
    "Stand-Up Comedy 101 with Hatton Jordan" => "standup101",
    "Teen Sketch Comedy Camp" => "teen_improv",
    "Teen Improv and Sketch Comedy Summer Camp" => "teenimprovcamp1",
  }

  def self.cached_classes
    @classes ||= Oj.load(File.read("cached_classes.json"))
  end

  def self.cached_shows
    @shows ||= Oj.load(File.read("cached_shows.json"))
  end

  def self.parse_item(parent, logger)
    parsed = {}
    url = "https://www.universe.com/api/v2/listings/#{parent["id"]}.json"
    logger.info "Parsing URL #{url}"
    json = load_json(url, logger)
    item = json["listing"]
    return if item["state"] == "expired"

    parsed[:start_stamp] = json["events"][0]["start_stamp"].to_i
    parsed[:id] = item["id"]
    parsed[:title] = item["title"].to_s.strip
    logger.info "> Title = #{parsed[:title]}"
    parsed[:date] = parent["formatted_duration"]

    cover_photo_id = item["cover_photo_id"]
    image = json["images"].select { |e|
      e["id"] == cover_photo_id
    }.first
    parsed[:image] = image["url_160"]

    cost = item["price"].to_i
    if cost == 0
      cost = "Free"
    else
      cost = "$%.2f" % cost
    end
    parsed[:cost] = cost

    parsed[:pageurl] = "https://www.universe.com/events/#{item["slug_param"]}"
    parsed[:description] = item["description"].to_s
    parsed[:full_description] = item["description_html"].to_s

    logger.debug "> Parsed details, now loading type"

    cached_show = cached_shows.select { |show|
      logger.debug "- checking show #{show["title"]}"
      show_id = show["id"]
      parsed_id = parsed[:id]
      logger.debug "- show_id   = #{show_id}"
      logger.debug "- parsed_id = #{parsed_id}"
      show_id == parsed_id
    }
    logger.debug "- cached_show.count = #{cached_show.count}"
    logger.debug ""
    cached_class = cached_classes.select { |clas|
      logger.debug "- checking class #{clas["title"]}"
      clas_id = clas["id"]
      parsed_id = parsed[:id]
      logger.debug "- clas_id   = #{clas_id}"
      logger.debug "- parsed_id = #{parsed_id}"
      clas_id == parsed_id
    }
    logger.debug "- cached_class.count = #{cached_class.count}"
    logger.debug ""

    if cached_show.count > 0
      logger.info "> This is a cached show"
      parsed[:type] = "show"
    elsif cached_class.count > 0
      logger.info "> This is a cached class"
      parsed[:type] = "class"
      parsed[:slug] = cached_class.first["slug"]
    else
      logger.debug "> This was not in cache"
      if CLASSNAMES.keys.include?(parsed[:title])
        logger.info "> This is a default class"
        parsed[:type] = "class"
        parsed[:slug] = CLASSNAMES[parsed[:title]]
      elsif SHOWNAMES.include?(parsed[:title])
        logger.info "> This is a default show"
        parsed[:type] = "show"
      else
        a = SHOWREGEXES.select do |x|
          x.match(parsed[:title])
        end
        if a.count == 1
          logger.info "> This is a regex show"
          parsed[:type] = "show"
        else
          logger.info "We aren't sure what this is, but we're going with show"
          parsed[:type] = "show"
        end
      end
    end

    logger.info "> Returning :#{parsed[:type]}"
    parsed
  end

  protected

  def self.load_json(url, logger)
    beginning_time = Time.now
    contents = Net::HTTP.get(URI.parse(url))
    json = Oj.load(contents)
    end_time = Time.now
    filename = url.gsub("https://www.universe.com/api/v2/listings/", "")
    # File.open("./down/#{filename}", "wb") { |file| file.write(contents) }
    logger.debug "Loaded JSON in #{(end_time - beginning_time) * 1000} milliseconds"
    json
  end
end
