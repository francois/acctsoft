namespace :backup do
  task :timestamp do
    $tstamp = Time.now.utc.strftime("%Y%m%d-%H%M")
  end

  desc "Dumps the *production* database to db/.  After this task, you can count on a symlink named db/production.sql.gz pointing to the real dump"
  task :dump => :timestamp do
    filename = "db/acctsoft-production-#{$tstamp}.sql.gz"
    sh "mysqldump -u root acctsoft_production | gzip --fast > #{filename}"
    Dir.chdir("db") do
      sh "ln -nfs #{File.basename(filename)} production.sql.gz"
    end
  end

  desc "Pushes the latest (as determined by db/production.sql.gz symlink) dump to S3"
  task :push => :timestamp do
    filename = "production-#{$tstamp}.sql.gz"
    sh "clis3 put db/production.sql.gz teksol.info/acctsoft/#{filename}"
  end

  desc "Removes all backups from db/, including the latest symlink"
  task :clean do
    sh "rm db/db/production.sql.gz"
    sh "rm db/acctsoft-production-*.sql.gz"
  end

  namespace :load do
    task :prereqs do
      $dumpfile = ENV["DUMPFILE"]
      raise ArgumentError, "Could not find dumpfile name #{$dumpfile.inspect}.  Have you set DUMPFILE?" unless File.file?($dumpfile)
    end
  end

  desc "Loads a named backup (DUMPFILE) to the current environment's database.  This task is safe in that it backs up the database before loading."
  task :load => %w(backup:load:prereqs backup:dump db:drop db:create) do
    conn    = ActiveRecord::Base.connection
    config  = conn.instance_variable_get("@config")
    raise ArgumentError, "Unfortunately, ActiveRecord changed since this task was written.  I can't find the @config instance variable in AciveRecord::Base.connection.  I need @config to find the database name to connect to." if config.nil?

    command = case File.extname($dumpfile)
              when ".gz"
                "gzcat #{$dumpfile} | mysql -u root #{config[:database]}"
              else
                "mysql < #{$dumpfile} -u root #{config[:database]}"
              end
    sh command
  end
end

desc "Dumps the *production* database to db/.  See backup:dump, backup:push"
task :backup => %w(backup:dump backup:push)

desc "Recreates the current environment's database from the named backup (DUMPFILE)"
task :load   => %w(backup:load)
