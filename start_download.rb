require 'net/ftp'
require 'zip/zip'

#
# Попытка скачать файл с указанного ресурса
#

##############################################################
# Заявим переменные
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
# Создадим папку куда будут кидаться архивы
Dir::mkdir(zip_files) unless File.exists?(zip_files)
#
# Создадим папку куда будут кидаться разархивированные файлы
Dir::mkdir(unzip_files) unless File.exists?(unzip_files)

#
# Чистим папки
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
# Вернемся в корень
Dir.chdir "..//"
#
# Выведем адрес
puts "Get files from ftp: #{address} to #{zip_files}"
#
# Соединимся и скачаем файлы
ftp=Net::FTP.new
# Подключимся к адресу
ftp.connect(address,21)
# Используем логин и пароль 
ftp.login(login,password)
# Перейдем по указанному пути
ftp.chdir(directory)
# получим список файлов на FTP
files = ftp.nlst
# Перейдем в папку с архивами
Dir.chdir zip_files
# Проходим по массиву файлов и скачиваем все кроме vrcpp.zip
files.each_with_index do |value,index| 
  # Скачаем нужный файл
  if value =~ /^(dwr|dwn|drw|dwf)\S+/ and value != "drweb32.zip" then
	filesize = ftp.size(value)
    puts "#{index+1}. Download #{value}, file size: #{(filesize/1024)/1024} Mb"
	ftp.getbinaryfile(value)
  end
end
# Закроем соединение
ftp.close
#
# Разархивируем файлы
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
# Копируем файлы из папки с разархивированными базами в папку антивируса

puts ""
puts "Copy files from #{unzip_files} to #{drweb_path}"
Dir.chdir("..//"+unzip_files)
Dir.glob('*.*').each do|f|
	puts "Copy #{f} to #{drweb_path}"	
	FileUtils.cp(f, drweb_path, :verbose => true)
end
