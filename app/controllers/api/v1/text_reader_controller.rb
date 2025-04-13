module Api
  module V1
    class TextReaderController < ApplicationController
      def speak
        # Check if we already have this text in our database
        audio_file = AudioFile.find_by(text: params[:text])

        if audio_file && File.exist?(audio_file.file_path)
          # Use existing file
          audio_file.increment_use_count!

          send_file(
            audio_file.file_path,
            filename: File.basename(audio_file.file_path),
            type: "audio/mpeg",
            disposition: "inline"
          )
        else
          # Generate new audio file
          reader = TextReader.new
          filename = reader.text_to_speech(text: params[:text])

          if filename
            # Move file to data directory
            source_path = Rails.root.join("tmp", filename)
            target_path = Rails.root.join("data", "audio", filename)
            FileUtils.mv(source_path, target_path)

            # Store the audio file information
            AudioFile.create!(
              file_path: target_path.to_s,
              text: params[:text]
            )

            # Send the file
            send_file(
              target_path,
              filename: filename,
              type: "audio/mpeg",
              disposition: "inline"
            )
          else
            render json: { error: "Failed to generate speech" }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
