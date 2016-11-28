project = 'schleuder-cli'
require_relative "lib/#{project}.rb"

@version = SchleuderCli::VERSION
@tagname = "#{project}-#{@version}"
@gpguid = 'schleuder@nadir.org'

def move_sign_and_add(file)
  `mv -iv #{file} gems/`
  `cd gems && gpg -u #{@gpguid} -b #{file}`
  `git add gems/#{file}*`
end

task :publish_gem => :website
task :git_tag => :check_version

desc "Build new version: git-tag and gem-file"
task :new_version => [:check_version, :gem, :tarball, :edit_readme, :git_commit_version, :git_tag] do
end

desc "Edit README"
task :edit_readme do
  puts "Please edit the README to refer to version #{@version}"
  if system('gvim -f README.md')
    `git add README.md`
  else
    exit 1
  end
end

desc 'git-tag HEAD as new version'
task :git_tag do
  `git tag -u #{@gpguid} -s -m "Version #{@version}" #{@tagname}`
end

desc "Commit changes as new version"
task :git_commit_version do
  `git add lib/#{project}/version.rb`
  `git commit -m "Version #{@version} (README, gems)"`
end

desc 'Build, sign and commit a gem-file.'
task :gem do
  gemfile = "#{@tagname}.gem"
  `gem build #{project}.gemspec`
  move_sign_and_add(gemfile)
end

desc 'Publish gem-file to rubygems.org'
task :publish_gem do
  puts "Really push #{@tagname}.gem to rubygems.org? [yN]"
  if gets.match(/^y/i)
    puts "Pushing..."
    `gem push #{@tagname}.gem`
  else
    puts "Not pushed."
  end
end

desc 'Build and sign a tarball'
task :tarball do
  tarball = "#{@tagname}.tar.gz"
  `git archive --format tar.gz --prefix "#{@tagname}/" -o #{tarball} #{@tagname}`
  move_sign_and_add(tarball)
end

desc 'Describe manual release-tasks'
task :website do
  puts "Please update the website:
  * Update changelog.
  * Publish release-announcement.
"
end

desc 'Check if version-tag already exists'
task :check_version do
  # Check if Schleuder::VERSION has been updated since last release
  if `git tag`.include?(@tagname)
    $stderr.puts "Warning: Tag '#{@tagname}' already exists. Did you forget to update #{project}/version.rb?"
    $stderr.print "Delete tag to continue? [yN] "
    if $stdin.gets.match(/^y/i)
      `git tag -d #{@tagname}`
    else
      exit 1
    end
  end
end

