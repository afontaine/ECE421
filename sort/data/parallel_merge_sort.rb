module ParallelMergeSort

  def self.sort(arr, time, &block)
    arr
  end

  class CanceledError < ThreadError; end
  class TimeoutError < ThreadError; end

  class ParallelSort
    def result

    end

    def cancel

    end
  end
end