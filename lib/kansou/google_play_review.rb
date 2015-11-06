module Kansou
  class GooglePlayReview
    def fetch(app_id, pages=0)
      @app_id = app_id
      csv = _get_csv_name
      result = download(csv)
      return parse(result)
    end

    def get_csv_name
      ym = Time.now.strftime("%Y%m")
      csv = "reviews_#{GOOGLE_PLAY_APP_ID}_#{ym}.csv"
      return csv   
    end   

    def download(csv)
      return -1 unless GSUTIL_PATH
      return -1 unless BUCKET_ID

      cmd = GSUTIL_PATH
      bucket_id = BUCKET_ID
      value = `#{cmd} cp gs://#{bucket_id}/reviews/#{csv} ./`
        if $?.exited?
          csv_path = _get_csv_path(csv)
          utf16 = open(csv_path, "rb:BOM|UTF-16"){|f| f.read }
          utf8 = utf16.encode("UTF-8")
        end
      return -1

    end

    def parse(csv)
      reviews = []
      CSV.parse(utf8, col_sep: ",", row_sep: "\n", headers: :first_row) do |row|
        next if row["Review Title"]==nil && row["Review Text"]==nil
        review = {
          :star => row["Star Rating"],
          :date => Time.at(row["Review Submit Millis Since Epoch"].to_f / 1000.0),
          :title => row["Review Title"],
          :body => row["Review Text"],
          :version => row["App Version Code"],
          :device => row["Device"],
          :app_id => @app[:app_id]
        }
        reviews.push review
      end
      return reviews
    end
  end
end
