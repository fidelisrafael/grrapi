module ActiveModel
  class ArraySerializer
    alias :_custom_initialize :initialize

    attr_reader :each_serializer_meta

    def initialize(object, options = {})
      @each_serializer_meta = options[:each_serializer_meta]

      _custom_initialize(object, options)
    end

    def serializer_for(item)
      serializer_class = @each_serializer || Serializer.serializer_for(item) || DefaultSerializer
      serializer_class.new(item, scope: scope, key_format: key_format, only: @only, except: @except, meta: @each_serializer_meta)
    end
  end
end
