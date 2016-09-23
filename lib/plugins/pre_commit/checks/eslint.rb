require 'pre-commit/checks/shell'

module PreCommit
  module Checks
    class Eslint < Shell

      def call(staged_files)
        return "Eslint not installed".red unless File.exist?("./node_modules/.bin/eslint")

        staged_files = staged_files.grep(/\.js$/)
        return if staged_files.empty?

        result =
        in_groups(staged_files).map do |files|
          args = %w{./node_modules/.bin/eslint} + config_file_flag + files
          colorize(execute(args))
        end.compact

        result.empty? ? nil : result.join("\n")
      end

      def colorize(value)
        value.to_s.gsub(/^(\s+\d+):(\d+)(\s+[^\s]+)(\s+.*?)$/) do |line|
          "#{$1.to_s.cyan}:#{$2.to_s.cyan}#{$3.to_s.red}#{$4.to_s.white}"
        end
      end

      def config_file_flag
        config_file ? ['-c', config_file] : []
      end

      def alternate_config_file
        '.scss-lint.yml'
      end

      def self.description
        "Runs scss lint to detect errors"
      end

    end
  end
end
