#!/usr/bin/env ruby
require 'parkinglot'
require 'concrete'

class CreateSampleData < ActiveRecord::Base
  Parkingplane.all.each do |plane|
    takenlotscount = plane.taken_lots.count
    totalcount = plane.lots.count
    d = (Time.now - 4.weeks)
    0.upto(4*7).each do |i|
      c = d+i.days
      0.upto(24).each do |h|
        t = c.beginning_of_day + h.hours + 30.minutes
        #some variation
        taken = totalcount*(1-((13-h).abs ) / 15.to_f)*(1 - rand(30)/100.to_f)
        taken = [totalcount.floor, taken].min
        Stat.create(:lots_taken => taken, :lots_total => totalcount, :parkingplane_id => plane.id, :created_at => DateTime.new(t.year, t.month, t.day , t.hour, 30))
      end
    end
  end
end
