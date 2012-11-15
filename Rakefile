require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

desc "Run all specs with rcov"
RSpec::Core::RakeTask.new("spec:coverage") do |t|
  t.rcov = true
  # t.rcov_opts = %w{--rails --include views -Ispec --exclude gems\/,spec\/,features\/,seeds\/}
  # t.rspec_opts = ["-c"]
end
# RCov::VerifyTask.new(:verify_rcov => 'spec:rcov') do |t|
#   t.threshold = 100.0
#   t.index_html = 'coverage/index.html'
# end
# RSpec::Core::RakeTask.new(:spec) do |t|
  # t.pattern = "**/*_spec.rb" #Dir.glob('spec/**/*_spec.rb')
  # t.spec_opts << '--format specdoc'
  # t.rcov = true
# end

task :default => :spec
task :test => :spec