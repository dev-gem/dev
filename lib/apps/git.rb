puts __FILE__ if defined?(DEBUG)

require 'tmpdir'
require 'rake'

class Git
	def self.branch directory=''
        directory=Dir.pwd if directory.length == 0
        Dir.chdir(directory) do
    		begin
    		  `git branch`.scan(/\* ([.\w-]+)/)[0][0] if(File.exists?('.git'))
    	    rescue
    	    	''
    	    end
        end
    end
    def self.url
        url=''
        url=`git config --get remote.origin.url` if(File.exists?('.git'))
    end

    def self.user_email
        email=''
        begin
            email=`git config --list`.scan(/user.email=([\d\w.@\-\+]+)/)[0][0]
        rescue
            email=''
        end
        email
    end

    def self.user_name
        name=''
        begin
            name=`git config --list`.scan(/user.name=([\d\w.@\-\+]+)/)[0][0]
        rescue
            name=''
        end
        name
    end

    def self.remote_origin directory=''
    	url=''
    	directory=Dir.pwd if directory.length == 0
    	Dir.chdir(directory) do
    		begin
    			url=`git remote show origin`.scan(/Fetch URL: ([\.\-:\/\w\d]+)/)[0][0] if(File.exists?('.git'))
    		rescue
    			url=''
    		end
    	end
    	url
    end

    def self.has_changes? directory=''
        directory=Dir.pwd if directory.length==0
        Dir.chdir(directory) do
            if(File.exists?('.git'))
                return true if `git status`.include?('modified:')
                return true if `git status`.include?('new file:')
            end
        end
        false
    end

    def self.init directory=''
        directory=Dir.pwd if directory.length==0
        parent=File.dirname(directory)
        FileUtils.mkdir_p parent if !File.exists?(parent) && parent.length > 0
        Dir.chdir(parent) do
           `git init --bare`

        end
    end

    def self.tag directory,version
        directory=Dir.pwd if directory.length == 0
        Dir.chdir(directory) do
            #`git pull`
            tags=`git tag`
            if(!tags.include?(version))
                puts 'tagging branch'
                puts `git tag #{version} -m'#{version}'`
                puts 'committing'
                puts `git commit -m'#{version}'`
                #puts 'pushing'
                #puts `git push --tags`
                #puts `git push`
            end
        end
    end

    def self.publish destination, source_dir, source_filelist, tag
        puts "publish to #{destination}"
        tmp_dir=Dir.mktmpdir
        FileUtils.mkdir_p(File.dirname(tmp_dir)) if(!File.exists?(File.dirname(tmp_dir)))
        FileUtils.rm_r(tmp_dir) if File.exists?(tmp_dir)
        puts `git clone #{destination} #{tmp_dir}`

        puts "checking if tag #{tag} exists..."
        Dir.chdir(tmp_dir) do
            tags=`git tag`
            if(tags.include?(tag))
                puts "tag #{tag} already exists."
            else
                puts "tag #{tag} does not exist."
                Dir.chdir(source_dir) do
                    source_filelist.each{|f|
                        dest = tmp_dir + "/" + f
                        FileUtils.mkdir_p(File.dirname(dest)) if(!File.exists?(File.dirname(dest)))
                        FileUtils.cp(f,dest);
                        puts "copying file #{f} for publishing"
                    }
                end
                puts 'git add -A'
                puts `git add -A`
                puts 'git commit -m"add"'
                puts `git commit -m"add"`
                Git.tag tmp_dir,tag
            end
        end

        FileUtils.rm_r tmp_dir
    end

    def self.clone_and_reset uri, directory, tagname
        if(!File.exists?(directory))
            `git clone #{uri} #{directory}`
            Dir.chdir(directory) do
                `git reset --hard #{tagname}`
            end
        end
    end

    def self.latest_tag directory=''
        if directory.length==0
            Command.output('git describe --abbrev=0 --tags').strip
            #`git describe --abbrev=0 --tags`.strip
        else
            result=''
            Dir.chdir(directory) do
                result=Command.output('git describe --abbrev=0 --tags').strip
                #result=`git describe --abbrev=0 --tags`.strip
            end
            result
        end
    end

    def self.copy(src_url,src_directory,branch,target_directory,filelist)
        if(!File.exists?(src_directory))
            puts "git clone #{src_url} #{src_directory}"
            puts `git clone #{src_url} #{src_directory}`
        else
            puts "chdir #{src_directory}"
            Dir.chdir(src_directory) do
                puts "git pull"
                git_pull=Command.new('git pull')
                git_pull[:directory]=src_directory
                git_pull[:timeout] = 30
                git_pull[:ignore_failure] =true
                git_pull.execute
                
            end
        end

        puts "chdir #{src_directory}"
        Dir.chdir(src_directory) do
            puts "git checkout #{branch}"
            puts `git checkout #{branch}`
            filelist.each{|f|
                dest="#{target_directory}/#{f}"
                FileUtils.mkdir_p File.dirname(dest) if !File.exists? File.dirname(dest)
                puts "copying #{f} to #{dest}"
                FileUtils.cp(f,dest)
            }
        end
    end
end