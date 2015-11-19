require 'spec_helper'

describe Kansou::GooglePlayReview do
  it 'parses google play reviews' do
    dummy_csv_path = File.dirname(__FILE__) + '/../google_play_reviews.csv'
    utf16 = open(dummy_csv_path, "rb:BOM|UTF-16"){|f| f.read }
    utf8 = utf16.encode("UTF-8")

    review = Kansou::GooglePlayReview.new(23134, "pubsite_prod_rev_1234567890")
    review.stub(:download).and_return(utf8)

    reviews = review.fetch(1)
    
    expect(reviews.size).to eq(2)
    expect(reviews[1][:star]).to eq("5")
    expect(reviews[1][:date].to_s).to eq("2015-11-02 15:40:54 +0900")
    expect(reviews[1][:title].length).not_to eq(0)
    expect(reviews[1][:body].length).not_to eq(0)
  end
end
