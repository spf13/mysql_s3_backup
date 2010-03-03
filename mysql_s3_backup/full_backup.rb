#!/usr/bin/env ruby

require "common"

def delete_old_backups(file_name)
  S3Object.delete file_name, @s3_bucket
end

begin
  FileUtils.mkdir_p @temp_dir

  dump_file = "#{@temp_dir}/#{Date.today.to_s}dump.sql.gz"
  
  cmd = "mysqldump --quick --single-transaction --create-options -u#{@mysql_user}  --flush-logs --master-data=2 --delete-master-logs"
  cmd += " -p'#{@mysql_password}'" unless @mysql_password.nil?
  cmd += " #{@mysql_database} | gzip > #{dump_file}"
  run(cmd)
  
  AWS::S3::S3Object.store(File.basename(dump_file), open(dump_file), @s3_bucket)
  
  delete_old_backup((Date.today - (@backups_to_keep * @backup_runs_every)).to_s)
ensure
  FileUtils.rm_rf(@temp_dir)
end
