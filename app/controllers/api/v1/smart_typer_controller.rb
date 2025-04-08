module Api
  module V1
    class SmartTyperController < ApplicationController
      def suggest
        smart_typer = SmartTyper.new
        result = smart_typer.suggest_completion(
          partial_text: params[:text],
          context: params[:context]
        )

        render json: result
      end
    end
  end
end
