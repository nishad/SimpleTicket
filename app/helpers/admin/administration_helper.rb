module Admin::AdministrationHelper
  require 'find'
  
  def get_notification_mailer_files
    dirs = ["#{RAILS_ROOT}/app/views/notification_mailer/"]
    excludes = [".svn"]
    files = []
    for dir in dirs
      Find.find(dir) do |path|
        if FileTest.directory?(path)
          if excludes.include?(File.basename(path))
            Find.prune       # Don't look any further into this directory.
          else
            next
          end
        else
          files << path
        end
      end
    end
    return files
  end
  
end
