module ThreadedMergeSort

  def self.sort(arr, time, &block)
    arr
  end

  class CanceledError < ThreadError; end
  class TimeoutError < ThreadError; end

  class Sorter
    def result

    end

    def cancel

    end
  end
end