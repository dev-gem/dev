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
      	build_commands=Array.new if build_commands.nil?
      	build_commands << "candle #{wxs_file} -ext WixNetFxExtension -ext WixBalExtension -ext WixUtilExtension"

      	if(defined?(VERSION))
      		build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj -out #{File.basename(wxs_file,'.*')}-#{VERSION}.#{ext} -ext WixNetFxExtension -ext WixBalExtension -ext WixUtilExtension"
      	else
      		build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj -ext WixNetFxExtension -ext WixBalExtension -ext WixUtilExtension"
      	end
      end
      build_commands
    end
end
