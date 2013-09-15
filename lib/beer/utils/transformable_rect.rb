require 'delegate'

module Beer
  module Utils

    class TransformableRect < DelegateClass(Rect)
      def initialize(rect)
        super(rect)
        @rect = rect
      end

      def half_left_rect
        make_rect(@rect.dup.tap { |r| r.w /= 2 })
      end

      def half_top_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2 })
      end

      def half_right_rect
        make_rect(@rect.dup.tap { |r| r.w /= 2; r.x += r.w })
      end

      def half_bottom_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2; r.y += r.h })
      end

      def top_left_quarter_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2 })
      end

      def top_right_quarter_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.x += r.w })
      end

      def bottom_left_quarter_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.y += r.h })
      end

      def bottom_right_quarter_rect
        make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.x += r.w; r.y += r.h })
      end

      def make_rect(rect)
        self.class.new(rect)
      end
      private :make_rect
    end

  end
end

