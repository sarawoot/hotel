# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-
class ApplicationController < ActionController::Base
  before_filter :login_required
  include ControllerAuthentication
  include DateHelper
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
end
