# modified version of rcov_plugin, includes rake tasks for Cucumber
# ===========
#
# This is a simple rails plugin that adds some useful rcov tasks.
#
#     rake test:coverage                # Tests coverage on the entire application
#     rake test:coverage:units          # Tests coverage for unit tests
#     rake test:coverage:functionals    # Tests coverage for functional tests
#     rake test:coverage:integration    # Tests coverage for integration tests
#
# The task ends up creating a coverage folder with an html coverage report in it.
#
# SHOW_ONLY is a comma-separated list of the files you'd like to see (although
# you can only run functionals, you still see all the models and helpers which
# are 'touched'). Right now there are four types of files rake test:coverage
# recognizes: models, helpers, controllers, and lib. These can be abbreviated
# to their first letters:
#
#     rake test:coverage SHOW_ONLY=models
#     rake test:coverage SHOW_ONLY=helpers,controllers
#     rake test:coverage SHOW_ONLY=h,c
#
# JRuby Support
# =============
# rcov_plugin works great with JRuby.
#
# If using JRuby, remember to run rake with it, like this:
#     jruby -S rake test:coverage
#
# Special thanks go to Leonard Borges ([http://www.leonardoborges.com](http://www.leonardoborges.com)) for getting the plugin working with JRuby.
#
# Requirements
# ============
#
# This task requires that you have rcov installed and on your path.
#
# Contributors
# ============
# Special thanks go to all of the contributors to this plugin:
#
# * leonardoborges
# * dovadi
# * baldowl
# * archfear
#
# License
# =======
# Copyright (c) 2008 Alan Johnson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# uncomment to include Cucumber feature tests in Rcov coverage
# require 'cucumber/rake/task'

def run_coverage(files)
  rm_f "coverage"
  rm_f "coverage.data"

  # turn the files we want to run into a string
  if files.empty?
    puts "No files were specified for testing"
    return
  end

  files = files.join(" ")

  if RUBY_PLATFORM =~ /darwin/
    exclude = '--exclude "gems/*" --exclude "Library/Frameworks/*"'
    exclude << " --exclude osx\/objc,gems\/,spec\/,features\/"
  elsif RUBY_PLATFORM =~ /java/
    exclude = '--exclude "rubygems/*,jruby/*,parser*,gemspec*,_DELEGATION*,eval*,recognize_optimized*,yaml,yaml/*,fcntl"'
  else
    exclude = '--exclude "rubygems/*"'
  end

  # rake test:units:rcov SHOW_ONLY=models,controllers,lib,helpers
  # rake test:units:rcov SHOW_ONLY=m,c,l,h
  if ENV['SHOW_ONLY']
    params = String.new
    show_only = ENV['SHOW_ONLY'].to_s.split(',').map{|x|x.strip}
    if show_only.any?
      reg_exp = []
      for show_type in show_only
        reg_exp << case show_type
        when 'm', 'models' then 'app\/models'
        when 'c', 'controllers' then 'app\/controllers'
        when 'h', 'helpers' then 'app\/helpers'
        when 'l', 'lib' then 'lib'
        else
          show_type
        end
      end
      reg_exp.map!{ |m| "(#{m})" }
      params << " --exclude \"^(?!#{reg_exp.join('|')})\""
    end
    exclude << params
  end

  rcov_bin = RUBY_PLATFORM =~ /java/ ? "jruby -S rcov" : "rcov"
  rcov = "#{rcov_bin} --rails -Ilib:test --sort coverage --text-report #{exclude} --aggregate coverage.data"
  puts
  puts
  puts "Running tests..."
  cmd = "#{rcov} #{files}"
  puts cmd
  system cmd
end

namespace :test do
  desc "Measures unit, functional, integration and Cucumber test coverage"
  task :coverage do
    run_coverage Dir["test/unit/**/*.rb", "test/functional/**/*.rb", "test/integration/**/*.rb"]
    # uncomment to include Cucumber feature tests in Rcov coverage
    # Rake::Task["test:coverage:cucumber_run"].invoke
  end

  namespace :coverage do
    desc "Runs coverage on unit tests"
    task :units do
      run_coverage Dir["test/unit/**/*.rb"]
    end

    desc "Runs coverage on functional tests"
    task :functionals do
      run_coverage Dir["test/functional/**/*.rb"]
    end

    desc "Runs coverage on integration tests"
    task :integration do
      run_coverage Dir["test/integration/**/*.rb"]
    end

    # uncomment to include Cucumber feature tests in Rcov coverage
    # Cucumber::Rake::Task.new(:cucumber_run) do |t|
    #   t.rcov = true
    #   t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
    #   t.rcov_opts << %[-o "coverage"]
    # end
    #
    # desc "Runs coverage on Cucumber tests"
    # task :cucumber do
    #   rm_f "coverage"
    #   rm_f "coverage.data"
    #   Rake::Task["test:coverage:cucumber_run"].invoke
    # end
  end
end
