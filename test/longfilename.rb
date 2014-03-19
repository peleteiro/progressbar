require 'test/unit'
require 'progressbar'

class ProgressBarTest < Test::Unit::TestCase
  SleepUnit = 0.005

  def do_make_progress_bar(title, total, &block)
    ProgressBar.new(title, total, &block)
  end

  def test_fill
    total = 1024 * 1024
    pbar = ProgressBar.new("0 test fill", total)
    pbar.file_transfer_mode
    pbar.bar_fill = '_'
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end

  def test_fill_nil
    total = 1024 * 1024 * 16
    sleep_unit = 0.01
    pbar = ProgressBar.new("1 test fill", total)
    pbar.file_transfer_mode
    pbar.bar_fill = nil
    pbar.bar_mark = '.+oO#'
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(sleep_unit)
    }
    pbar.finish
  end

  def test_fill_mult
    total = 1024 * 1024
    pbar = ProgressBar.new("2 test fill", total)
    pbar.file_transfer_mode
    pbar.bar_fill = '_+'
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end

  def test_long_file_baseA
    total = 1024 * 1024
    pbar = ProgressBar.new("0test very long filename", total)
    pbar.file_transfer_mode
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end

  def test_long_file_baseB
    total = 1024 * 1024
    pbar = ProgressBar.new("Btest very very very very long filename", total)
    pbar.file_transfer_mode
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end

  def test_long_file_adj
    total = 1024 * 1024
    pbar = ProgressBar.new("1 adj veryveryveryverylong filename", total)
    pbar.title_width = 50
    pbar.file_transfer_mode
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end


  def test_long_file_adj2
    total = 1024 * 1024
    pbar = ProgressBar.new("2 adj veryveryveryverylong filename", total)
    pbar.title_width = 30
    pbar.file_transfer_mode
    0.step(total, 2**14) {|x|
      pbar.set(x)
      sleep(SleepUnit)
    }
    pbar.finish
  end

end
