module DateHelper
    def datetime_datesql(dt)
        dt = dt.split(" ")
        dt = dt[0].split("/")
        "#{dt[2]}-#{dt[1]}-#{dt[0]}"
      rescue
        ""
      end
      
      
      def datetime_datetimesql(dt)
        dt = dt.split(" ")
        d = dt[0].split("/")
        t = dt[1].split(":")
        "#{d[2]}-#{d[1]}-#{d[0]} #{t[0]}:#{t[1]}"
      rescue
        ""
      end
      
      
      def date_dateform(dt)
        "#{"%02d" % dt.day}/#{"%02d" % dt.mon}/#{dt.year}"
      rescue
        ""
      end
      
      def date_dateform_sh(dt)
        "#{"%02d" % dt.day}/#{"%02d" % dt.mon}/#{dt.year.to_s[2..3]}"
      rescue
        ""
      end
      
      def datetime_datetimeform(dt)
        "#{"%02d" % dt.day}/#{"%02d" % dt.mon}/#{dt.year} #{"%02d" % dt.hour}:#{"%02d" % dt.min}"
      rescue
        ""
      end
      
      def date_datesql(dt)
        dt = dt.split("/")
        "#{dt[2]}-#{dt[1]}-#{dt[0]}"
      rescue
        ""
      end
      
      def dateform_date(dt)
        dt = dt.split("/")
        Time.new(dt[2].to_i, dt[1].to_i, dt[0].to_i)
      rescue
        ""
      end
end
