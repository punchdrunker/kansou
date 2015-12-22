require 'json'
require 'oga'

module Kansou
  class GooglePlayReview
    def initialize(app_id)
      return nil unless app_id

      @app_id = app_id
    end

    def fetch(pages=1)
      reviews = []
      pages.times do |page|
        result = download(@app_id, page)
        if result
          reviews.concat(parse(result))
        end
      end
      return reviews
    end

    private
      def download(app_id, page=0)
        http = Net::HTTP.new('play.google.com', 443)
        http.use_ssl = true
        path = "/store/getreviews"
        data = "id=#{app_id}&reviewSortOrder=0&reviewType=1&pageNum=#{page}"
        response = http.post(path, data)
        return response.body
      end

      def parse(input_text)
        input_text = remove_unused_lines(input_text)
        json = JSON.load(input_text)
        body = json[0][2]

        titles = []
        bodies = []
        dates = []
        stars = []
        authors = []
        document = Oga.parse_html(body)
        main_expression = 'div[class="single-review"]'
        title_expression = 'span[class="review-title"]'
        body_expression = 'div[class="review-body"]'
        date_expression = 'span[class="review-date"]'
        star_expression = 'div[class="current-rating"]'
        author_expression = 'span[class="author-name"]'

        document.css(main_expression).each do |elm|
          elm.css(title_expression).each { |title_node| titles.push(title_node.text) }
          elm.css(body_expression).each { |body_node| bodies.push(body_node.text) }
          elm.css(date_expression).each { |date_node| dates.push(date_node.text) }
          elm.css(star_expression).each { |star_node| stars.push(process_star_count(star_node)) }
          elm.css(author_expression).each { |author_node| authors.push(author_node.text.strip) }
        end

        reviews = []
        count = stars.size - 1
        (0..count).each do |key|
          item = {
            :star   => stars[key],
            :user   => authors[key],
            :date   => dates[key],
            :title  => titles[key],
            :body   => bodies[key],
            :app_id => @app_id
          }
          reviews.push(item)
        end
        return reviews
      end

      def remove_unused_lines(text)
        lines =  text.split("\n")
        return lines[2] + "]"
      end

      def process_star_count(node)
        widths = node.attribute("style").value.match("width: ([0-9]+)")
        star  = widths[1].to_i / 20
      end
  end
end
