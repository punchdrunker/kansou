require 'open-uri'
require 'oga'

module Kansou
  class AppStoreReview
    def initialize(app_id)
      return nil unless app_id

      @app_id = app_id

      @users = []
      @versions = []
      @dates = []
      @titles = []
      @stars = []
      @bodies = []
    end

    def fetch(page_amount = 1)
      reviews = []
      max_page = page_amount - 1
      (0..max_page).each do |page|
        xml = download(page)
        reviews.concat(parse(xml))
      end
      reviews
    end

    def download(page = 0)
      base_url = 'https://itunes.apple.com'
      user_agent = 'iTunes/9.2 (Windows; Microsoft Windows 7 '\
                                + 'Home Premium Edition (Build 7600)) AppleWebKit/533.16'

      url = base_url + '/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id='\
        + @app_id.to_s + '&pageNumber=' + page.to_s + '&sortOrdering=4&type=Purple+Software'
      xml = open(url, 'User-Agent' => user_agent, 'X-Apple-Store-Front' => '143462-1').read
      xml
    end

    def parse(xml)
      i = 0
      document = Oga.parse_xml(xml)

      parse_author_info(document)

      document.css('TextView[styleSet="basic13"][textJust="left"][maxLines="1"]').each do |elm|
        elm.css('b').each do |e|
          @titles.push e.text
        end
      end

      document.css('HBoxView[topInset="1"]').each do |elm|
        @stars.push elm.attribute('alt').value.gsub(/ stars*/, '')
      end

      document.css('TextView[styleSet="normal11"]').each do |elm|
        @bodies.push(elm.text.gsub("\n", '<br />'))
      end

      items = []
      count = @stars.size - 1
      (0..count).each do |key|
        item = {
          star: @stars[key],
          user: @users[key],
          date: @dates[key],
          title: @titles[key],
          body: @bodies[key],
          version: @versions[key],
          app_id: @app_id
        }
        items.push(item)
      end
      items
    end

    def parse_author_info(document)
      expression = 'TextView[topInset="0"][styleSet="basic13"][squishiness="1"][leftInset="0"][truncation="right"][textJust="left"][maxLines="1"]'
      document.css(expression).each do |elm|
        next unless elm.text =~ /by/
        tmp_array = elm.text.delete(' ').split("\n")
        info = []
        tmp_array.each do |v|
          info.push v if v != '' && v != '-' && v != 'by'
        end
        @users.push info[0]

        if info[1]
          @versions.push(get_version(info[1]))
        else
          @versions.push('')
        end

        if info[2]
          @dates.push(info[2])
        else
          @dates.push('')
        end
      end
    end

    def get_version(text)
      version = nil
      version = Regexp.last_match(1) if /Version([\d\.]+)/ =~ text
      version
    end
  end
end
