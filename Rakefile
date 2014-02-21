desc 'Run specs'
task :spec do
  puts 'No automated tests yet - please manually test the examples'
  # sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  puts 'No automated tests yet - please manually test the examples'
  # sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  puts 'No automated tests yet - please manually test the examples'
  # sh 'rspec -cfd --tty | less -R'
end

desc 'Check for warnings'
task :warn do
  sh 'ruby -w -I lib -r eftcmdr -e ""'
end

desc 'Run example foo'
task 'example:foo' do
  sh 'ruby -w -I lib bin/eftcmdr examples/foo.yml'
end

desc 'Run example bar'
task 'example:bar' do
  sh 'ruby -w -I lib bin/eftcmdr examples/bar.yml'
end

desc 'Run example qux'
task 'example:qux' do
  sh 'ruby -w -I lib bin/eftcmdr examples/qux.yml'
end

desc 'Run example hello'
task 'example:hello' do
  sh 'ruby -w -I lib bin/eftcmdr examples/hello.yml'
end

desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end

desc 'Cleanup'
task :clean do
  sh 'rm -rf .yardoc/ doc/ *.gem'
end

desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/eftcmdr/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build eftcmdr.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/eftcmdr/version.rb'
end
