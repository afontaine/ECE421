require 'test/unit'
require_relative '../data/timer'

class TimerTest < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_message
    assert_equal('testing', Timer::timer(1, 'testing'))
    assert_equal('', Timer::timer(1, ''))
  end

  def test_time_limits
    assert_raise(Timer::TimeTooLongError) { Timer::timer((2**(0.size * 8 -2) -1) + 1, 'testing') }
    assert_raise(Timer::TimeCannotBeNegativeError) { Timer::timer(-1, 'testing') }
  end

  def test_message_limits
    assert_raise(Timer::MessageTooLongError) { Timer::timer(1, 'a' * 256) }
    assert_nothing_raised { Timer::timer(1, '') }
  end

  def test_new_process
    ruby = `ps | grep ruby | wc -l`.to_i
    Timer::start(100000000, "started")
    assert_equal(ruby + 1, `ps | grep ruby | wc -l`.to_i)
  end

end
