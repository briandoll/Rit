namespace :whitespace do
  FIND_FILE_BLACKLIST = "find . -type f | grep -v -e '.git/' -e 'coverage/' -e 'log/' -e 'public/' -e 'script/' -e 'tmp/' -e 'vendor/' -e '.data' -e '.DS_Store'  -e '.png' -e '.sqlite3'"

  desc 'Runs all whitespace tasks'
  task :all do
    Rake::Task["whitespace:remove_trailing"].invoke
    Rake::Task["whitespace:covert_to_soft_tabs"].invoke
    Rake::Task["whitespace:remove_blank_lines"].invoke
  end

  desc 'Removes trailing whitespace'
  task :remove_trailing do
    system %{
      echo Removing trailing whitespace
      for f  in `#{FIND_FILE_BLACKLIST}`;
        do cat $f | sed 's/[ \t]*$//' > .whitespace; cp .whitespace $f; rm .whitespace; echo $f;
      done
    }
  end

  desc 'Converts hard-tabs into two-space soft-tabs'
  task :covert_to_soft_tabs do
    system %{
      echo Converting hard-tabs into two-space soft-tabs
      for f in `#{FIND_FILE_BLACKLIST}`;
        do cat $f | sed 's/\t/  /g' > .soft_tabs; cp .soft_tabs $f; rm .soft_tabs; echo $f;
      done
    }
  end

  desc 'Remove consecutive blank lines'
  task :remove_blank_lines do
    system %{
      echo Removing consecutive blank lines
      for f in `#{FIND_FILE_BLACKLIST}`;
        do cat $f | sed '/./,/^$/!d' > .blank_lines; cp .blank_lines $f; rm .blank_lines; echo $f;
      done
    }
  end
end
