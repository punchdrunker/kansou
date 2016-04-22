# coding: utf-8
require 'spec_helper'

describe Kansou::GooglePlayReview do
  it 'parses google play reviews' do
    dummy_review_path = File.dirname(__FILE__) + '/../google-review.txt'
    dummy = open(dummy_review_path){|f| f.read }

    review = Kansou::GooglePlayReview.new("jp.mixi")
    review.stub(:download).and_return(dummy)

    reviews = review.fetch
    
    expect(reviews.size).to eq(40)
    expect(reviews[2][:star]).to eq(2)
    expect(reviews[2][:date].to_s).to eq("2016年2月27日")
    expect(reviews[2][:title].length).not_to eq(0)
    expect(reviews[2][:body].length).not_to eq(0)
  end
end
