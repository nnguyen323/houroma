class ChartsController < ApplicationController
  before_action :logged_in_user,   only: [:live_tracked, :total_time, :user_signup, :nest_time, :weekly_time]

  def active_users
    # needs to be in this form {"activity1":7,"activity2":1}
    # database queries give you an array of hashes
    result = {}
    Action.joins(:activities)
      .where("activities.finished_at IS NULL")
      .select("actions.content", "COUNT(*) as weight")
      .group("actions.id")
      .order("weight DESC")
      .limit(8).each { |dat|
        result[dat.content] = dat.weight
      }
    
     render json:result
  end

  def user_signup
    if current_user.admin?
      render json: User.group_by_day(:created_at).count
    end
  end

  #for word cloud in form {text: "a", weight: 3, link: "http://...com/", html: {title: "I have html"}}
  #logged in user home page
  def live_tracked
    result = []

    cnt = current_user.activity.action.content if current_user.active
    found = false

    Action.joins(activities: {user: :trackers})
      .where("users.active_id = activities.id and tracker_id = ? and users.active", current_user.id)
      .select("actions.content, COUNT(*) AS weight")
      .group("actions.id")
      .order("weight DESC")
      .limit(10).each { |dat| 
        found = true  if dat.content == cnt
        result.push({ text: dat.content, weight: dat.weight + (dat.content == cnt ? 1 : 0), link: "/lounges/#{dat.content}/"})
    }
    result.push({text: cnt, weight: 1, link: "/lounges/#{cnt}/"}) if cnt and !found and result.count < 10
    render json: result
  end

  def timeline_from_day
    result = []
    date = params[:date] || 24.hours.ago
    user = User.find_by_username(params[:username])
    #1441 minutes is one minute over 24 hours
    #checking exactly 24 hours obviously won't work as time is constantly pushing ahead!
    if (user and (current_user? user or date > 1441.minutes.ago))
      Activity.where("(finished_at > ? OR created_at > ?) AND user_id = ?", date, date, user.id).each do |a|
        result.push(
          [a.action.content.capitalize,
           a.created_at < date ? date : a.created_at,
           a.finished_at || Time.now]
          )
      end
      if result.count == 0
        result = [["No data since #{date}",0,1]]
      end  
    else
      result = [["Only can access a users data into the past 24 hours",0,1]]
    end

    render json: result
  end

  def last_activities
    result = []
    user = User.find_by_username(params[:username])
    if (user)
      Activity.where("user_id = ?", user.id).order("created_at DESC").limit(4).each do |a|
        result.push(
          [a.action.content.capitalize,
           a.created_at,
           a.finished_at || Time.now]
          )
      end
      if result.count == 0
        result = [["No Data",0,1]]
      end  
    else
      result = [["Invalid User",0,1]]
    end

    render json: result
  end
  
  def weekly_time
    result = []
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
        result.push([d.content.capitalize, ((d.total_time)/3600.0).round(1)])
      end
    render json: result
  end

  def total_time
    result = []
    Action.joins(:activities)
      .where('user_id = ?', current_user.id)
      .select("actions.id, actions.content AS content, 
        EXTRACT(EPOCH FROM SUM(
          CASE WHEN (activities.finished_at IS NOT NULL)
               THEN (activities.finished_at - activities.created_at)
               ELSE (current_timestamp - activities.created_at)
          END )) AS total_time")
      .group('actions.id')
      .order('total_time DESC')
      .limit(8).each do |d|
        result.push([d.content.capitalize, ((d.total_time)/3600.0).round(1)])
      end                 
    render json: result
  end

  def nest_time
    nest = current_user.nests.find(params[:nest_id])
    result = {}

    if nest
      if params[:date]
        date = DateTime.parse(params[:date]).utc.iso8601
      
        if !(date || date.kind_of?(Date) || date.kind_of?(Time))
          render json:result
          return false
        end

        nest.nesting_users.joins(:activities)
          .where('activities.action_id = ? AND (activities.created_at > ? OR activities.finished_at > ? OR activities.finished_at IS NULL)', nest.action_id, date, date)
          .select("username, activities.user_id,
                EXTRACT(EPOCH FROM SUM(
                  CASE WHEN (activities.created_at > #{Activity.sanitize(date)} AND activities.finished_at IS NOT NULL)
                       THEN (activities.finished_at - activities.created_at)
                       
                       WHEN (activities.created_at <= #{Activity.sanitize(date)} AND activities.finished_at IS NOT NULL)
                       THEN (activities.finished_at - #{Activity.sanitize(date)})

                       WHEN (activities.finished_at IS NULL AND activities.created_at > #{Activity.sanitize(date)})
                       THEN (current_timestamp - activities.created_at)

                       ELSE (current_timestamp - #{Activity.sanitize(date)})
                  END )) AS total_time")
          .group('activities.user_id','username')
          .limit(8).each do |d|
            result[d.username] = (d.total_time/3600.0).round(1)
          end
      else
        nest.nesting_users.joins(:activities)
          .where('activities.action_id = ?', nest.action_id)
          .select('username, activities.user_id, EXTRACT(EPOCH FROM 
            sum(
              activities.finished_at - activities.created_at)) AS total_time')
          .group('activities.user_id','username')
          .limit(8).each do |d|
            user = User.find(d.user_id)
            addActive = 0.0
            if user.active and user.activity.action_id == nest.action_id
              addActive = Time.now - user.activity.created_at
            end

            result[d.username] = ((addActive + (d.total_time ? d.total_time : 0))/3600.0).round(1)
        end
      end

      render json: result
    end

  end
end