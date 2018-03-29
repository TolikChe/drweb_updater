require 'net/ftp'
require 'zip/zip'

#
# ������� ������� ���� � ���������� �������
#

##############################################################
# ������ ����������
type = "ftp"
address = "ftp.drweb.com"
directory = "/pub/drweb/bases/700"
login = "anonymous"
password = "anonymous"
zip_files =   "zips"
unzip_files = "unzips"
drweb_path = "C:/Program Files/DrWeb"
###############################################################
#
# �������� ����� ���� ����� �������� ������
Dir::mkdir(zip_files) unless File.exists?(zip_files)
#
# �������� ����� ���� ����� �������� ����������������� �����
Dir::mkdir(unzip_files) unless File.exists?(unzip_files)

#
# ������ �����
puts ""
puts "Clear #{zip_files}"
Dir.chdir zip_files
Dir.glob('*.*').each do|f|
 puts f
 FileUtils.rm(f)
end
#
puts ""
puts "Clear #{unzip_files}"
Dir.chdir "..//" + unzip_files
Dir.glob('*.*').each do|f|
 puts f
 FileUtils.rm(f)
end
#
# �������� � ������
Dir.chdir "..//"
#
# ������� �����
puts "Get files from ftp: #{address} to #{zip_files}"
#
# ���������� � ������� �����
ftp=Net::FTP.new
# ����������� � ������
ftp.connect(address,21)
# ���������� ����� � ������ 
ftp.login(login,password)
# �������� �� ���������� ����
ftp.chdir(directory)
# ������� ������ ������ �� FTP
files = ftp.nlst
# �������� � ����� � ��������
Dir.chdir zip_files
# �������� �� ������� ������ � ��������� ��� ����� vrcpp.zip
files.each_with_index do |value,index| 
  # ������� ������ ����
  if value =~ /^(dwr|dwn|drw|dwf)\S+/ and value != "drweb32.zip" then
	filesize = ftp.size(value)
    puts "#{index+1}. Download #{value}, file size: #{(filesize/1024)/1024} Mb"
	ftp.getbinaryfile(value)
  end
end
# ������� ����������
ftp.close
#
# ������������� �����
puts ""
puts "Unzip files to #{unzip_files}"
#
files.each_with_index do |value,index| 
	if value =~ /^(dwr|dwn|drw|dwf)\S+/ and value != "drweb32.zip" then
		puts "#{index+1}. Unzip #{value}"
		Zip::ZipFile.open(value) { |zip_file|
			zip_file.each { |f|
				f_path=File.join("..//"+unzip_files, f.name)
				FileUtils.mkdir_p(File.dirname(f_path))
				zip_file.extract(f, f_path) unless File.exist?(f_path)
			}
		}
	end
end

#
# �������� ����� �� ����� � ������������������ ������ � ����� ����������

puts ""
puts "Copy files from #{unzip_files} to #{drweb_path}"
Dir.chdir("..//"+unzip_files)
Dir.glob('*.*').each do|f|
	puts "Copy #{f} to #{drweb_path}"	
	FileUtils.cp(f, drweb_path, :verbose => true)
end
