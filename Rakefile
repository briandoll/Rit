# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'metric_fu'

  MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :saikuro, :stats, :flog, :flay, :reek, :roodi]
    config.graphs   = [:flog, :flay, :reek, :roodi]
    config.flay     = { :dirs_to_flay => ['app', 'lib'], :minimum_score => 100 }
    config.flog     = { :dirs_to_flog => ['app', 'lib']  }
    config.reek     = { :dirs_to_reek => ['app', 'lib']  }
    config.roodi    = { :dirs_to_roodi => ['app', 'lib'] }
    config.saikuro  = { :output_directory => 'scratch_directory/saikuro',
      :input_directory => ['app', 'lib'],
      :cyclo => "",
      :filter_cyclo => "0",
      :warn_cyclo => "5",
      :error_cyclo => "7",
      :formater => "text"}
    config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
    config.graph_engine = :bluff
  end

  desc "test + metrics"
  task :full_suite => ['test', 'metrics:all']

rescue LoadError => e
  desc "test + metrics"
  task :full_suite => ['test']
end
