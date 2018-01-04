# frozen_string_literal: true

module KeepUp
  # Interface to the version control system (only Git is supported).
  class VersionControl
    def commit_changes(dependency)
      `git commit -am "Auto-update #{dependency.name} to #{dependency.version}"`
    end

    def revert_changes
      `git reset --hard`
    end

    def clean?
      `git status -s` == ''
    end
  end
end
