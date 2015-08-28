puts __FILE__ if defined?(DEBUG)

require 'json'
require_relative('../apps/svn.rb')
require_relative('string.rb')

class Project < Hash
	attr_accessor :filename,:dev

	def self.get_url directory=Rake.application.original_dir
	  url=''
	  Dir.chdir(directory) do#Rake.application.original_dir) do
	    url=`git config --get remote.origin.url`.strip if(File.exists?('.git'))
	    url= Svn.url.strip if(File.exists?('.svn'))
	  end
	  url
	end

	def self.get_fullname directory
	    directory.gsub(Environment.dev_root,'').gsub('/wrk','')
	end

	def self.get_fullname_from_url url
		return url.gsub('http://','').gsub('https://','').gsub('.com/','/').gsub('.git','')
	end

	def initialize value=''
		@filename=''

		self[:url]=Project.get_url
		self[:fullname]=Project.get_fullname_from_url self[:url] if self[:url].length > 0
		if value.is_a?(String)
		    self[:url] = value if value.is_a?(String) && value.length > 0
		    self[:fullname] = Project.get_fullname_from_url self[:url]
		elsif(value.is_a?(Hash))
			value.each{|k,v|self[k.to_sym]=v}
		else
			self[:fullname]=Project.get_fullname_from_url self[:url] if self[:url].length > 0
		end

		#self[:fullname]=Project.get_fullname Rake.application.original_dir if(self.fullname.include?(':') && Rake.application.original_dir.include?('/wrk/'))
	end

    def url
    	self[:url]
    end
    def fullname
    	self[:fullname]
    end

    def name
    	parts=fullname.split('/')
    	parts[parts.length-1]
    end

	def wrk_dir
		"#{@dev.wrk_dir}/#{self.fullname}"
	end

	def pull
		if(File.exists?(wrk_dir) && File.exists?("#{wrk_dir}/.git"))
			Dir.chdir(wrk_dir) do
				puts "git pull (#{wrk_dir})"
				puts `git pull`
			end
		end
	end

	def clone
		puts "project.clone" if @dev.debug?
		puts "wrk_dir=#{wrk_dir}" if @dev.debug?
		if(!File.exists?(wrk_dir) && self[:url].include?('.git'))
			puts "cloning #{self[:url]} to #{self.wrk_dir}"
			puts `git clone #{self[:url]} #{self.wrk_dir}`
		end
	end

	def checkout
		if(!File.exists?(wrk_dir) && self[:url].include?('svn'))
			puts "checkout #{self.url} to #{self.wrk_dir}"
			puts `svn checkout #{self.url} #{self.wrk_dir}`
		end
	end

	def rake
		if(!File.exists?(self.wrk_dir))
			clone
			checkout
		end
		if(File.exists?(self.wrk_dir))
			Dir.chdir(self.wrk_dir) do
				rake = Command.new({ :input => 'rake', :timeout => 300, :ignore_failure => true })
				rake.execute
				puts rake.summary
			end
		end
	end

	def info
		puts "Project #{name}"
		puts "#{'fullname'.fix(13)}: #{self.fullname}"
		puts "#{'url'.fix(13)}: #{self[:url]}"
		puts "#{'version'.fix(13)}: #{VERSION}" if defined? VERSION
	end

    def latest_tag update=false
		FileUtils.mkdir("#{Environment.dev_root}/make") if !File.exists? "#{Environment.dev_root}/make"
		makedir="#{Environment.dev_root}/make/#{self.fullname}"
    	FileUtils.mkdir_p(File.dirname(makedir)) if !File.exists?(File.dirname(makedir))
        if(File.exists?(makedir))
        	Dir.chdir(makedir) do
        	  Command.exit_code('git pull')
            end
        else
        	if(update)
        	   clone=Command.new("git clone #{self.url} #{makedir}")
			   clone[:quiet]=true
			   clone[:ignore_failure]=true
			   clone.execute
		    end
        end
        if(File.exists?(makedir))
        	Dir.chdir(makedir) do
        		begin
        		    return Git.latest_tag
        	    rescue
        	    end
        	end
        end
        ''
    end

    def make_dir tag
    	"#{Environment.dev_root}/make/#{self.fullname}-#{tag}"
    end

	def make tag=''
		tag=latest_tag if tag.length==0

		return if tag.length==0
		raise 'no tag specified' if tag.length==0

		rake_default=nil
		logfile="#{Environment.dev_root}/log/#{self.fullname}/#{tag}/#{Environment.user}@#{Environment.machine}.json"
		if(File.exists?(logfile))
			# load hash from json
			rake_default=Command.new(JSON.parse(IO.read(logfile)))
			#puts rake_default.summary
		else
			FileUtils.mkdir("#{Environment.dev_root}/make") if !File.exists? "#{Environment.dev_root}/make"
			makedir="#{Environment.dev_root}/make/#{self.fullname}-#{tag}"
			FileUtils.mkdir_p(File.dirname(makedir)) if !File.exists? File.dirname(makedir)
			if(self[:url].include?('.git'))
				if(!File.exists?(makedir))
				   clone=Command.new({:input=>"git clone #{self[:url]} #{makedir}",:quiet=>true})
				   clone.execute
			    end
				if(File.exists?(makedir))
				  Dir.chdir(makedir) do
				  	#puts "making #{self.fullname}"
					checkout=Command.new({:input=>"git checkout #{tag}",:quiet=>true})
					checkout.execute
					FileUtils.rm_r '.git'
					rake_default=Command.new('rake default')
					rake_default[:quiet]=true
					rake_default[:ignore_failure]=true
					#rake_default[:timeout]=5*60*1000
					rake_default.execute

					@dev.history.add_command rake_default
					
					FileUtils.mkdir_p(File.dirname(logfile)) if !File.exists?(File.dirname(logfile))
					File.open(logfile,'w'){|f|f.write(rake_default.to_json)}
					update_status
					rake_default
				  end
			   end
			end
			begin
			    FileUtils.rm_r makedir
		    rescue
		    end
			rake_default
		end
	end

    def last_work_mtime
    	logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.json"
    	if File.exists? logfile
    		return File.mtime(logfile)
    	end
    	nil
    end

    def update_status
    	status_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.status.json"
    	status=Hash.new({'status'=>'?'})
    	wrk_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.json"
    	if(File.exists?(wrk_logfile))
    		rake_default=Command.new(JSON.parse(IO.read(wrk_logfile)))
    		status[:work_logfile]=wrk_logfile 
    		status['status']='0' 
    		status['status']='X' if rake_default[:exit_code] != 0
        end
    	make_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{latest_tag}/#{Environment.user}@#{Environment.machine}.json"
    	if(File.exists?(make_logfile))
    		rake_default=Command.new(JSON.parse(IO.read(make_logfile)))
    		status[:make_logfile]=make_logfile 
    		status['status']='0' 
    		status['status']='X' if rake_default[:exit_code] != 0
    	else
    		status['status']='?'
    	end
    	FileUtils.mkdir_p(File.dirname(status_logfile)) if !File.exists?(File.dirname(status_logfile))
    	File.open(status_logfile,'w'){|f|f.write(status.to_json)}
    end

    def status
    	status_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.status.json"
    	update_status if !File.exists? status_logfile
    	if(File.exists?(status_logfile))
    	  statusHash=JSON.parse(IO.read(status_logfile))
    	  return statusHash['status'] if(statusHash.has_key?('status'))
    	end
    	'?'
    	#status='?'
    	#wrk_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.json"
    	#if(File.exists?(wrk_logfile))
    	#	rake_default=Command.new(JSON.parse(IO.read(wrk_logfile)))
    	#	status='0'
    	#	return 'X' if rake_default[:exit_code] != 0
    	#end
    	#make_logfile="#{Environment.dev_root}/log/#{self.fullname}/#{latest_tag}/#{Environment.user}@#{Environment.machine}.json"
    	#if(File.exists?(make_logfile))
    	#	rake_default=Command.new(JSON.parse(IO.read(make_logfile)))
    	#	status='0'
    	#	return 'X' if rake_default[:exit_code] != 0
    	#else
    	#	return '?' # outstanding make
    	#end
    	#status
    end

    def report
    end

    def work
    	clone
    	checkout
    	if(File.exists?(wrk_dir))
    		if(last_work_mtime.nil? || last_work_mtime < Environment.get_latest_mtime(wrk_dir))
    		  Dir.chdir(wrk_dir) do
    		  	puts "working #{self.fullname}"
    		  	rake_default=Command.new('rake default')
				rake_default[:quiet]=true
				rake_default[:ignore_failure]=true
				rake_default.execute
    			#Command.exit_code('rake default')
    			@dev.history.add_command rake_default
    			logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.json"
    			FileUtils.mkdir_p(File.dirname(logfile)) if !File.exists?(File.dirname(logfile))
				File.open(logfile,'w'){|f|f.write(rake_default.to_json)}
				update_status
				puts rake_default.summary
    	      end
    	    else
    	    	logfile="#{Environment.dev_root}/log/#{self.fullname}/#{Environment.user}@#{Environment.machine}.json"
    	    	if(File.exists?(logfile))
    	    		rake_default=Command.new('rake default')
    	    		rake_default.open logfile
    	    		puts rake_default.summary if(rake_default[:exit_code] != 0)
    	    	end
    	    end
    	end
    end

    def update
    	clone
    	checkout
    	if(File.exists?(wrk_dir))
    		Dir.chdir(wrk_dir) do
    			rake_default=Command.new('git pull')
				rake_default[:quiet]=true
				rake_default[:ignore_failure]=true
				rake_default.execute
				rake_default=Command.new('svn update')
				rake_default[:quiet]=true
				rake_default[:ignore_failure]=true
				rake_default.execute
    		end
    	end
    end

    def tags
    	tags=Array.new
    	if !File.exists? wrk_dir
    		clone=Command.new({:input=>'git clone #{self[:url]} #{wrk_dir}',:quiet=>true})
    		clone.execute
    	end
    	Dir.chdir(wrk_dir) do
    		Command.output('git tag').split('\n').each{|line|
    			tag=line.strip
    			tags << tag if tag.length < 0
    		}
    	end
    	tags
    end

	def clobber

	end
end

