module Rnnr
  def self.start
    puts "Creating agent"
    plist = plist_template
    plist_path = File.expand_path("~/Library/LaunchAgents/com.rnnr.plist")
    shell_script_path = File.expand_path("~/.rnnr.sh")
    File.write(plist_path, plist)
    File.write(shell_script_path, shell_script)

    puts "Launching agent"
    `chmod +x #{shell_script_path}`
    `launchctl load #{plist_path}`

    puts "Done!"
  end

  def self.plist_template
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
    "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" "\
    "\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"\
    "<plist version=\"1.0\">\n"\
    "<dict>\n"\
    "\t<key>Label</key>\n"\
    "\t<string>rnnr</string>\n"\
    "\t<key>ProgramArguments</key>\n"\
    "\t<array>\n"\
    "\t\t<string>#{File.expand_path('~/.rnnr.sh')}</string>\n"\
    "\t</array>\n"\
    "\t<key>StartCalendarInterval</key>\n"\
    "\t<array>\n"\
    "\t<!-- Run daily at 1:00 AM -->\n"\
    "\t\t<dict>\n"\
    "\t\t\t<key>Hour</key>\n"\
    "\t\t\t<integer>01</integer>\n"\
    "\t\t\t<key>Minute</key>\n"\
    "\t\t\t<integer>00</integer>\n"\
    "\t\t</dict>\n"\
    "\t</array>"\
    "\t<key>StandardOutPath</key>\n"\
    "\t<string>#{File.expand_path('~/.rnnr_stdout.log')}</string>\n"\
    "\t<key>StandardErrorPath</key>\n"\
    "\t<string>#{File.expand_path('~/.rnnr_stderr.log')}</string>\n"\
    "</dict>\n"\
    "</plist>"
  end

  def self.shell_script
    "#!/bin/sh\n"\
    "#{`which rnnr`.chomp} send --offset 1 --email true"
  end
end
