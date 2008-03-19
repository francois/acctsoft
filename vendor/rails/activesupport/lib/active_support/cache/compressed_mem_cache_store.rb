module ActiveSupport
  module Cache
    class CompressedMemCacheStore < MemCacheStore
      def read(name, options = {})
        if value = super(name, options.merge(:raw => true))
          Marshal.load(ActiveSupport::GZip.decompress(value))
        end
      end

      def write(name, value, options = {})
        super(name, ActiveSupport::GZip.compress(Marshal.dump(value)), options.merge(:raw => true))
      end
    end
  end
end
