class SmartTyper
  def initialize
    @client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: ENV["GOOGLE_API_KEY"],
        version: "v1beta"
      },
      options: { model: "gemini-2.0-flash", server_sent_events: true }
    )
  end

  def suggest_completion(partial_text:, context: nil)
    prompt = build_prompt(partial_text, context)

    result = @client.generate_content({
      contents: {
        role: "user",
        parts: { text: prompt }
      }
    })

    parse_response(result)
  end

  private

  def build_prompt(partial_text, context)
    <<~PROMPT
      You are a smart text completion assistant for a patient with
      Amyotrophic lateral sclerosis (ALS) with a speech impairment.
      Your task is to:
      1. Complete the given partial text in a natural way
      2. Fix any typos in the text
      3. Consider the context if provided
      4. Always use Brazilian Portuguese
      5. Return a JSON object with the following keys:
        - text: The completed text if you can complete it;
        - word: The full word you are completing;
        - confidence: A confidence score between 0 and 1

      Context: #{context || 'No specific context provided'}
      Partial text: #{partial_text}

      Please complete the text naturally and fix any typos.
      Return ONLY the raw JSON object without any markdown formatting, code blocks, or additional text.
      Example of expected response: {"text":"completo","word":"palavra","confidence":0.95}
    PROMPT
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
        word: "",
        confidence: 0.0
      }
    end
  end
end
