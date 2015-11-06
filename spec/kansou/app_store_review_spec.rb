require 'spec_helper'

describe Kansou::AppStoreReview do
  it 'parses app store reviews' do
    f = open(File.dirname(__FILE__) + '/../app_store_reviews.xml')

    review = Kansou::AppStoreReview.new
    review.stub(:download).and_return(f.read)

    reviews = review.fetch(1,0)
    
    expect(reviews.size).to eq(25)
    expect(reviews[2][:star]).to eq("1")
    expect(reviews[2][:user]).to eq("amtq7+15<9")
    expect(reviews[2][:date]).to eq("Nov01,2015")
    expect(reviews[2][:title].length).not_to eq(0)
    expect(reviews[2][:body].length).not_to eq(0)
  end
  
  it 'parses version info' do
    review = Kansou::AppStoreReview.new
    expect(review.get_version('Version11.1')).to eq('11.1')
  end
end
