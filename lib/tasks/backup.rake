task :backup do
  puts "Backing up ***** production ***** database"

  tstamp = Time.now.utc.strftime("%Y%m%d-%H%M")
  filename = "backup-#{tstamp}.sql.gz"
  sh "mysqldump -u root acctsoft_ production | gzip --fast > tmp/#{filename}"
  sh "clis3 put tmp/#{filename} teksol.info/acctsoft/#{filename}"
  rm "tmp/#{filename}"
end
