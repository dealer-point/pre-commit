module PreCommit
  class Line < Struct.new :message, :file, :line, :code

    def to_s
      result = message.to_s.red
      unless empty? file
        result = "#{result}#{"\n" unless empty?(result)}#{file.cyan}"
        result = "#{result}:#{line.magenta}" unless empty? line
        result = "#{result}:#{code.white}" unless empty? code
      end
      result
    end

  protected

    def empty?(string)
      string == nil || string == ""
    end

  end
end

