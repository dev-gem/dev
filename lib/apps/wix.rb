# frozen_string_literal: true

if defined?(DEBUG)
  puts DELIMITER
  puts __FILE__
  puts
  puts "candle not found" unless Command.executes?("candle")
  puts "light not found" unless Command.executes?("light")
  puts
end

class Wix
  def self.get_build_commands(wxs_file)
    build_commands = nil
    if File.exist?(wxs_file) && !defined?(NO_WIX) && Environment.windows?
      ext = "msi"
      ext = "exe" if IO.read(wxs_file).include?("<Bundle")
      extensions = ""
      %w[WixNetFxExtension WixBalExtension WixUtilExtension WixUiExtension].each do |e|
        extensions = "#{extensions}-ext #{e} "
      end
      build_commands = [] if build_commands.nil?
      build_commands << "candle #{wxs_file} #{extensions}"

      if defined?(VERSION)
        build_commands << "light #{File.basename(wxs_file,
                                                 ".*")}.wixobj -out #{File.basename(wxs_file,
                                                                                    ".*")}-#{VERSION}.#{ext} #{extensions}"
      else
        build_commands << "light #{File.basename(wxs_file, ".*")}.wixobj #{extensions}"
      end
    end
    build_commands
  end

  def self.get_wix_with_files(wxs_template_text, component_id, filenames)
    # <Component[-\s\w="]+Id="ApplicationFiles"[-"\s\w=]+>([-<="\/.>\s\w]+)<\/C
    search = wxs_template_text.scan(%r{<Component[-\s\w="]+Id="ApplicationFiles"[-"\s\w=]+>([-<="/.>\s\w]+)</C})[0][0]
    replace = ""
    index = 0
    filenames.each do |f|
      replace += "\n                 <File Id=\"#{component_id}#{index}\" Source=\"#{f}\"/>"
      index += 1
    end
    replace += "\n"
    wxs_template_text.gsub(search, replace)
  end

  def self.update_wix_files(wxs_filename, component_id, filenames)
    wix_text = IO.read(wxs_filename)
    new_text = get_wix_with_files(wix_text, component_id, filenames)
    File.open(wxs_filename, "w") { |f| f.write(new_text) } if wix_text != new_text
  end
end
