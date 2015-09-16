#! /usr/bin/ruby -w

require 'optparse'

# Expanding the built in Dir class, with a purge function.
# Purge, will delete all files recursively that are older 
# than the given date.
class Dir

  def purge(options)
    
    count = 0
    one_day = 60*60*24 #addition with the Time object requires seconds

    self.each { |f|
      if f !~ /^(\.{1,2})$/
        file = File.join(self.path, f)

        ft = File.stat(file).mtime
        ft += one_day * options[:age]

        if ft < Time.now
          count += 1
          if options[:simulate]
            puts file
          else
            File.delete(file)
          end
        elsif File.stat(file).directory?
          d = Dir.new(file)
          d.purge(date)
        end
      end
    }

    if options[:simulate]
      would_be = "would be"
    else
      would_be = ""
    end
    puts "#{count} old files #{would_be} deleted."
  end

end


def get_opts(args)

  options = {}
  opts = OptionParser.new do |opts|
    #opts.banner = "Usage: #0 [options]"
    opts.on("-d", "--directory DIRECTORY", "Directory in which to purge old files. Does not" + 
      "\n\t\t\t\trun correctly on the current directory. It is better" + 
      "\n\t\t\t\tto run from the parent.") do |dir|
      tmpdir = Dir.new(dir)
      options[:directory] = dir
    end
    opts.on("-a", "--age AGE", "Will delete all files older than age (in days).") do |o|
      options[:age] = Integer(o)
    end
    opts.on("-s", "--simulate", "Only print file names that would be deleted.") do |o|
      options[:simulate] = o
    end
    opts.on_tail("-h", "--help", "Show this usage statement.") do |m|
      options[:help] = true
      puts opts
    end
  end

  begin
    opts.parse!(args)
  rescue Exception => e
    puts e, "", opts
    exit
  end

  exit if options[:help]

  if !options[:directory] || !options[:age]
    puts "Missing required arguments."
    puts opts
    exit
  end

  return options
end

options = get_opts(ARGV)

dir = Dir.new(options[:directory])
dir.purge(options)

