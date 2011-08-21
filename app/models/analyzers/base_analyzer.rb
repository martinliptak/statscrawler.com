module Analyzers
  class BaseAnalyzer
    def initialize(headers, body)
      @headers = headers
      @data = body
    end

    def run()
      @document = Nokogiri::HTML(@data)
      @result = { :features => [] }
      yield self
      @result[:features].uniq!
      @result
    end

    # HTTP headers
    def header(name)
      yield @headers[name] if @headers[name]
    end

    # Regexps over raw HTML
    def regexp(exp)
      begin
        match = exp.match(@data)
        yield match if match
      rescue ArgumentError # velmi zriedkava UTF8 chyba
      end
    end

    # DOM element
    def element(path)
      @document.css(path).each do |script|
        yield script
      end
    end

    # DOM attribute
    def attribute(script, attr)
      yield script[attr] if script[attr]
    end

    # filename from path
    def filename(path)
       yield $2 if /(\/|^)([^\/]*$)/i.match(path)
    end

    # meta name=generator
    def generator
      generator = @document.css("meta[name=generator], meta[name=Generator]").first
      yield generator["content"] if (generator and generator["content"])
    end

    def framework_in?(frameworks)
      frameworks.index(@result[:framework])
    end

    # Feature's attributes
    def server(val)
      @result[:server] = val
    end

    def engine(val)
      @result[:engine] = val unless @engine_final
    end

    def engine_final(val)
      @result[:engine] = val
      @engine_final = true
    end

    def doctype(val)
      @result[:doctype] = val
    end

    def framework(val)
      @result[:framework] = val unless @final
    end

    def framework_final(val)
      @result[:framework] = val
      @final = true
    end

    def feature(val)
      @result[:features] << val
    end
  end
end