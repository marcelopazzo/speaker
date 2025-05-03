class SmartTyper
  def initialize(user)
    @user = user
    @client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: Rails.application.credentials.google.api_key,
        version: "v1beta"
      },
      options: { model: "gemini-2.0-flash", server_sent_events: true }
    )
  end

  def suggest_completion(text:)
    prompt = build_prompt(text)

    result = @client.generate_content({
      contents: {
        role: "user",
        parts: { text: prompt }
      }
    })

    Rails.logger.info("Prompt: #{prompt}")
    Rails.logger.info("Result: #{result}")

    parse_response(result)
  end

  private

  def build_prompt(text)
    <<~PROMPT
      You are a smart phrase completion assistant for a patient with
      Amyotrophic lateral sclerosis (ALS) with a speech impairment.
      Your task is to:
      1. Guess the full phrase based on the given partial phrase
      2. Fix any typos in the phrase
      3. Always use Brazilian Portuguese
      4. Return a JSON object with the following keys:
        - text: The full phrase if you can guess it;
        - confidence: A confidence score between 0 and 1

      Provided partial text: #{text}

      Please guess the full phrase naturally and fix any typos.
      Return ONLY the raw JSON object without any markdown formatting, code blocks, or additional text.
      Example of expected response: {"text":"mensagem completa","confidence":0.95}

      These are examples of the most common phrases:
      #{most_common_phrases}
    PROMPT
  end

  def most_common_phrases
    @user.audio_files.order(use_count: :desc).limit(10).pluck(:text).join("\n")
  end

  def parse_response(response)
    response_text = response.dig("candidates", 0, "content", "parts", 0, "text").to_s.strip

    # Try to extract JSON from markdown code blocks if present
    if response_text.start_with?("```json") || response_text.start_with?("```")
      response_text = response_text.gsub(/```json\n?|\n?```/, "").strip
    end

    begin
      JSON.parse(response_text)
    rescue JSON::ParserError
      {
        text: response_text,
        confidence: 0.0
      }
    end
  end
end
