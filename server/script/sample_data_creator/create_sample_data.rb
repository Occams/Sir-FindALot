#!/usr/bin/env ruby
require 'parkinglot'
require 'concrete'

class CreateSampleData < ActiveRecord::Base
  operator = Operator.create(:email => "foo@bar.de", :name => "Foo Bar", :password => "password")
  if operator.nil?
    operator = Operator.find_by_email "foo@bar.de"
  end

  [
    ["Universität Passau",48.568188,13.453059],
    ["Krankenhaus Passau",48.563672,13.444476],
    ["Zentraltiefgarage Passau",48.573725,13.456213],
    ["Flughafen München P1",48.358587,11.751852],
    ["Flughafen München P2",48.345811,11.755543]
  ].each do |current|
    puts "Creating #{current[0]}"
    ramp = Parkingramp.create("name"=>current[0], "operator_id"=> operator.id, "category"=>"Tiefgarage", "info_status"=>"Offen - Kleine Bauarbeiten", "info_pricing"=>"Für Studenten kostenlos", "info_openinghours"=>"07:00 - 24:00 Wochentags\r\nGeschlossen am Wochenenden und Feiertags", "info_address"=>"Universität Passau\r\nInnstraße 14\r\n94032 Passau", "latitude"=>current[1], "longitude"=>current[2])
    ramp.parkingplanes << Parkingplane.create("name"=>"2. Etage")
    ramp.parkingplanes << Parkingplane.create("name"=>"1. Etage")
    
    ramp.parkingplanes.each do |plane|
      YAML::load(File.open("script/sample_data_creator/create_sample_lots_data.yml")).each do |l|
        plane.lots << Parkinglot.new(l.attributes)
      end
      plane.concretes << YAML::load(File.open("script/sample_data_creator/create_sample_concretes_data.yml")).each do |l|
        plane.concretes << Concrete.new(l.attributes)
      end
      
=begin     
      (Date.current.year-1).upto(Date.current.year-1) do |y|
        ydate = Date.new y, 1, 1
        ydate.month.upto(ydate.end_of_year.month) do |m|
          mdate = Date.new y, m, 1
          mdate.day.upto(mdate.end_of_month.day) do |d|
            0.upto(23) do |h|
              #Um 13 Uhr sind die meisten belegt +- Schwankung von max 15%
              taken = plane.taken_lots.count*(1-((13-h).abs ) / 15)*(1.15 - rand(30)/100)
              taken = [plane.taken_lots.count, taken].min
              Stat.create(:lots_taken => taken, :lots_total => plane.lots.count, :parkingplane_id => plane.id, :created_at => DateTime.new y, m, d , h, 30)
            end
          end
        end
      end
=end    
      
    end
    ramp.reset_cache_values
  end
end
