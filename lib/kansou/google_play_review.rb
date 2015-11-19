require 'csv'

module Kansou
  class GooglePlayReview
    def initialize(app_id, bucket_id, csv_dir=nil, gsutil_path=nil)
      return nil unless app_id
      return nil unless bucket_id
      csv_dir ||= "/tmp"

      @app_id = app_id
      @bucket_id = bucket_id
      @gsutil_path = gsutil_path
      @csv_dir = csv_dir
    end

    def fetch(pages=0)
      csv = get_csv_name
      result = download(csv)
      if result
        return parse(result)
      end
    end

    private
      def download(csv)
        cmd = GSUTIL_PATH
        bucket_id = BUCKET_ID
        value = `#{cmd} cp gs://#{bucket_id}/reviews/#{csv} ./`
        if $?.exited?
          csv_path = get_csv_path(csv)
          utf16 = open(csv_path, "rb:BOM|UTF-16"){|f| f.read }
          utf8 = utf16.encode("UTF-8")
          return utf8
        end
      end

      def parse(csv_text)
        reviews = []
        CSV.parse(csv_text, col_sep: ",", row_sep: "\n", headers: :first_row) do |row|
          next if row["Review Title"]==nil && row["Review Text"]==nil
          review = {
            :star => row["Star Rating"],
            :date => Time.at(row["Review Submit Millis Since Epoch"].to_f / 1000.0),
            :title => row["Review Title"],
            :body => row["Review Text"],
            :version => row["App Version Code"],
            :device => row["Device"],
            :app_id => @app_id
          }
          reviews.push review
        end
        return reviews
      end

      def get_csv_name
        ym = Time.now.strftime("%Y%m")
        csv = "reviews_#{@app_id}_#{ym}.csv"
        return csv   
      end   

      def get_csv_path(csv)
        csv_path = @csv_dir + '/' + csv
      end

  end
end
