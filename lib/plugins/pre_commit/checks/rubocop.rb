require 'stringio'
require 'pre-commit/checks/plugin'

module PreCommit
  module Checks
    class Rubocop < Plugin

      WHITELIST = %w[
        \.gemspec \.jbuilder \.opal \.podspec \.rake \.rb config\.ru
        Berksfile Capfile Cheffile Gemfile Guardfile Podfile
        Rakefile Thorfile Vagabondfile Vagrantfile
      ]

      def self.aliases
        [ :rubocop_all, :rubocop_new ]
      end

      def self.excludes
        [ :ruby_symbol_hashrocket ]
      end

      def call(staged_files)
        require 'rubocop'
      rescue LoadError => e
        $stderr.puts "Could not find rubocop: #{e}"
      else
        staged_files = filter_staged_files(staged_files)
        return if staged_files.empty?

        args = config_file_flag + user_supplied_flags + ["--force-exclusion"] + staged_files

        success, captured = capture { ::RuboCop::CLI.new.run(args) == 0 }
        colorize(captured) unless success
      end

      def colorize(value)
        value.gsub(/^([^:\n]+):(\d+):(\d+):(.+)$/) do |line|
          "#{$1.to_s.cyan}:#{$2.to_s.magenta}:#{$3.to_s.magenta}: #{$4.to_s.white}"
        end.gsub(/(\^+)/) do |line|
          "#{$1.to_s.red}"
        end
      end

      def filter_staged_files(staged_files)
        expression = Regexp.new(WHITELIST.map { |i| i + "\\Z" }.join("|"))
        staged_files.grep(expression)
      end

      def capture
        $stdout, stdout = StringIO.new, $stdout
        $stderr, stderr = StringIO.new, $stderr
        result = yield
        [result, $stdout.string + $stderr.string]
      ensure
        $stdout = stdout
        $stderr = stderr
      end

      def config_file_flag
        config_file ? ['-c', config_file] : []
      end

      def user_supplied_flags
        Array(config.get('rubocop.flags')).reject(&:empty?)
      end

      def alternate_config_file
        '.rubocop.yml'
      end

      def self.description
        "Runs rubocop to detect errors."
      end
    end
  end
end
