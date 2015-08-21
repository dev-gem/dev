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

end