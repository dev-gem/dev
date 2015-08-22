puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('environment.rb')
require_relative('project.rb')
require_relative('../apps/git.rb')
require_relative('../apps/svn.rb')

class Projects < Hash
	attr_accessor :filename

	def initialize
		@filename=''
	end

    def update
    	self.each{|k,v|
    		self[k]=Project.new(v) if(v.is_a?(String))
    		self[k]=Project.new(v) if(!v.is_a?(Project) && v.is_a?(Hash))
    		self[k][:fullname]=k
    	}
    end

	def save filename=''
		@filename=filename if !filename.nil? && filename.length > 0
		File.open(@filename,'w'){|f|f.write(JSON.pretty_generate(self))} if @filename.length > 0
	end

	def open filename=''
		@filename=filename if filename.length > 0
		JSON.parse(IO.read(@filename)).each{|k,v| self[k]=v}
		update
	end

    def show filter=''
		self.each{|k,v|
			puts k if(filter.length == 0 || k.include?(filter))
		}
	end

	def make args
		filter=''
		filter=args[1] if !args.nil? && args.length > 0
		self.each{|k,v|
			if filter.nil? || filter.length==0 || k.include?(filter)
				tag=v.latest_tag
				if(tag.length > 0)
				   puts "making #{k} #{tag}"
			 	   v.make tag
			    end
		    end
		}
	end

	def self.user_projects_filename
		FileUtils.mkdir("#{Environment.dev_root}/data") if(!File.exists?("#{Environment.dev_root}/data"))
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
end

PROJECTS=Projects.new
PROJECTS.open Projects.user_projects_filename if File.exists? Projects.user_projects_filename
current=Projects.current # this makes sure the current project is added to PROJECTS
PROJECTS[current.fullname]=current if !PROJECTS.has_key? current.fullname
PROJECTS.save Projects.user_projects_filename if !File.exists? Projects.user_projects_filename
