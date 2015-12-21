require 'open-uri'
require 'oga'

module Kansou
  class AppStoreReview
    def fetch(app_id, page_amount=1)
      # TODO: error handling
      # app_id
      # page_amount

      @app_id = app_id
      reviews = []
      max_page = page_amount - 1
      (0..max_page).each do |page|
        xml = download(app_id, page)
        reviews.concat(parse(xml))
      end
      return reviews
    end

    def download(app_id, page=0)
      base_url = "https://itunes.apple.com"
      user_agent = "iTunes/9.2 (Windows; Microsoft Windows 7 "\
                                + "Home Premium Edition (Build 7600)) AppleWebKit/533.16"

      url = base_url + "/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="\
        + app_id.to_s + "&pageNumber="+page.to_s+"&sortOrdering=4&type=Purple+Software"
      xml = open(url, 'User-Agent' => user_agent, 'X-Apple-Store-Front' => '143462-1').read
      return xml
    end

    def parse(xml)
      items = []
      users = []
      versions = []
      dates = []
      i = 0
      document = Oga.parse_xml(xml)

      expression = 'TextView[topInset="0"][styleSet="basic13"][squishiness="1"][leftInset="0"][truncation="right"][textJust="left"][maxLines="1"]'
      document.css(expression).each do |elm|
        if elm.text =~ /by/
          tmp_array = elm.text.gsub(" ", "").split("\n")
          info = []
          tmp_array.each do |v|
            if v!=""&&v!="-"&&v!="by"
              info.push v
            end
          end
          users.push info[0]

          if info[1]
            versions.push(get_version(info[1]))
          else
            versions.push("")
          end

          if info[2]
            dates.push(info[2])
          else
            dates.push("")
          end
        end
      end

      titles = []
      document.css('TextView[styleSet="basic13"][textJust="left"][maxLines="1"]').each do |elm|
        elm.css('b').each do |e|
          titles.push e.text
        end
      end

      stars = []
      document.css('HBoxView[topInset="1"]').each do |elm|
        stars.push elm.attribute("alt").value.gsub(/ stars*/,"")
      end

      bodies = []
      document.css('TextView[styleSet="normal11"]').each do |elm|
        bodies.push(elm.text.gsub("\n", "<br />"))
      end

      count = stars.size - 1
      (0..count).each do |key|
        item = {
          :star => stars[key],
          :user => users[key],
          :date => dates[key],
          :title => titles[key],
          :body => bodies[key],
          :version => versions[key],
          :app_id => @app_id
        }
        items.push(item)
      end
      return items
    end

    def get_version(text)
      version = nil
      if /Version([\d\.]+)/ =~ text
        version = $1
      end
      return version
    end

  end
end
