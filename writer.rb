#  def write_show(id:, title:, description:, full_description:, image:, cost:, date:, pageurl:)
#     @shows_json << Detail.new(id, title, description, full_description, image, cost, date, pageurl)
#     puts "Writing show details for #{title}".yellow
#     summary = ActionView::Base.new.truncate(description, length: 300, separator: ' ')

#     index = <<-eos
#       <div class="row clients-page">
#         <div class="col-md-2" align="center">
#           <div class="thumbnail-img">
#               <div class="overflow-hidden">
#                   <img class="img-responsive" src="#{image}" alt="" />
#               </div>
#           </div>
#         </div>
#         <div class="col-md-10">
#           <h3>#{title}</h3>
#           <ul class="list-inline">
#             <li><i class="fa fa-money color-green"></i> #{cost}</li>
#             <li><i class="fa fa-clock-o color-green"></i> #{date}</li>
#             <li><i class="fa fa-ticket color-green"></i> <a href="#{pageurl}" target="_blank">Buy Tickets</a></li>
#           </ul>
#           <p>#{summary}</p>
#           <p><span class="pull-left"><a class="btn-more btn-u btn-u-large" href="shows.html##{id}">read more</a></span><span class="pull-right"><a href="#{pageurl}" target="_blank" class="unii-listing-button unii-pink unii-medium">Buy Tickets</a></span></p>
#         </div>
#       </div>
#       <hr />
#     eos
#     @index_shows << index

#     shows = <<-eos
#             <div class="col-md-12">
#                 <div class="search-blocks search-blocks-left-orange">
#                     <div class="row">
#                         <div class="col-md-4 search-img">
#                             <img class="img-responsive" src="#{image}" alt="">
#                         </div>
#                         <div class="col-md-8 longarticle">
#                             <h2><a href="#" id="#{id}" name="#{id}">#{title}</a></h2>
#                             <article>
#                             #{full_description}
#                             </article>
#                             <br />
#                             <a href="#{pageurl}" target="_blank" class="unii-listing-button unii-pink unii-medium">Buy Tickets</a>
#                         </div>
#                     </div>
#                 </div>
#             </div>
#     eos
#     @shows << shows
#   end

#   def write_class(id:, title:, description:, full_description:, image:, cost:, date:, pageurl:)
#     puts "Writing class details for #{title}".green
#     @classes_json << Detail.new(id, title, description, full_description, image, cost, date, pageurl)
#     summary = ActionView::Base.new.truncate(description, length: 300, separator: ' ')
#     page_link = "improvisation"
#     if title.match(/sketch/i)
#       puts "setting to sketch_comedy".red
#       page_link = "sketch_comedy"
#     end

#     index = <<-eos
#       <div class="row clients-page">
#         <div class="col-md-2" align="center">
#           <div class="thumbnail-img">
#               <div class="overflow-hidden">
#                   <img class="img-responsive" src="#{image}" alt="" />
#               </div>
#           </div>
#         </div>
#         <div class="col-md-10">
#           <h3>#{title}</h3>
#           <ul class="list-inline">
#             <li><i class="fa fa-money color-green"></i> #{cost}</li>
#             <li><i class="fa fa-clock-o color-green"></i> #{date}</li>
#             <li><i class="fa fa-ticket color-green"></i> <a href="#{pageurl}" target="_blank">Register Now!</a></li>
#           </ul>
#           <p>#{summary}</p>
#           <p><span class="pull-left"><a class="btn-more btn-u btn-u-large" href="#{page_link}.html##{id}">read more</a></span><span class="pull-right"><a href="#{pageurl}" target="_blank" class="unii-listing-button unii-pink unii-medium">Register Now</a></span></p>
#         </div>
#       </div>
#       <hr />
#     eos
#     @index_classes << index
#   end
