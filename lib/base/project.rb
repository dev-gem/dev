puts __FILE__ if defined?(DEBUG)

require 'json'
require_relative('../apps/svn.rb')
require_relative('string.rb')

class Project < Hash
	attr_accessor :filename

	def self.get_url
	  url=''
	  Dir.chdir(Rake.application.original_dir) do
	    url= `git config --get remote.origin.url` if(File.exists?('.git'))
	    url= Svn.url if(File.exists?('.svn'))
	  end
	  url
	end

	def self.get_fullname
	  Rake.application.original_dir.gsub(Environment.dev_root,'').gsub('/trunk','') .gsub('/wrk','')
	end

	def self.get_fullname_from_url url
		return url.gsub('http://','').gsub('https://','').gsub('.com/','/').gsub('.git','')
	end

	def initialize value=''
		@filename=''
		self[:url]=Project.get_url
		self[:fullname]=Project.get_fullname
		if value.is_a?(String)
		    self[:url] = value if value.is_a?(String) && value.length > 0
		    self[:fullname] = Project.get_fullname_from_url self[:url]
		elsif(value.is_a?(Hash))
			value.each{|k,v|self[k.to_sym]=v}
		else
			self[:fullname]=Project.get_fullname
		end
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
    	#self[:name]
    end

	def wrk_dir
		"#{Environment.dev_root}/wrk/#{self.fullname}"
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

    def make_dir tag
    	"#{Environment.dev_root}/make/#{self.fullname}-#{tag}"
    end

	def make tag
		rake_default=nil
		logfile="#{Environment.dev_root}/log/#{self.fullname}/#{tag}/#{Environment.user}@#{Environment.machine}.json"
		if(File.exists?(logfile))
			# load hash from json
			return Command.new(JSON.parse(IO.read(logfile)))
		else
			FileUtils.mkdir("#{Environment.dev_root}/make") if !File.exists? "#{Environment.dev_root}/make"
			makedir="#{Environment.dev_root}/make/#{self.fullname}-#{tag}"
			FileUtils.mkdir_p(File.dirname(makedir)) if !File.exists? File.dirname(makedir)
			if(self[:url].include?('.git'))
				clone=Command.new({:input=>"git clone #{self[:url]} #{makedir}",:quiet=>true})
				clone.execute
				Dir.chdir(makedir) do
					checkout=Command.new({:input=>"git checkout #{tag}",:quiet=>true})
					checkout.execute
					FileUtils.rm_r '.git'
					rake_default=Command.new('rake default')
					rake_default[:quiet]=true
					rake_default.execute
					FileUtils.mkdir_p(File.dirname(logfile)) if !File.exists?(File.dirname(logfile))
					File.open(logfile,'w'){|f|f.write(rake_default.to_json)}
					rake_default
				end
			end
			FileUtils.rm_r makedir
			rake_default
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

