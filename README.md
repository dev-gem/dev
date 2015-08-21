#dev  <img src="https://badge.fury.io/rb/dev.png" alt="Gem Version" />
The dev gem automatically generate rake tasks for a project directory
based on specific file types that is recognizes. These include
Git (.git directory)
Subversion (.svn directory)
Visual Studio .sln files
Nuget .nuspec files

The gem defined DEV as a hash, which is populated based on the content
of the directory in which the rakefile.rb resides.
The dev gem provides task definitions to support the development of ruby,c#,c++ and c projects.
The DEV variable may be manipulated to modify the behavior of defined tasks or to 
cause additional task to be generated.

##Installation and Setup
dev can be installed by the single command

    gem install dev


(Optional) Add an environment variable DEV_ROOT assigned to the directory that will act as the root directory for the dev gem.
The dev_root directory is root directory for the dev gem. On Windows this defaults to the USERPROFILE environment variable. On unix/OSX this defaults to the HOME environment variable. The dev_root directory may be changed by setting the DEV_ROOT environment variable on your system.

##Usage

    require 'dev'

##Recognized Applications
###[git](https://git-scm.com)
###[svn](https://subversion.apache.org)
###[msbuild](https://msdn.microsoft.com/en-us/library/0k6kkbsd.aspx)
###[nuget](https://www.nuget.org/packages/NuGet.CommandLine)
###[candle (WiX Toolset)](http://wixtoolset.org)
###[light](http://wixtoolset.org)

##Directory Structure
The directories uses by dev gem are located in DEV_ROOT.

###dep
dependency directory, where files that are shared across multiple projects may be placed.
###wrk
The working directory, where source code resides.
The example project located at http://github.com/dev-gem/hello.gem.git would be cloned into [DEV_ROOT]/wrk/github/dev-gem/hello.gem
##Reference
###Variables
####DEV is a global instance of a Hash. The variable is define by require 'dev' statement
DEV may define several keys automatically
  DEV[:scm_uri]   # the uri for the source code management system.
  DEV[:scm_type]  # the type of source code managment, (none,svn,git).
  DEV[:directory] # the full directory name of the rakefile.rb.
  DEV[:fullname]  # the name of the project (inferred by directory structure relative to DEV_ROOT).
  DEV[:version]   # the version specified by the .semver file.
  DEV[:src_glob]  # the glob pattern(s) defining the source files.
  DEV[:dev_root]  # the root working directory ENV['DEV_ROOT'] if defined, otherwise user home directory.
  DEV[:toolset]   # the boost build toolset, if available
  DEV[:paths]     # a hash containing various environment paths
####CLEAN is a Rake::FileList that specifies file(s) to be removed during the clean task.
  CLEAN.include('doc')
####CLOBBER is a Rake::FileList that specifies file(s) to be removed during the clobber task.
  CLOBBER.include('obj')
###Tasks
dev will automatically generated the following tasks as applicable.
  rake add       # add files defined by src_glob to source code management, not generated if no scm can be detected.
  rake check     # checks if the project default task may be skipped
  rake clean     # Remove any temporary products.
  rake clobber   # Remove any generated file.
  rake commit    # commits to scm. not generated if no scm detected.
  rake compile   # compile command(s). 
  rake features  # tests cucumber features
  rake info      # display information about the rakefile
  rake replace   # replace text
  rake setup     # setup the project environment
  rake test      # run unit tests
  rake update    # updates changes from source code management
  rake default   # the default task for the rakefile

If either pre_compile or post_compile tasks are manually created, then TASKS.refresh is called,
these task will be executed in the correct sequence (either before or after compile task) by the default task
  require 'dev'

  task :pre_compile do
    puts 'pre_compile'
  end

  task :post_compile
    puts 'post_compile'
  end

  TASKS.refresh

the default task is automatically generated by require 'dev'. It will be defined as dependent on the following tasks if they are defined:
  ["check","setup","replace","pre_compile","compile","post_compile","pre_test",
   "test","post_test","add","commit","update","clean","finalize"]
to prevent the default task from being defined, define DEV_NO_DEFAULT_TASK prior to require 'dev'
  DEV_NO_DEFAULT_TASK=1
  require 'dev'

  # now, can manually define default task
  task :default do
    puts "hello default task"
  end
to provide a custom set of default dependencies, the DEFAULT_TASK_ORDER may be defined prior to require 'dev',
then a call to TASKS.refresh can be made to redefine the default task
  DEFAULT_TASK_ORDER=["step1","step2"]
  require 'dev'

  task :step1 do
    puts "step1"
  end

  task :step2 do
    puts "step2"
  end

  TASKS.refresh    

##License
Copyright 2012-2013 Lou Parslow

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
