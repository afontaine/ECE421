require 'test/unit'
require_relative '../timer'

class TimerTest < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_message
    assert_equal('testing', Timer::time(5, 'testing'))
    assert_equal('', Timer::time(7, ''))
  end

  def test_time_limits
    assert_raise(Timer::TimeTooLongError) { Timer::time((2**(0.size * 8 -2) -1) + 1, 'testing') }
    assert_raise(Timer::TimeCannotBeNegativeEror) { Timer::time(-1, 'testing') }
  end

  def test_message_limits
    assert_raise(Timer::MessageTooLongError) { Timer::time(8, 'a' * 256) }
    assert_nothing_raised { Timer::time(10, '') }
  end

  def test_new_process
    ruby = `ps | grep ruby | wc-l`.to_i
    Timer::start(100000000, "started")
    assert_equal(ruby + 1, `ps | grep ruby | wc-l`)
  end

end
