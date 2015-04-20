# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-
class ApplicationController < ActionController::Base
  before_filter :login_required
  include ControllerAuthentication
  protect_from_forgery
  helper_method :get_shift, :time_overlap, :date_dateform, :date_dateform_sh, :datetime_datetimeform
  
  
  def get_shift
    now = Time.now  
    now = DateTime.new(now.year,now.mon,now.day,now.hour,now.min)  
    duration = [] 
    shift_id = nil 
    Shift.where(hotel_src_id: current_user.hotel_src_id, used: '1' ).each do |rs| 
      start_at = DateTime.new(now.year,now.mon,now.day,rs.start_at.hour,rs.start_at.min)
       end_at = DateTime.new(now.year,now.mon,now.day,rs.end_at.hour,rs.end_at.min)
       if start_at > end_at
         duration.push({
           start_at: start_at,
           end_at: end_at + 1,
           id: rs.id
         })
         duration.push({
           start_at: start_at - 1 ,
           end_at: end_at,
           id: rs.id
         })
       else
         duration.push({
           start_at: start_at,
           end_at: end_at,
           id: rs.id
         })
       end
   end
   duration.each do |rs|
     if rs[:start_at] <= now and rs[:end_at] > now 
       shift_id = rs[:id]
     end
   end
   shift_id
  end
    
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
 
  
  def time_overlap(st,en,fst,fen)
    "
      (date(#{fst}) between '#{st}' and '#{en}' or
      date(#{fen}) between '#{st}' and '#{en}' or
      (
              date(#{fst}) < '#{st}' and
              date(#{fen}) > '#{en}' 
      )
      or
      (
              date(#{fst}) > '#{st}' and
              date(#{fen}) < '#{en}' 
      )
      or
      (
              date(#{fst}) = '#{st}' and
              date(#{fen}) = '#{en}' 
      )
      or
      (
              date(#{fst}) > '#{st}' and
              date(#{fen}) = '#{en}' 
      )
      or
      (
              date(#{fst}) = '#{st}' and
              date(#{fen}) < '#{en}' 
      ))
    "
  end
  
  
  def share_payment(arr, money)
    new_arr = []
    money = money.round(2)
    arr.each {|a|
      a = a.round(2)
      new_money = 0.0
      if a < money or a == money
        new_money = a
      end
      if a > money
        new_money = money
      end
      money = money - new_money
      new_arr.push([a.to_f,new_money])
    }
    if money != 0
      new_money = (money / arr.length).round(2)
      new_arr.each{|a|
        a[1] += new_money
      }
    end
    new_arr
  rescue
    []
  end


    
end
