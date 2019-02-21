class GitUrl
    def self.build url 

        if(url.kind_of?(Array))
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

    def self.build_tag url, tag
        puts "build #{url} #{tag}"
        work_dir = get_work_dir(url,tag)
        puts "work_dir #{work_dir}"
        if(!Dir.exists?(work_dir))
            puts "git clone -b #{tag} --single-branch --depth 1 #{url} #{work_dir}"
            puts `git clone -b #{tag} --single-branch --depth 1 #{url} #{work_dir}`
        end
    
        Dir.chdir(work_dir) do
            puts "rake #{work_dir}"
            puts `rake`
        end
    end
    
    def self.get_work_dir url
        Environment.dev_root + "/work/" + get_relative_dir(url)
    end

    def self.get_work_dir url, tag
        Environment.dev_root + "/work/" + get_relative_dir(url) + "-#{tag}"
    end
    
    def self.get_relative_dir url 
        url.gsub('http://','').gsub('https://','').gsub('.git','')
    end
end