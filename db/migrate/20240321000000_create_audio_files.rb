class CreateAudioFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :audio_files do |t|
      t.string :file_path, null: false
      t.text :text, null: false
      t.integer :use_count, null: false, default: 1
      t.timestamps
    end
  end
end
