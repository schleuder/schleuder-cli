project = 'schleuder-conf'
require_relative "lib/#{project}.rb"

version = SchleuderConf::VERSION
tagname = "#{project}-#{version}"
gpguid = 'schleuder2@nadir.org'

task :gem => :check_version
task :git_tag => :check_version

desc "Build new version: git-tag and gem-file"
task :build => [:gem, :edit_readme, :git_tag] do

end

desc "Edit README"
task :edit_readme do
  say "Please edit the README to refer to version #{version}"
  `gvim -f README.md`
  `git commit README.md -m "Reference #{version} in README"`
end

desc 'git-tag HEAD as new version and push to origin'
task :git_tag do
  `git tag -u #{gpguid} -s -m "Version #{version}" #{tagname}`
  #`git push && git push --tags`
end

desc 'Build, sign and commit a gem-file.'
task :gem do
  gemfile = "#{tagname}.gem"
  `gem build #{project}.gemspec`
  `mv -iv #{gemfile} gems/`
  `cd gems && gpg -u #{gpguid} -b #{gemfile}`
  `git add gems/#{gemfile}*`
  `git commit -m "Gem-file and OpenPGP-sig for #{version}"`
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

