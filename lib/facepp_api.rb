class FaceppApi
  class << self

    def ocr_id_card(type, image)
      result = http_call ocr_id_card_url, {
        image_file: File.new(image, 'rb')
      }

      if result["cards"] && result["cards"].any?
        send "parse_from_#{type}", result["cards"].first
      elsif result["error_message"]
        {error_message: result["error_message"]}
      else
        {error_message: "No cards"}
      end
    end

    def compare(image1, image2)
      result = http_call compare_url, {
        image_file1: File.new(image1, 'rb'),
        image_file2: File.new(image2, 'rb')
      }

      if result["confidence"]
        if result["confidence"].to_i > SiteSetting.facepp_compare_confidence
          {confidence: result["confidence"]}
        else
          {error_message: "Not same person", confidence: result["confidence"]}
        end
      elsif result["error_message"]
        {error_message: result["error_message"]}
      else
        {error_message: "No faces"}
      end
    end

    protected

    def parse_from_front(card)
      if card["side"] == "front" && card["name"] && card["id_card_number"]
        {name: card["name"], id_card_number: card["id_card_number"]}
      else
        {error_message: "Parse from id card front failed"}
      end
    end

    def parse_from_back(card)
      if card["side"] == "back" && card["valid_date"]
        expire_time = Time.new *card["valid_date"].split('-').last.split('.')
        if expire_time > Time.now + 3*30*24*60*60
          {issued_by: card["issued_by"]}
        else
          {error_message: "ID card is expired"}
        end
      else
        {error_message: "Parse from id card back failed"}
      end
    end

    def http_call(url, params)
      response = begin
        RestClient.post url, params.merge({
            api_key: SiteSetting.facepp_app_key,
            api_secret: SiteSetting.facepp_app_secret
          })
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end

      begin
        JSON.parse response
      rescue JSON::ParserError
        {"error_message": response.body}
      end
    end

    def ocr_id_card_url
      "https://api-cn.faceplusplus.com/cardpp/v1/ocridcard"
    end

    def compare_url
      "https://api-cn.faceplusplus.com/facepp/v3/compare"
    end

  end
end
