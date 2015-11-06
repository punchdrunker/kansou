require "kansou/version"

module Kansou
  def self.fetch(app_id, pages=0)
    if is_app_store_app(app_id)
      review = Kansou::AppStoreReview.new
      return review.fetch(app_id, pages)
    else
      review = GooglePlayReview.new(app_id)
      return review.fetch
    end
  end

  def self.is_app_store_app(id)
    return (/\A\d+\Z/ =~ id.to_s) ? true : false
  end
end
