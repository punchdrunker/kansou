# coding: utf-8
require 'spec_helper'

describe Kansou::GooglePlayReview do
  it 'parses google play reviews' do
    dummy_review_path = File.dirname(__FILE__) + '/../google-review.txt'
    dummy_string = open(dummy_review_path){|f| f.read }

    review = Kansou::GooglePlayReview.new("jp.mixi")
    allow(review).to receive(:download).and_return(dummy_string)

    reviews = review.fetch(1)
    
    expect(reviews.size).to eq(40)
    expect(reviews[2][:star]).to eq(1)
    expect(reviews[2][:date].to_s).to eq("2015年12月21日")
    expect(reviews[2][:title].length).not_to eq(0)
    expect(reviews[2][:body].length).not_to eq(0)
  end

  it 'does not die if exception occurred' do
    dummy_review_path = File.dirname(__FILE__) + '/../google-review-bad.txt'
    dummy_string = open(dummy_review_path){|f| f.read }

    review = Kansou::GooglePlayReview.new("jp.mixi")
    allow(review).to receive(:download).and_return(dummy_string)

    reviews = review.fetch(1)
    
    expect(reviews.size).to eq(0)
  end
end
