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

      def self.get_wix_with_files wxs_template_text, component_id, filenames
            # <Component[-\s\w="]+Id="ApplicationFiles"[-"\s\w=]+>([-<="\/.>\s\w]+)<\/C
            search=wxs_template_text.scan(/<Component[-\s\w="]+Id="ApplicationFiles"[-"\s\w=]+>([-<="\/.>\s\w]+)<\/C/)[0][0]
            replace=''#bin/a.dll''
            index = 0
            filenames.each{|f|
                  replace += "<File Id=\"#{component_id}#{index}\" Source=\"#{f}\"/>\r\n"
                  index += 1
            }
            wxs_template_text.gsub(search,replace)
            #`git branch`.scan(/\* ([.\w-]+)/)[0][0] if(File.exists?('.git'))
      end
      
      def self.update_wix_files wxs_filename, component_id, filenames
            wix_text = IO.read(wxs_filename)
            new_text = get_wix_with_files(wix_text, component_id,filenames)
            if(wix_text != new_text)
                  File.open(wxs_filename,'w'){|f| f.write(new_text) }
            end
      end
end
