require "rnnr/version"
require "send"
require "start"
require "commander/import"
require "logger"

module Rnnr
  @log = Logger.new(STDOUT)
  @log.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime.strftime('%F %R')} #{msg}\n"
  end

  def Rnnr.run
    program :name, 'Rnnr'
    program :version, Rnnr::VERSION
    program :description, 'Daily running reports'

    command :send do |c|
      c.syntax = 'rnnr send'
      c.description = 'Send email of year-to-date running total'
      c.option '--offset INTEGER', Integer, 'Offset for days in year'
      c.option '--email <true/false>', String, 'Send an email'
      c.option '--disp <true/false>', String, 'Print results to screen'
      c.option '--config_dir directory', String, 'Directory where your .rnnr_config.yml file lives'
      c.action do |args, options|
        options.default :offset => 0,
                        :email => 'false',
                        :disp => 'true',
                        :config_dir => "~/"
        Rnnr.send options
      end
    end

    command :auth do |c|
      c.syntax = 'rnnr auth'
      c.description = 'Authenticate the app'
      c.action do |args, options|
        Rnnr.auth
      end
    end

    command :start do |c|
      c.syntax = 'rnnr start'
      c.description = 'Create the launchd agents'
      c.action do |args, options|
        Rnnr.start
      end
    end
  end

  def self.log msg
    @log.info msg
  end
end
