task :backup do
  tstamp = Time.now.utc.strftime("%Y%m%d-%H%M")
  filename = "backup-#{tstamp}.sql.gz"
  sh "mysqldump -u root acctsoft_production | gzip --fast > tmp/#{filename}"
  sh "clis3 put tmp/#{filename} teksol.info/acctsoft/#{filename}"
  rm "tmp/#{filename}"
end
