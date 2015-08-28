puts __FILE__ if defined?(DEBUG)
require_relative('command.rb')

class Gemspec
	def self.update gemspec_file
		Text.replace_in_file gemspec_file,
                              /('\d{4}-\d{2}-\d{2}')/,
                              "'#{Time.now.strftime('%Y-%m-%d')}'"
	end

	def self.gemfile gemspec_file
		spec=Gem::Specification.load(gemspec_file)
		return "#{spec.name}-#{spec.version}.gem" if !spec.nil?
		return ""
	end

    def self.version gemspec_file
    	spec=Gem::Specification.load(gemspec_file)
		return spec.version.to_s
    end

    def self.latest_published_version gemname
    	scan=`gem list -r #{gemname}`.scan(/^dev\s*\(([\d.]+)\)/)
		if(!scan.nil?)
			return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
		end
		''
    end

    def self.published_version gemspec_file
  		published_version=''
    	spec=Gem::Specification.load(gemspec_file)
		begin
		  published_version = latest_published_version spec.name# `gem list -r #{spec.name}`.scan(/\((\d+.\d+.\d+)\)/)[0][0]
		rescue
		  published_version=''
		end
		published_version
    end
	def self.published? gemspec_file
		published_version(gemspec_file)==version(gemspec_file) ? true : false
	end

	def self.normalize gemspec_file
		spec=Gem::Specification.load(gemspec_file)
		File.open(gemspec_file,'w'){|f|f.write(spec.to_ruby)}
	end

	def self.upgrade gemspec_file
	end
end