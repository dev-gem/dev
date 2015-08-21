require_relative '../lib/apps/git.rb'
require 'fileutils'

describe Git do

	it "should be able to perform a basic workflow" do
		repo_dir="#{File.dirname(__FILE__)}/git_spec/repo.git"
		
		FileUtils.rm_r repo_dir if File.exists?(repo_dir)
		
		Git.init repo_dir

		#expect(File.exists?("#{repo_dir}")).to eq(true)

		#wrk_dir="#{File.dirname(__FILE__)}/tmp/wrk"
		#FileUtils.rm_r wrk_dir if File.exists?(wrk_dir)
		#{}`git clone #{repo_dir} #{wrk_dir}`
		#expect(File.exists?("#{wrk_dir}/.git")).to eq(true)
		#Dir.chdir(wrk_dir) do

		#	File.open('rakefile.rb','w'){|f|f.puts "require 'dev'"}
		#	`git add rakefile.rb`

		#	'git commit -m"added rakefile.rb"'
		#	Git.tag '','0.0.1'
			#{}`git checkout -b master`
			#expect(Git.branch).to eq('master')
		#end

		#expect(Git.branch wrk_dir).to eq('master')

		FileUtils.rm_r "#{File.dirname(__FILE__)}/git_spec" if File.exists? "#{File.dirname(__FILE__)}/git_spec"
		#FileUtils.rm_r wrk_dir if File.exists? wrk_dir
	end

	it "should be able to publish to a git repo" do

		#demo_dir="#{File.dirname(__FILE__)}/tmp/demo"
		#FileUtils.mkdir_p(demo_dir) if !File.exists? demo_dir
		#Dir.chdir(demo_dir) do
		#	File.open('ReadMe.txt','w'){|f|f.puts "README"}
		#	File.open('rakefile.rb','w'){|f|
		#		f.puts "task :default"
		#		f.puts "  puts 'test 0.0.2'"
		#		f.puts "end"
		#	}
		#end
		#def self.publish destination, source_dir, source_glob='**/*', tag
		#filelist = FileList.new('**/*.{txt,rb}')
		#Git.publish "https://github.com/lou-parslow/demo.git", demo_dir, filelist, '0.0.2'

		#FileUtils.rm_r demo_dir
	end
end