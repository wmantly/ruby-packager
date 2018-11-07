require 'packager/version'

require 'tmpdir'

class Packager
  class Executor
    attr_accessor :commands, :dryrun

    def initialize(opts={})
      self.dryrun = !!opts[:dryrun]
      self.commands = []
    end

    def execute_on(items)
      curdir = Dir.pwd
      items.collect do |item|
        Dir.mktmpdir do |tempdir|
          Dir.chdir(tempdir) do
            path = create_package_for(item)
            FileUtils.mv(path, curdir) if path
          end
        end
      end
    end

    def create_package_for(item)
      unless item.files.empty?
        item.files.each do |file|
          dest = (file.dest || '').gsub /^\//, ''
          FileUtils.mkdir_p File.dirname(dest)
          FileUtils.cp_r(file.source, dest)
        end
      end

      cmd = Packager::Struct::Command.new(
        :name     => item.name,
        :version  => item.version,
        :target   => item.type,
        :requires => item.requires,
        :provides => item.provides,
      )

      Dir.glob('*') do |entry|
        if File.directory?(entry)
          cmd.add_directory(entry)
        end
      end

      commands.push(cmd)

      execute_command(cmd)
    end

    def execute_command(cmd)
      if dryrun
        puts 'Dry run! This has not run or changed anything'
        puts "#{cmd.to_system.join(' ')}"
        return
      end

      x = `#{cmd.to_system.join(' ')}`
      rv = eval(x)
      raise rv[:error] if rv[:error]
      return rv[:path]
    end
  end
end
