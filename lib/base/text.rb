puts __FILE__ if defined?(DEBUG)

class Text
  def self.replace_in_glob(glob,search,replace)
     Dir.glob(glob).each{ |f| replace_in_file(f,search,replace) }
  end
   
  def self.replace_in_file(filename,search,replace)
    text1 = IO.read(filename)
    text2 = text1.gsub(search) { |str| str=replace }
    unless text1==text2
      File.open(filename,"w") { |f| f.puts text2 }
      return true
    end
    false
  end

 def self.copy_if_different(source,destination)
    if(!File.exists?(destination))
      FileUtils.cp source, destination
    else
      source_text=IO.read(source)
      destination_text=IO.read(destination)
      if(source_text != destination_text)
        FileUtils.rm destination
        FileUtils.cp source, destination
      end
    end
   end
end