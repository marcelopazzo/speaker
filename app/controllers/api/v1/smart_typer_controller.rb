module Api
  module V1
    class SmartTyperController < ApplicationController
      def suggest
        smart_typer = SmartTyper.new(current_user)
        result = smart_typer.suggest_completion(
          text: params[:text],
        )

        render json: result
      end
    end
  end
end
