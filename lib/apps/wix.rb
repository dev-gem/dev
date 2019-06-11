if defined?(DEBUG)
      puts DELIMITER
      puts __FILE__
      puts
      puts 'candle not found' if(!Command.executes?('candle')) 
      puts 'light not found' if(!Command.executes?('light')) 
      puts
    end

#
# 
#
class Wix
      def self.get_build_commands wxs_file
            build_commands=nil
            if(File.exists?(wxs_file) && !defined?(NO_WIX))
            if(Environment.windows?)
                  ext='msi'
                  ext='exe' if(IO.read(wxs_file).include?('<Bundle'))
                  extensions=''
                  ['WixNetFxExtension','WixBalExtension','WixUtilExtension','WixUiExtension'].each{|e|
                        extensions="#{extensions}-ext #{e} "
                  }
                  build_commands=Array.new if build_commands.nil?
                  build_commands << "candle #{wxs_file} #{extensions}"
                  
                  if(defined?(VERSION))
                        build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj -out #{File.basename(wxs_file,'.*')}-#{VERSION}.#{ext} #{extensions}"
                  else
                        build_commands << "light #{File.basename(wxs_file,'.*')}.wixobj #{extensions}"
                  end
            end
            end
            build_commands
      end

      def self.set_component_files wxs_file, component_id, filenames
      end
end
