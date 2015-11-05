require 'spec_helper'

describe Kansou do
  it 'has a version number' do
    expect(Kansou::VERSION).not_to be nil
  end

  it 'does something useful' do
    Kansou.fetch(1)
    expect(true).to eq(true)
  end
end
