class CreateInputTypes < ActiveRecord::Migration
  def change
    create_table :input_types do |t|
      t.string :tel
      t.integer :nation_id
      t.integer :agent_id
      t.integer :gst_type_id
      t.integer :gst_level_id
      t.integer :src_gst_id
      t.integer :prpt_grp_id
      t.integer :rsvt_type_id
      t.integer :rsvt_status_id
      t.integer :adult
      t.integer :child
      t.integer :night
      t.datetime :arvl_at
      t.datetime :dpt_at
      t.integer :input_by
      t.string :location
      t.integer :rate_code_id
      t.string  :ref
      t.text    :remark
      t.integer :hotel_src_id
      t.integer :contact_id
      t.string  :type
      t.string :stay_status, limit: 1
      
      t.timestamps
    end
  end
end
