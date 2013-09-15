module Beer
  module Utils

    # Pauses main thread on given @interval, while the @block is executed in child thread
    # @interval [Float] pause length in seconds
    #
    class TimedThread
      Thread.abort_on_exception = true

      def initialize(interval, &block)
        started = Time.now
        t = Thread.new(&block)
        elapsed = Time.now - started
        sleep([interval - elapsed, 0].max)
        t.join
      end
    end

  end
end
