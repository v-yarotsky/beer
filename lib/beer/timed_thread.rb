module Beer

  class TimedThread
    def initialize(interval, &block)
      started = Time.now
      t = Thread.new(&block)
      elapsed = Time.now - started
      sleep([interval - elapsed, 0].max)
      t.join
    end
  end

end
