class GitUrl
    def self.build url 

        if(url.kind_of?(Array))
            puts "url is an Array"
            url.each{|u| GitUrl.build u}
        else
            puts "build #{url}"
            work_dir = get_work_dir(url)
            puts "work_dir #{work_dir}"
            if(!Dir.exists?(work_dir))
                puts "git clone #{url} #{work_dir}"
                puts `git clone #{url} #{work_dir}`
            end
        
            Dir.chdir(work_dir) do
                puts "git pull (#{work_dir})"
                puts `git pull`
                puts "rake #{work_dir}"
                puts `rake`
            end
        end
    end
    
    def self.get_work_dir url
        Environment.dev_root + "/work/" + get_relative_dir(url)
    end
    
    def self.get_relative_dir url 
        url.gsub('http://','').gsub('https://','').gsub('.git','')
    end
end