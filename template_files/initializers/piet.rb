module Piet
  class << self

    def optimize(path, opts={})
      output = optimize_for(path, opts)
      puts output if opts[:verbose]
      true
    end

    alias :optimize_png_using_pngquant :optimize_png

    private
    def optimize_png(path, opts)
      if Application::Config.enabled?(:optimize_png_using_pngquant)
        self.pngquant(path)
      else
        optimize_png_using_pngquant(path, opts)
      end
    end

  end
end
