
module Blender
  module Exceptions
    class ExecutionFailed < RuntimeError; end
    class UnsupportedFeature < ArgumentError; end
    class UnknownTransport < ArgumentError; end
    class UnknownTask < ArgumentError; end
    class UnknownSchedulingStrategy < ArgumentError; end
  end
end
