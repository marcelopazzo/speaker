require "http"

class TextReader
  ELEVENLABS_FQDN = "https://api.elevenlabs.io"

  # Default parameters
  DEFAULT_STABILITY = ENV["DEFAULT_STABILITY"] || 0.5
  DEFAULT_SIMILARITY_BOOST = ENV["DEFAULT_SIMILARITY_BOOST"] || 0.75
  DEFAULT_STYLE = ENV["DEFAULT_STYLE"] || 0.5
  DEFAULT_SPEED = ENV["DEFAULT_SPEED"] || 0.8
  DEFAULT_MODEL = ENV["DEFAULT_MODEL"] || "eleven_multilingual_v2"

  def initialize
    @api_key = Rails.application.credentials.elevenlabs.api_key
    @voice_id = Rails.application.credentials.elevenlabs.voice_id
  end

  def text_to_speech(text:)
    begin
      # Ensure text is properly encoded in UTF-8
      text = text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      Rails.logger.info("Converting to speech: #{text}")

      body = {
        text: text,
        model_id: DEFAULT_MODEL,
        voice_settings: {
          stability: DEFAULT_STABILITY,
          similarity_boost: DEFAULT_SIMILARITY_BOOST,
          style: DEFAULT_STYLE,
          speed: DEFAULT_SPEED
        }
      }

      url_path = "#{ELEVENLABS_FQDN}/v1/text-to-speech/#{@voice_id}"

      audio_content = authorized_http_client
        .post(url_path, json: body)
        .to_s

      # Generate a unique filename
      filename = "speech_#{SecureRandom.uuid}.mp3"
      filepath = Rails.root.join("tmp", filename)

      # Save the audio file in binary mode
      File.open(filepath, "wb") do |file|
        file.write(audio_content)
      end

      # Return the filename for the controller to use
      filepath
    rescue => e
      Rails.logger.error("ElevenLabs API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      nil
    end
  end

  private

  def authorized_http_client
    HTTP.headers('xi-api-key': @api_key)
  end
end
