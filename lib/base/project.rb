puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('../apps/svn.rb')
require_relative('dir.rb')
require_relative('environment.rb')
require_relative('string.rb')

class Project < Hash
	attr_accessor :filename,:env

    def initialize value='',fullname=''
        @filename=''
        @env=Environment.new
        self[:url]=Project.get_url
        self[:fullname]=Project.get_fullname_from_url self[:url] if self[:url].length > 0
        self[:timeout]=60*5
        if value.is_a?(String)
            self[:url] = value if value.is_a?(String) && value.length > 0
            self[:fullname] = Project.get_fullname_from_url self[:url]
        elsif(value.is_a?(Hash))
            value.each{|k,v|self[k.to_sym]=v}
        else
            self[:fullname]=Project.get_fullname_from_url self[:url] if self[:url].length > 0
        end
        self[:fullname] = fullname if fullname.length > 0
    end

    def set_timeout value
        self[:timeout] = value if value.is_a? Numeric
        self[:timeout] = value.gsub('m','').strip.to_f * 60 if value.include?('m')
        self[:timeout] = value.gsub('s','').strip.to_f * 60 if value.include?('s')
    end

	def self.get_url directory=Rake.application.original_dir
	  url=''
	  Dir.chdir(directory) do#Rake.application.original_dir) do
	    url=`git config --get remote.origin.url`.strip if(File.exists?('.git'))
	    url= Svn.url.strip if(File.exists?('.svn'))
	  end
	  url
	end

	def self.get_fullname directory
	    directory.gsub(@env.wrk_dir,'')
	end

	def self.get_fullname_from_url url
		return url.gsub('http://','').gsub('https://','').gsub('.com/','/').gsub('.git','')
	end

    def url; self[:url]; end
    def fullname; self[:fullname]; end

    def name
    	parts=fullname.split('/')
    	parts[parts.length-1]
    end

	def wrk_dir; "#{@env.wrk_dir}/#{self.fullname}"; end
	def make_dir tag=''
		"#{@env.make_dir}/#{self.fullname}" if tag.length==0
    	"#{@env.make_dir}/#{self.fullname}-#{tag}"
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
		if(!File.exists?(wrk_dir) && self[:url].include?('.git'))
            cmd=Command.new({ :input => "git clone #{self[:url]} #{self.wrk_dir}", :quiet => true,:ignore_failure => true})
            cmd.execute
            @env.out cmd.summary
		end
	end

	def checkout
		if(!File.exists?(wrk_dir) && self[:url].include?('svn'))
			#puts "checkout #{self.url} to #{self.wrk_dir}"
			#puts `svn checkout #{self.url} #{self.wrk_dir}`
            cmd=Command.new({ :input => "svn checkout #{self.url} #{self.wrk_dir}", :quiet => true,:ignore_failure => true})
            cmd.execute
            @env.out cmd.summary
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
				@env.out rake.summary
			end
		end
	end

	

    def latest_tag update=false
		makedir="#{@env.make_dir}/#{self.fullname}"
    	FileUtils.mkdir_p(File.dirname(makedir)) if !File.exists?(File.dirname(makedir))
        if(File.exists?(makedir))
        	Dir.chdir(makedir) do
        	  Command.exit_code('git pull') if update
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

    

    def log_filenames tags=nil
    	tags=Array.new if tags.nil?
    	filenames=Array.new
    	Dir.chdir(@env.log_dir) do
    		dotname=fullname.gsub('/','.')
    		Dir.glob("#{dotname}*.json").each{|f|
    			if(tags.length==0)
    				filenames << "#{@env.log_dir}/#{f}"
    			else
    				has_tags=true
    				tags.each{|tag|
    					has_tags=false if !f.include? tag
    				}
    				filenames << "#{@env.log_dir}/#{f}" if has_tags
    			end
    		}
    	end
    	filenames
    end

    def command_history tags=nil
    	commands=Array.new
    	log_filenames(tags).each{|logfile|
    		commands << Command.new(JSON.parse(IO.read(logfile)))
    	}
        commands
    end
   
    def wrk_up_to_date?
        logfile=get_logfile ['work','up2date']
        if File.exists? logfile
            last_work_time=File.mtime(logfile)
            last_file_changed=Dir.get_latest_mtime Rake.application.original_dir
            if last_work_time > last_file_changed
                CLEAN.include logfile
                return true
            end
            #if File.mtime(logfile) > Dir.get_latest_mtime Rake.application.original_dir
                #CLEAN.include(logfile)
            #    return true
           # end
        end
        false
    end

    def mark_wkr_up_to_date
    end

    def get_logfile tags
    	tagstring=''
    	tagstring=tags if tags.kind_of?(String)
    	tagstring=tags.join('.') if tags.kind_of?(Array)
    	name="#{self.fullname}.#{tagstring}.json".gsub('/','.')
    	"#{@env.log_dir}/#{name}"
    end

    def list
        history=command_history
        if(history.length==0)
            @env.out "?      #{fullname}"
        else
            status=0
            history.each{|c|
                status=c.exit_code if c.exit_code != 0
            }
            if(status==0)
                @env.out "       #{fullname}"
            else
                if(@env.colorize?)
                    require 'ansi/code'
                    @env.out ANSI.red + ANSI.bright + "X      #{fullname}" + ANSI.reset
                else
                    @env.out "X      #{fullname}"
                end
            end
        end
    end

    def out_brackets message
        if(@env.colorize?)
            require 'ansi/code'
            @env.out "[" + ANSI.blue + ANSI.bright + message + ANSI.reset + ']'
        else
            @env.out "[#{message}]"
        end
    end

    def out_cyan message
        if(@env.colorize?)
            require 'ansi/code'
            @env.out ANSI.cyan + ANSI.bright + message + ANSI.reset
        else
            @env.out "#{message}"
        end
    end

    def out_property name,value
        if(@env.colorize?)
            require 'ansi/code'
            @env.out "#{name}: " + ANSI.white + ANSI.bold + value.to_s.strip + ANSI.reset
        else
            @env.out "#{name}: #{value}"
        end
    end

    #def info
    #    @env.out "Project #{name}"
    #    @env.out "#{'fullname'.fix(13)}: #{self.fullname}"
    #    @env.out "#{'url'.fix(13)}: #{self[:url]}"
    #    @env.out "#{'version'.fix(13)}: #{VERSION}" if defined? VERSION
    #end
    def info
        infoCmd=Command.new({ :input => 'info', :exit_code => 0 })
        #out_cyan '========================================================='
        #out_cyan fullname
        out_property "fullname".fix(15), fullname
        out_property "url".fix(15), url
        wrk_history=command_history ['work']
        out_property "work status".fix(15), "?" if wrk_history.length == 0
        out_property "work status".fix(15), wrk_history[0].summary if wrk_history.length > 0
        if(wrk_history.length > 0)
            @env.out wrk_history[0].info
        end
        make_history=command_history ['make', latest_tag]
        out_property "make status".fix(15),"?" if make_history.length == 0
        out_property "make status".fix(15), make_history[0].summary if make_history.length > 0
        if(make_history.length >0)
            @env.out make_history[0].info
        end
        infoCmd
    end

    def clobber
        clobberCmd=Command.new('clobber')
        clobberCmd[:exit_code]=0
        if(File.exists?(wrk_dir))
            Dir.remove wrk_dir,true
            @env.out "removed #{wrk_dir}"
        end
        if(File.exists?(make_dir))
            Dir.remove make_dir,true
            @env.out "removed #{make_dir}"
        end
        clobberCmd
    end

    def work
        clone
        checkout
        logfile=get_logfile ['work']
        if(File.exists?(wrk_dir))
            rake_default=Command.new({:input =>'rake default',:quiet => true,:ignore_failure => true})
            if(last_work_mtime.nil? || last_work_mtime < Environment.get_latest_mtime(wrk_dir))
              Dir.chdir(wrk_dir) do

                @env.out fullname
                
                if(!File.exists?'rakefile.rb')
                    rake_default[:exit_code]=1
                    rake_default[:error]="rakefile.rb not found."
                    rake_default[:start_time]=Time.now
                    rake_default[:end_time]=Time.now
                else
                    #rake_default[:timeout] = self[:timeout]
                    rake_default.execute
                end
                rake_default.save logfile
                update_status
                @env.out rake_default.summary true
                return rake_default
              end
            else
                if(File.exists?(logfile))
                    rake_default.open logfile
                    @env.out rake_default.summary true if(rake_default[:exit_code] != 0 || @env.show_success?)
                end
            end
            rake_default
        end
    end

	def make tag=''
		tag=latest_tag true if tag.length==0
		#return if tag.length==0
		raise 'no tag specified' if tag.length==0

		rake_default=Command.new({:input => 'rake default',:quiet => true,:ignore_failure => true})
		logfile=get_logfile ['make',tag]		
		if(File.exists?(logfile))
            rake_default.open logfile
            @env.out rake_default.summary true if(rake_default[:exit_code] != 0) || @env.show_success?
            rake_default
		else
			makedir=make_dir tag
			FileUtils.mkdir_p(File.dirname(makedir)) if !File.exists? File.dirname(makedir)
			if(self[:url].include?('.git'))
				if(!File.exists?(makedir))
				   clone=Command.new({:input=>"git clone #{self[:url]} #{makedir}",:quiet=>true})
				   clone.execute
			    end
            end
			if(File.exists?(makedir))
				  Dir.chdir(makedir) do
					checkout=Command.new({:input=>"git checkout #{tag}",:quiet=>true})
					checkout.execute
					FileUtils.rm_r '.git'
                    if(!File.exists?'rakefile.rb')
                        rake_default[:exit_code]=1
                        rake_default[:error]="rakefile.rb not found."
                        rake_default[:start_time]=Time.now
                        rake_default[:end_time]=Time.now
                    else
                        #rake_default[:timeout] = self[:timeout]
                        rake_default.execute 
                    end
                    rake_default.save logfile
					update_status
                    @env.out rake_default.summary true
					rake_default
				  end
            else
                puts "Project make make_dir #{makedir} does not exist." if @env.debug?
			end
			
			begin
			    FileUtils.rm_r makedir
		    rescue
		    end
			rake_default
		end
	end

    def last_work_mtime
    	logfile=get_logfile ['work']
    	return File.mtime(logfile) if File.exists? logfile
    	nil
    end

    def update_status
    	status_logfile="#{@env.root_dir}/log/#{self.fullname}/#{@env.user}@#{@env.machine}.status.json"
    	status=Hash.new({'status'=>'?'})
    	wrk_logfile="#{@env.root_dir}/log/#{self.fullname}/#{@env.user}@#{@env.machine}.json"
    	if(File.exists?(wrk_logfile))
    		rake_default=Command.new(JSON.parse(IO.read(wrk_logfile)))
    		status[:work_logfile]=wrk_logfile 
    		status['status']='0' 
    		status['status']='X' if rake_default[:exit_code] != 0
        end
    	make_logfile="#{@env.root_dir}/log/#{self.fullname}/#{latest_tag}/#{@env.user}@#{@env.machine}.json"
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
    	status_logfile="#{@env.root_dir}/log/#{self.fullname}/#{@env.user}@#{@env.machine}.status.json"
    	update_status if !File.exists? status_logfile
    	if(File.exists?(status_logfile))
    	  statusHash=JSON.parse(IO.read(status_logfile))
    	  return statusHash['status'] if(statusHash.has_key?('status'))
    	end
    	'?'
    end

    def report
    end

    def update
    	clone
    	checkout
    	if(File.exists?(wrk_dir))
    		Dir.chdir(wrk_dir) do
                if(File.exists?('.git'))
                  pull=Command.execute(Command.new({:input => 'git pull', :quiet => true, :ignore_failure => true}))
                  @env.out pull.summary
                  return pull
    			  #pull=Command.new('git pull')
				  #rake_default[:quiet]=true
				  #rake_default[:ignore_failure]=true
				  #rake_default.execute
                  #return rake_defa
                end
                if(File.exists?('svn'))
                    updateCmd=Command.execute(Command.new({:input => 'svn update', :quiet => true, :ignore_failure => true}))
                    @env.out updateCmd.summary
                    return updateCmd
                end
				#rake_default=Command.new('svn update')
				#rake_default[:quiet]=true
				#rake_default[:ignore_failure]=true
				#rake_default.execute
    		end
    	end
        return Command.new({:exit_code => 1})
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

	
end

