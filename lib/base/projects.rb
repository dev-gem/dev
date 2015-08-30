puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('environment.rb')
require_relative('project.rb')
require_relative('../apps/git.rb')
require_relative('../apps/svn.rb')

class Projects < Hash
	attr_accessor :env

	def initialize env=nil
		@env=env if env.kind_of?(Environment)
		@env=Environment.new if @env.nil?
		open
	end

	def filename
		"#{@env.root_dir}/data/Projects.json"
	end

    #def update_state
    #	self.each{|k,v|
    #		self[k]=Project.new(v) if(v.is_a?(String))
    #		self[k][:fullname]=k
    #	}
    #end

	def save
		Dir.make File.dirname(filename) if !File.exists? File.dirname(filename)
		File.open(filename,'w'){|f|f.write(JSON.pretty_generate(self))}
	end

	def open
		if File.exists? filename
		  JSON.parse(IO.read(filename)).each{|k,v|
		  	if(v.kind_of?(Project))
		  		self[k]=v
		  	else
		  		self[k]=Project.new(v)
		  	end
		}
		  #update_state
	    end
	end

    def get_projects value=''
    	puts "get_projects #{value.to_s}" if @env.debug?
    	puts "get_project total project count #{self.length}" if @env.debug?
    	projects=Array.new
    	filter=''
    	filter=value.to_s if !value.nil? && value.kind_of?(String)
    	filter=value[0].to_s if !value.nil? && value.kind_of?(Array) && !value[0].to_s.include?('=')

        puts "get_project filter '#{filter}'" if @env.debug?
    	self.each{|k,v|
    		puts " checking project #{k}" if @env.debug?
    		puts " v.class #{v.class}" if @env.debug?
    		if(filter.length==0 || k.include?(filter))
    			if(v.kind_of?(Project))
    			   projects << v
    			   v.env=@env
    			end
    		end
    	}
    	projects
    end

    def add args
    	puts "add #{args}\n" if @env.debug?
    	url=args[0]
    	puts "url #{url}\n" if @env.debug?
    	project=Project.new(url)
    	project[:fullname]=args[1] if args.length > 1
    	puts "fullname #{project[:fullname]}\n" if @env.debug?
    	if(!self.has_key?(project[:fullname]) && project[:fullname].length > 0)
    		puts "adding #{project.fullname}\n"
    		self[project.fullname]=project
    		self.save
    	end
    end

    def help args
    end
    
    def work args
    	projects=get_projects args
		puts "working #{projects.length} projects..." if @env.debug?
		exit_code=0
    	projects.each{|project|
    		begin
    		    result=project.work
    		    exit_code=result.exit_code if(result.exit_code!=0)
    		rescue => error
		    	puts "error raised during work #{project.fullname}"
		    	puts "--------------------------------------------"
		    	puts error
		    	puts "--------------------------------------------"
		    end
    	}
    	exit_code
	end

	def info args
		projects=get_projects args
		puts "collecting info for #{projects.length} projects..." if @env.debug?
		exit_code=0
    	projects.each{|project|
    		begin
    		    result=project.info
    		    exit_code=result.exit_code if(result.exit_code!=0)
    		rescue => error
		    	puts "error raised during work #{project.fullname}"
		    	puts "--------------------------------------------"
		    	puts error
		    	puts "--------------------------------------------"
		    end
    	}
    	exit_code
	end

    def list args
    	projects=get_projects args
		puts "listing #{projects.length} projects..." if @env.debug?
    	projects.each{|project|
    		project.list
    		
    	}
	end

	def make args
		projects=get_projects args
		puts "making #{projects.length} projects..." if @env.debug?
		projects.each{|project|
			begin
			    project.make
		    rescue => error
		    	puts "error raised during make #{project.fullname}"
		    	puts "--------------------------------------------"
		    	puts error
		    	puts "--------------------------------------------"
		    end
		}
	end

	def clobber args
		projects=get_projects args
		puts "clobbering #{projects.length} projects..." if @env.debug?
		projects.each{|project|
			begin
			    project.clobber
			    #Dir.remove_empty @env.wrk_dir
		    rescue => error
		    	puts "error raised during clobber #{project.fullname}"
		    	puts "--------------------------------------------"
		    	puts error
		    	puts "--------------------------------------------"
		    end
		}
    end

	def update args
		filter=''
		filter=args[1] if !args.nil? && args.length > 0
		self.each{|k,v|
			if filter.nil? || filter.length==0 || k.include?(filter)
				puts "updating #{v.fullname}"
			 	v.update
		    end
		}
	end

	def self.user_projects_filename
		FileUtils.mkdir_p("#{Environment.dev_root}/data") if(!File.exists?("#{Environment.dev_root}/data"))
		"#{Environment.dev_root}/data/PROJECTS.json"
	end

	def self.current
		project=nil
		url=Git.remote_origin
		url=Svn.url if url.length==0
		if(Rake.application.original_dir.include?('/wrk/') &&
			   url.length > 0)
			project=Project.new(url)
			fullname=Rake.application.original_dir.gsub("#{Environment.dev_root}/wrk/",'')
			project[:fullname] = name if(name.length>0 && !name.include?(Environment.dev_root))
			if(defined?(PROJECTS))
				PROJECTS[name]=project if(!PROJECTS.has_key?(name))
				project.each{|k,v|PROJECTS[name][k]=v}
				PROJECTS.save
			else
				project[:fullname]=name
			end
		end			
		project
	end

	def pull
		self.each{|k,v| v.pull if v.respond_to?("pull".to_sym)}
	end
	def rake
		self.each{|k,v| v.rake if v.respond_to?("rake".to_sym)}
	end

	def import pattern=''
		wrk=@env.wrk_dir
		if File.exists?(wrk)
		   Dir.chdir(wrk) do
		   	    puts "scanning {wrk} for imports..."
		   		Dir.glob('**/rakefile.rb').each{|rakefile|
		   			rakedir=File.dirname(rakefile)
		   			url = Project.get_url rakedir
		   			project = Project.new(Project.get_url(rakedir))
		   			project[:fullname]=rakedir.gsub(@env.wrk_dir,'') if(project.fullname.include?(':'))
		   			if(pattern.length==0 || project.fullname.include?(pattern))
		   				if(project.fullname.length > 0 && !self.has_key?(project.fullname))
		   				    puts "importing #{project.fullname}"
		   				    self[project.fullname]=project
		   			    end
		   			end
		   		}
		   end
		   self.save
	    end
	end
end