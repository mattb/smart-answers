module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end

    def initialize(load_path = nil)
      @load_paths = !load_path.nil? ? [Pathname.new(load_path)] : [Pathname.new(Rails.root.join('lib','flows'))]
      @load_paths << Pathname.new(Rails.root.join('test', 'fixtures')) if Rails.env.test?

      preload_flows! if Rails.env.production?
    end

    def find(name)
      raise NotFound unless available?(name)

      absolute_path = @load_paths.map do |load_path|
        absolute_path = load_path.join("#{name}.rb").to_s
        File.exists?(absolute_path) ? absolute_path : nil
      end.compact.first

      preloaded(name) || Flow.new do
        eval(File.read(absolute_path), binding, absolute_path)
        name(name)
      end
    end

    def available?(name)
      available_flows.include?(name)
    end

    def available_flows
      @load_paths.map do |load_path| 
        Dir[load_path.join('*.rb')].map do |path|
          File.basename(path).gsub(/\.rb$/, '')
        end
      end.flatten
    end

    def flows
      available_flows.map { |s| find(s) }
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = find(flow_name)
      end
    end

    def preloaded(name)
      @preloaded && @preloaded[name]
    end
  end
end
