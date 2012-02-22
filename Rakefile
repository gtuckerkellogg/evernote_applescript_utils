# -*- Mode: Ruby -*-
require 'rake/clean'
require 'fileutils'

DESTDIR = File.join(ENV['HOME'], 'Library', 'Scripts')

SRC = FileList['scripts/*.applescript']
SCPTSDIR = 'build'
SCPTS = SRC.collect { |s| 
  File.join(SCPTSDIR, s.sub(/scripts\/(.+)\.applescript$/, '\1.app')) 
}
CLEAN.include(SCPTS)
CLEAN.include(SCPTSDIR)

verbose true

# Create directories for the build output
SCPTS.each do |s|
    directory File.dirname(s)
end
directory DESTDIR

rule '.app' => lambda { |scpt| find_source(scpt) } do |t|
    # Make sure the directory exists
    Rake::Task[File.dirname(t.name)].invoke
    # Compile execute-only (-x)
    sh "osacompile -x -o '#{t.name}' '#{t.source}'"
end

# We want to build into a parallel directory structure, so this is used to go
# find the applescript
def find_source(scpt)
    base = File.basename(scpt, '.app')
    SRC.find { |s| File.basename(s, '.applescript') == base }
end

desc 'Compile the scripts as Applications'
task :compile => SCPTS do
end

desc "Install scripts to #{DESTDIR}."
task :install => [:compile] do
    Rake::Task[DESTDIR].invoke
    SCPTS.each do |s|
        # Strip off SCPTSDIR, append to DESTDIR
        d = File.join(DESTDIR, s.split(File::Separator)[1..-1])
        # Make sure the directory exists
        directory File.dirname(d)
        Rake::Task[d].invoke
        puts "cp #{s} #{d}" if verbose
        FileUtils.cp_r(s, d)
    end
end

desc "Install scripts to #{DESTDIR} and clean up."
task :installclean => [:install, :clean] do
end

task :default do
  puts "run one of the following:"
  sh "rake -T"
end 
