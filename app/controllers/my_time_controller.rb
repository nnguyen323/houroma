class MyTimeController < ApplicationController
  before_action :logged_in_user,  only: [:index]
  def index
    @total_hours = 0

    Activity.where('user_id = ?', current_user.id)
      .select("EXTRACT(EPOCH FROM SUM(
        CASE WHEN (activities.finished_at IS NOT NULL)
             THEN (activities.finished_at - activities.created_at)

             ELSE (current_timestamp - activities.created_at)
        END )) AS total")
    .group("user_id")
    .except(:order).each do |d|
      @total_hours = (d.total/3600.0).round(0)
    end

    @week_data = []
    date = 7.days.ago.utc.iso8601

    Action.joins(:activities)
      .where('user_id = ? AND (activities.created_at > ? OR activities.finished_at > ? OR activities.finished_at IS NULL)', current_user.id, date, date)
      .select("actions.id, actions.content AS content, 
        EXTRACT(EPOCH FROM SUM(
          CASE WHEN (activities.created_at > #{Activity.sanitize(date)} AND activities.finished_at IS NOT NULL)
               THEN (activities.finished_at - activities.created_at)
               
               WHEN (activities.created_at <= #{Activity.sanitize(date)} AND activities.finished_at IS NOT NULL)
               THEN (activities.finished_at - #{Activity.sanitize(date)})

               WHEN (activities.finished_at IS NULL AND activities.created_at > #{Activity.sanitize(date)})
               THEN (current_timestamp - activities.created_at)

               ELSE (current_timestamp - #{Activity.sanitize(date)})
          END )) AS total_time")
      .group('actions.id')
      .order('total_time DESC')
      .limit(8).each do |d|
        @week_data.push({content: d.content, total_time: ((d.total_time)/3600.0).round(1)})
      end

    @day_data = []
    date_today = 1.day.ago.utc.iso8601
    Action.joins(:activities)
      .where('user_id = ? AND (activities.created_at > ? OR activities.finished_at > ? OR activities.finished_at IS NULL)', current_user.id, date_today, date_today)
      .select("actions.id, actions.content AS content, 
        EXTRACT(EPOCH FROM SUM(
          CASE WHEN (activities.created_at > #{Activity.sanitize(date_today)} AND activities.finished_at IS NOT NULL)
               THEN (activities.finished_at - activities.created_at)
               
               WHEN (activities.created_at <= #{Activity.sanitize(date_today)} AND activities.finished_at IS NOT NULL)
               THEN (activities.finished_at - #{Activity.sanitize(date_today)})

               WHEN (activities.finished_at IS NULL AND activities.created_at > #{Activity.sanitize(date_today)})
               THEN (current_timestamp - activities.created_at)

               ELSE (current_timestamp - #{Activity.sanitize(date_today)})
          END )) AS total_time")
      .group('actions.id')
      .order('total_time DESC')
      .limit(8).each do |d|
        @day_data.push({content: d.content, total_time: ((d.total_time)/3600.0).round(1)})
      end        
  end
end