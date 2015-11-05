require 'open-uri'

# this is a script to get sample data for test.
# set constatns below
# usage:
#   ruby sample_data_fetcher.rb

APP_STORE_APP_ID = "000000000"
GOOGLE_PLAY_APP_ID = "com.example"
GSUTIL_PATH = "/path/to/gsutil"
BUCKET_ID = "pubsite_prod_rev_00000000000000000000"

def fetch_app_store_reviews
  base_url = "https://itunes.apple.com"
  user_agent = "iTunes/9.2 (Windows; Microsoft Windows 7 "\
                            + "Home Premium Edition (Build 7600)) AppleWebKit/533.16"

  page = 0
  url = base_url + "/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="\
    + APP_STORE_APP_ID + "&pageNumber="+page.to_s+"&sortOrdering=4&type=Purple+Software"
  xml = open(url, 'User-Agent' => user_agent, 'X-Apple-Store-Front' => '143462-1').read
  return xml
end 

def fetch_google_play_reviews
  csv = _get_csv_name
  result = _copy_csv(csv)
end

def _get_csv_name
  ym = Time.now.strftime("%Y%m")
  csv = "reviews_#{GOOGLE_PLAY_APP_ID}_#{ym}.csv"
  return csv   
end   

def _copy_csv(csv)
  return -1 unless GSUTIL_PATH
  return -1 unless BUCKET_ID

  cmd = GSUTIL_PATH
  bucket_id = BUCKET_ID
  value = `#{cmd} cp gs://#{bucket_id}/reviews/#{csv} ./`
    return 1 if $?.exited?
  return -1
end


if APP_STORE_APP_ID
  xml = fetch_app_store_reviews
  file_name = "app_store_reviews.xml"
  File.open(file_name, 'w') {|file|
    file.write xml
  }
end

if GOOGLE_PLAY_APP_ID && GSUTIL_PATH && BUCKET_ID
  fetch_google_play_reviews
end
