require 'bundler'
require_relative 'gemfile_filter'
require_relative 'dependency'

module KeepUp
  # A Gemfile with its current set of locked dependencies.
  class Bundle
    def direct_dependencies
      bundler_lockfile.dependencies.map do |dep|
        spec = locked_spec dep
        next unless spec
        Dependency.new(name: dep.name,
                       version: dep.requirements_list.first,
                       locked_version: spec.version)
      end.compact
    end

    def apply_updated_dependency(dependency)
      puts "Updating #{dependency.name} to #{dependency.version}"
      update_gemfile_contents(dependency)
      update_lockfile(dependency)
    end

    private

    def locked_spec(dep)
      bundler_lockfile.specs.find { |it| it.name == dep.name }
    end

    def bundler_lockfile
      @bundler_lockfile ||= Bundler::LockfileParser.new(File.read('Gemfile.lock'))
    end

    def update_gemfile_contents(dependency)
      current_dependency = direct_dependencies.find { |it| it.name == dependency.name }
      if current_dependency && current_dependency.matches?(dependency)
        return
      end
      contents = File.read 'Gemfile'
      updated_contents = GemfileFilter.apply(contents, dependency)
      File.write 'Gemfile', updated_contents
    end

    def update_lockfile(dependency)
      Bundler::Definition.build('Gemfile', 'Gemfile.lock',
                                gems: [dependency.name]).lock('Gemfile.lock')
      true
    rescue Bundler::VersionConflict
      puts 'Update failed'
      false
    end
  end
end