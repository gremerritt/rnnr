require 'faraday'
require 'launchy'
require 'yaml'
require 'json'
require 'time'
require 'mail'

module Rnnr
  def self.send options
    begin
      @config_dir = File.expand_path(options.config_dir)
      load_config

      today = DateTime.now
      today_start = DateTime.new(today.year, today.month, today.day)
      last_sunday = today_start - today_start.wday

      conn = Faraday.new(:url => 'https://api.ua.com')
      resp = conn.get do |req|
        req.url "/v7.1/workout/"\
                "?user=#{@config[:user]}"\
                "&updated_after=#{Time.new(Time.now.year).utc.iso8601}"

        req.headers['Authorization'] = "Bearer #{@config[:auth]}"
        req.headers['Api-Key'] = @config[:key]
      end

      if resp.status == 200
        body = JSON.parse(resp.body)
        yearly_distance = 0.0
        weekly_distance = 0.0
        body['_embedded']['workouts'].each do |workout|
          yearly_distance += workout['aggregates']['distance_total']

          date = DateTime.parse(workout['start_datetime'])
          if date > last_sunday
            weekly_distance += workout['aggregates']['distance_total']
          end
        end
        yearly_distance = yearly_distance.to_miles.round(2)
        weekly_distance = weekly_distance.to_miles.round(2)
        milesperday     = (yearly_distance / (Date.today.yday - options.offset)).round(2)

        rslt_str = "Yearly:    #{yearly_distance}"\
                   "\nWeekly:    #{weekly_distance}"\
                   "\nMiles/Day: #{milesperday}"\

        if options.email == 'true'
          send_email rslt_str
        else
          puts rslt_str
        end
      else
        raise "Unable to retrieve workout data"
      end
    rescue StandardError => msg
      log msg
      return
    end
  end

  def self.auth
    begin
      @config = load_config_file

      url = "https://www.mapmyfitness.com/v7.1/oauth2/uacf/authorize/"
      url << "?client_id=#{@config[:key]}"
      url << "&response_type=code"
      resp = Faraday.get url
      if resp.status == 302
        Launchy.open(resp.headers["location"])
        code = ask("Enter the code: ")

        conn = Faraday.new(:url => 'https://api.ua.com')
        resp = conn.post do |req|
          req.url "/v7.1/oauth2/uacf/access_token/"
          req.body = "grant_type=authorization_code"\
                     "&client_id=#{@config[:key]}"\
                     "&client_secret=#{@config[:secret]}"\
                     "&code=#{code}"
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.headers['Api-Key'] = @config[:key]
        end

        if resp.status == 200
          update_config resp
          puts "SUCCESS!"
        else
          puts "FAILED."
        end
      else
        puts "FAILED. CHECK 'MAPMYRUN_KEY ENV VARIABLE.'"
      end
    rescue Interrupt => msg
      puts "Quitting..."
    rescue StandardError => msg
      puts "Error: #{msg}"
    end
  end

  def self.load_config
    @config = load_config_file

    if @config[:expire] < Time.now.to_i
      conn = Faraday.new(:url => 'https://api.ua.com')
      resp = conn.post do |req|
        req.url "/v7.1/oauth2/uacf/access_token/"
        req.body = "grant_type=refresh_token"\
                   "&client_id=#{@config[:key]}"\
                   "&client_secret=#{@config[:secret]}"\
                   "&refresh_token=#{@config[:refresh]}"
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Api-Key'] = @config[:key]
      end

      if resp.status == 200
        update_config resp
      else
        raise "Unable to retrieve access token"
      end
    end
  end

  def self.update_config resp
    body = JSON.parse(resp.body)
    @config[:refresh] = body['refresh_token']
    @config[:auth]    = body['access_token']
    @config[:user]    = body['user_id']
    @config[:expire]  = (Time.now.to_i + body['expires_in'])
    save_config_file
  end

  def self.load_config_file
    config_file = File.join(@config_dir, '.rnnr_config.yml')
    if !File.exists?(config_file)
      config = {
                :key    => ENV['MAPMYRUN_KEY'],
                :secret => ENV['MAPMYRUN_SECRET']
               }
    else
      config = YAML.load_file(config_file)
    end
    return config
  end

  def self.save_config_file
    File.open(File.join(@config_dir, '.rnnr_config.yml'), "w+") do |f|
      f.write @config.to_yaml
    end
  end

  def self.send_email content
    to_email = @config[:email][:to]
    from_email = @config[:email][:username]
    begin
      options = { :address              => "smtp.gmail.com",
                  :port                 => 587,
                  :user_name            => @config[:email][:username],
                  :password             => @config[:email][:password],
                  :authentication       => 'plain',
                  :enable_starttls_auto => true  }

      Mail.defaults do
        delivery_method :smtp, options
      end

      Mail.deliver do
         to to_email
         from from_email
         subject "Running Summary #{Date.today.strftime('%b %e, %Y')}"
         body content
      end
    rescue StandardError => msg
      puts "mail error: #{msg}"
    end
  end
end

class Float
  def to_miles
    self * 0.000621371
  end
end
