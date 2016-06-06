module Piet
  class << self

    def optimize(path, opts={})
      output = optimize_for(path, opts)
      puts output if opts[:verbose]
      true
    end

    private
    def optimize_png(path, opts)
      if Application::Config.enabled?(:optimize_png_using_pngquant)
        self.pngquant(path)
      else
        super(path, opts)
      end
    end

  end
end
