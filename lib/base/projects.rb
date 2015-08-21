puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('environment.rb')
require_relative('project.rb')

class Projects < Hash
	attr_accessor :filename

	def initialize
		@filename=''
	end

    def update
    	self.each{|k,v|
    		self[k]=Project.new(v) if(v.is_a?(String))
    		self[k]=Project.new(v) if(!v.is_a?(Project) && v.is_a?(Hash))
    		self[k][:name]=k
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
			name=Rake.application.original_dir.gsub("#{Environment.dev_root}/wrk/",'')
			project[:name] = name if(name.length>0 && !name.include?(Environment.dev_root))
			if(defined?(PROJECTS))
				PROJECTS[name]=project if(!PROJECTS.has_key?(name))
				project.each{|k,v|PROJECTS[name][k]=v}
				PROJECTS.save
			else
				project[:name]=name
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
PROJECTS.save Projects.user_projects_filename if !File.exists? Projects.user_projects_filename
