module Kansou
  class GooglePlayReview
    def initialize(app_id, bucket_id, csv_dir=nil, gsutil_path=nil)
      return nil unless app_id
      return nil unless bucket_id

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
        html_string = JSON.parse(response.body.gsub(/\)\]\}\'/,""))[0][2]
      end

      def parse(html_text)
        p html_text
        reviews = []
        return reviews
      end

  end
end
