require "net/http"
require "json"
require "base64"

class GeminiCaptionService
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def initialize(image_record)
    @image_record = image_record
  end

  def generate_captions
    api_key = ENV["GEMINI_API_KEY"]
    raise "API key not set" if api_key.blank?

    blob = @image_record.image.blob
    image_data = blob.download
    base64_image = Base64.strict_encode64(image_data)
    mime_type = blob.content_type

    uri = URI("#{API_URL}?key=#{api_key}")

    body = {
      contents: [
        {
          parts: [
            {
              inline_data: {
                mime_type: mime_type,
                data: base64_image
              }
            },
            {
              text: "Generate exactly 3 creative, descriptive captions for this image. Return ONLY a JSON array of 3 strings, no other text. Example: [\"caption 1\", \"caption 2\", \"caption 3\"]"
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.8,
        maxOutputTokens: 256
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Gemini API error: #{response.code} - #{response.body}")
      raise "Gemini API request failed with status #{response.code}"
    end

    parse_captions(response.body)
  end

  private

  def parse_captions(response_body)
    data = JSON.parse(response_body)
    text = data.dig("candidates", 0, "content", "parts", 0, "text")

    raise "No text in Gemini response" if text.blank?

    json_match = text.match(/\[.*\]/m)
    raise "Could not parse captions from Gemini response: #{text}" unless json_match

    captions = JSON.parse(json_match[0])

    unless captions.is_a?(Array) && captions.length >= 3
      raise "Expected 3 captions, got: #{captions.inspect}"
    end

    captions.first(3).map(&:to_s)
  end
end
