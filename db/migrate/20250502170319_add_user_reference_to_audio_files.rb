class AddUserReferenceToAudioFiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :audio_files, :user, null: false, foreign_key: true
  end
end
