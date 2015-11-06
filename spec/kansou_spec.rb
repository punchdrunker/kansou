require 'spec_helper'

describe Kansou do
  it 'has a version number' do
    expect(Kansou::VERSION).not_to be nil
  end

  it 'handles app id' do
    expect(Kansou.is_app_store_app(123)).to eq(true)
    expect(Kansou.is_app_store_app("com.example")).to eq(false)
    expect(Kansou.is_app_store_app(nil)).to eq(false)
  end
end
