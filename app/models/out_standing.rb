class OutStanding < ActiveRecord::Base
  attr_accessible :room,:room_type,:gst_type,:gst_name,:arvl_at,
                  :dpt_at,:room_rate,:ext_bed_rate,:folio,:credit, :report
end
