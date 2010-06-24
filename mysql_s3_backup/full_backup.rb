#!/usr/bin/env ruby

require "common"

begin
  FileUtils.mkdir_p @temp_dir

  dump_file = "#{@temp_dir}/#{Date.today.to_s}.dump.sql.gz"
  
  cmd = "mysqldump -u#{@mysql_user}"
  cmd += " -p'#{@mysql_password}'" unless @mysql_password.nil?
  cmd += " --host=#{@mysql_host}"
  cmd += " #{@mysql_database} | gzip > #{dump_file}"
  run(cmd)
  
  AWS::S3::S3Object.store(File.basename(dump_file), open(dump_file), @s3_bucket)
  AWS::S3::S3Object.delete("#{(Date.today - (@backups_to_keep * @backup_runs_every)).to_s}.dump.sql.gz", @s3_bucket)
ensure
  FileUtils.rm_rf(@temp_dir)
end
