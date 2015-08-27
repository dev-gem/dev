puts __FILE__ if defined?(DEBUG)

#
# 
#
class Wix
	def self.get_build_commands wxs_file
      build_commands=nil
      if(File.exists?(wxs_file))
            ext='msi'
            ext='exe' if(IO.read(wxs_file).include?('<Bundle'))
            extensions=''
            ['WixNetFxExtension','WixBalExtension','WixUtilExtension','WixUiExtension'].each{|e|
                  extensions="#{extensions}-ext e "
            }
      	build_commands=Array.new if build_commands.nil?
      	build_commands << "candle #{wxs_file} #{extensions}"
            
      	if(defined?(VERSION))
      		build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj -out #{File.basename(wxs_file,'.*')}-#{VERSION}.#{ext} #{extensions}"
      	else
      		build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj #{extensions}"
      	end
      end
      build_commands
    end
end
