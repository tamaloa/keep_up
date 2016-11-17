module KeepUp
  class RemoteIndex
    def search(dependency)
      remote_index.search(Bundler::Dependency.new(dependency.name, nil))
    end

    def remote_definition
      @remote_definition ||=
        Bundler::Definition.build('Gemfile', 'Gemfile.lock', true).tap do |dfn|
          dfn.resolve_remotely!
        end
    end

    def remote_index
      @remote_index ||= remote_definition.index
    end
  end
end