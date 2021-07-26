class CreateNightAudits < ActiveRecord::Migration
  def change
    create_table :night_audits do |t|
      t.date :at_date
      t.string :status

      t.timestamps
    end
  end
end
