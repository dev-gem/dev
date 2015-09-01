require 'fileutils'
require 'tmpdir'
require_relative('../base/dir.rb')
class Svn

	def self.latest_revision
	    if(Dir.exists?(".svn"))
	      `svn update`
		  `svn info`.scan(/Last Changed Rev: ([\d]+)/).each{|m|
		    return m.first.to_s
		  }
		end
		"0"
	end

	def self.url
		if(Dir.exists?(".svn"))
		  `svn info`.scan(/URL: ([:\/\.\-\d\w]+)/).each{|m|
		    return m.first.to_s
		  }
		end
		''
	end

	def self.export url, destination
		if(!File.exists?(destination.chomp('@')))
			`svn export #{url} #{destination}`
		end
	end

	def self.has_changes? directory=''
        directory=Dir.pwd if directory.length==0
        Dir.chdir(directory) do
            if(File.exists?('.svn'))
                return true if `svn status`.scan(/^[MA]/).length>0
            end
        end
        false
    end

    def self.add source, directory=''
    	directory=Dir.pwd if directory.length < 1
    	Dir.chdir(directory) do
	      	source.each{|f|
				puts `svn add #{f} --parents` if `svn status #{f}`.include?('?')
				puts `svn add #{f} --parents` if !system("svn status #{f}")
			}
		end
    end

    def self.append_commit_message message,directory=''
    	directory=Dir.pwd if directory.length < 1
    	Dir.chdir(directory) do
    		
    	end
    end

    def self.commit message, directory=''
    	directory=Dir.pwd if directory.length < 1
    	Dir.chdir(directory) do
    		# svn commit -F commit_message_filename
    		puts `svn commit -m"commit all"`
    		`svn update`
    	end
    end

	# publish a directory to a new subversion path
	# source_dir is the directory with the files to be published
	# destination is the new subversion path URL
	# source_glob is a string or array of glob directives to specify files in source_dir to be publish
	# source_glob defaults to '**/*' to publish all files in the source_dir
	def self.publish destination, source_dir, source_filelist=FileList.new('**/*')

		# Support for legacy argument order
		if(source_dir.include?('svn:') || source_dir.include?('http:') || source_dir.include?('https:'))
			# swap arguments
			tmp=source_dir
			source_dir=destination
			destination=tmp
		end

		output = "\n"
		if(`svn info #{destination} 2>&1`.include?('Revision:'))
			puts "Svn.publish: destination #{destination} already exists" 
		else
			# create subversion directory
			output = output + "svn mkdir #{destination} --parents --message mkdir_for_publishing"
			if(!`svn mkdir #{destination} --parents --message mkdir_for_publishing`.include?('Committed'))
				raise "failure 'svn mkdir #{destination} --parents --message mkdir_for_publishing'"
			end

			Dir.chdir(source_dir) do
				files = source_filelist.to_a
			end
			files=source_filelist
			output = output + "\nfiles: "
			files.each{|f|
				output = output + f + " "
			}
			pwd=Dir.pwd
			Dir.mktmpdir{|dir|

				# checkout new subversion directory
				output = output + "\nsvn checkout #{destination} #{dir}/to_publish_checkout"
				if(!`svn checkout #{destination} #{dir}/to_publish_checkout`.include?('Checked out'))
					raise "failure 'svn checkout #{destination} #{dir}/to_publish_checkout'"
				end

				# copy files into the checkout out subversion directory to_publish
				raise "#{dir}/to_publish_checkout does not exist" if(!File.exists?("#{dir}/to_publish_checkout"))
				Dir.chdir("#{dir}/to_publish_checkout") do
					File.open('add.txt','w'){|add_file|

						files.each{|f|
							fdir=File.dirname(f)
							FileUtils.mkdir_p(fdir) if(fdir.length > 0 && !File.exists?(fdir))
							FileUtils.cp("#{source_dir}/#{f}","#{f}")
							add_file.puts f
						}
						add_file.close
					}

					output = output + "\nsvn add --parents --targets add.txt 2>&1"
	                `svn add --parents --targets add.txt 2>&1`
					commit_output = `svn commit -m"add" 2>&1`
					output = output + "\n#{commit_output}"
					if(!commit_output.include?("Committed"))
						raise "failure 'svn commit -m'added files''" + output
					end
				end
				
				#begin
				Dir.remove "#{dir}/to_publish_checkout"
				output
			}
		end
	end
end