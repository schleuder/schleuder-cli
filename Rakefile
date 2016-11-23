project = 'schleuder-conf'
require_relative "lib/#{project}.rb"

version = SchleuderConf::VERSION
tagname = "#{project}-#{version}"
gpguid = 'schleuder@nadir.org'

task :gem => :check_version
task :git_tag => :check_version

desc "Build new version: git-tag and gem-file"
task :new_version => [:gem, :edit_readme, :git_commit_version, :git_tag] do
end

desc "Edit README"
task :edit_readme do
  puts "Please edit the README to refer to version #{version}"
  if system('gvim -f README.md')
    `git add README.md`
  else
    exit 1
  end
end

desc 'git-tag HEAD as new version'
task :git_tag do
  `git tag -u #{gpguid} -s -m "Version #{version}" #{tagname}`
end

desc "Commit changes as new version"
task :git_commit_version do
  `git add lib/#{project}/version.rb`
  `git commit -m "Version #{version} (README, gems)"`
end

desc 'Build, sign and commit a gem-file.'
task :gem do
  gemfile = "#{tagname}.gem"
  `gem build #{project}.gemspec`
  `mv -iv #{gemfile} gems/`
  `cd gems && gpg -u #{gpguid} -b #{gemfile}`
  `git add gems/#{gemfile}*`
end

desc 'Check if version-tag already exists'
task :check_version do
  # Check if Schleuder::VERSION has been updated since last release
  if `git tag`.include?(tagname)
    $stderr.puts "Warning: Tag '#{tagname}' already exists. Did you forget to update #{project}/version.rb?"
    $stderr.print "Continue? [yN] "
    if $stdin.gets.match(/^y/i)
      `git tag -d #{tagname}`
    else
      exit 1
    end
  end
end

