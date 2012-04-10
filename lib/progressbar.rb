#
# Ruby/ProgressBar - a text progress bar library
#
# Copyright (C) 2001-2005 Satoru Takabayashi <satoru@namazu.org>
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms
# of Ruby's license.
#

class ProgressBar
  VERSION = "0.11.0"

  def initialize (title, total, out = STDERR)
    @title = title
    @total = total
    @out = out
    @terminal_width = 80
    @bar_mark = "o"
    @current = 0
    @previous = 0
    @finished_p = false
    @start_time = Time.now
    @previous_time = @start_time
    @title_width = 14
    @format = "%-#{@title_width}s %3d%% %s %s"
    @format_arguments = [:title, :percentage, :bar, :stat]
    clear
    show
  end

  attr_reader   :title
  attr_reader   :current
  attr_reader   :total
  attr_accessor :start_time
  attr_writer   :bar_mark

private

  def fmt_bar
    bar_width = do_percentage * @terminal_width / 100
    sprintf("|%s%s|",
            @bar_mark * bar_width,
            " " *  (@terminal_width - bar_width))
  end

  def fmt_percentage
    do_percentage
  end

  def fmt_stat
    if @finished_p then elapsed else eta end
  end

  def fmt_stat_for_long_run
    if @finished_p then elapsed else eta_running_average end
  end

  def fmt_stat_for_file_transfer
    if @finished_p then
      sprintf("%s %s %s", bytes, transfer_rate, elapsed)
    else
      sprintf("%s %s %s", bytes, transfer_rate, eta)
    end
  end

  def fmt_title
    @title[0,(@title_width - 1)] + ":"
  end

  def convert_bytes (bytes)
    if bytes < 1024
      sprintf("%6dB", bytes)
    elsif bytes < 1024 * 1000 # 1000kb
      sprintf("%5.1fKB", bytes.to_f / 1024)
    elsif bytes < 1024 * 1024 * 1000  # 1000mb
      sprintf("%5.1fMB", bytes.to_f / 1024 / 1024)
    else
      sprintf("%5.1fGB", bytes.to_f / 1024 / 1024 / 1024)
    end
  end

  def transfer_rate
    bytes_per_second = @current.to_f / (Time.now - @start_time)
    sprintf("%s/s", convert_bytes(bytes_per_second))
  end

  def bytes
    convert_bytes(@current)
  end

  def format_time (t)
    t = t.to_i
    sec = t % 60
    min  = (t / 60) % 60
    hour = t / 3600
    sprintf("% 3d:%02d:%02d", hour, min, sec);
  end

  # ETA stands for Estimated Time of Arrival.
  def eta
    if @current == 0
      "ETA:  --:--:--"
    else
      elapsed = Time.now - @start_time
      eta = elapsed * @total / @current - elapsed;
      sprintf("ETA: %s", format_time(eta))
    end
  end

  # Compute ETA with running average (better suited to long running tasks)
  def eta_running_average
    now = Time.now

    # update throughput running average
    if @total > 0 && @eta_previous && @eta_previous_time
      current_elapsed = @current - @eta_previous
      alpha = 0.9 ** current_elapsed
      current_progress = 1.0 * current_elapsed
      current_throughput = current_progress / (now - @eta_previous_time)
      if @eta_throughput
        @eta_throughput = @eta_throughput * alpha + current_throughput * (1-alpha)
      else
        @eta_throughput = current_throughput
      end
    end

    @eta_previous = @current
    @eta_previous_time = now

    if @eta_throughput && @eta_throughput > 0
      eta = (@total - @current) / @eta_throughput;
      sprintf("ETA: %s", format_time(eta))
    else
      "ETA:  --:--:--"
    end
  end

  def elapsed
    elapsed = Time.now - @start_time
    sprintf("Time: %s", format_time(elapsed))
  end

  def eol
    if @finished_p then "\n" else "\r" end
  end

  def do_percentage
    if @total.zero?
      100
    else
      @current  * 100 / @total
    end
  end

  DEFAULT_WIDTH = 80
  def get_term_width
    if ENV['COLUMNS'] =~ /^\d+$/
      ENV['COLUMNS'].to_i
    elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && shell_command_exists?('tput')
      `tput cols`.to_i
    elsif STDIN.tty? && shell_command_exists?('stty')
      `stty size`.scan(/\d+/).map { |s| s.to_i }[1]
    else
      DEFAULT_WIDTH
    end
  rescue
    DEFAULT_WIDTH
  end

  def shell_command_exists?(command)
    ENV['PATH'].split(File::PATH_SEPARATOR).any?{|d| File.exists? File.join(d, command) }
  end

  def show
    arguments = @format_arguments.map {|method|
      method = sprintf("fmt_%s", method)
      send(method)
    }
    line = sprintf(@format, *arguments)

    width = get_term_width
    if line.length == width - 1
      @out.print(line + eol)
      @out.flush
    elsif line.length >= width
      @terminal_width = [@terminal_width - (line.length - width + 1), 0].max
      if @terminal_width == 0 then @out.print(line + eol) else show end
    else # line.length < width - 1
      @terminal_width += width - line.length + 1
      show
    end
    @previous_time = Time.now
  end

  def show_if_needed
    if @total.zero?
      cur_percentage = 100
      prev_percentage = 0
    else
      cur_percentage  = (@current  * 100 / @total).to_i
      prev_percentage = (@previous * 100 / @total).to_i
    end

    # Use "!=" instead of ">" to support negative changes
    if cur_percentage != prev_percentage ||
        Time.now - @previous_time >= 1 || @finished_p
      show
    end
  end

public

  def clear
    @out.print "\r"
    @out.print(" " * (get_term_width - 1))
    @out.print "\r"
  end

  def finish
    @current = @total
    @finished_p = true
    show
  end

  def finished?
    @finished_p
  end

  def file_transfer_mode
    @format_arguments = [:title, :percentage, :bar, :stat_for_file_transfer]
  end

  def long_running
    @format_arguments = [:title, :percentage, :bar, :stat_for_long_run]
  end

  def format= (format)
    @format = format
  end

  def format_arguments= (arguments)
    @format_arguments = arguments
  end

  def halt
    @finished_p = true
    show
  end

  def inc (step = 1)
    @current += step
    @current = @total if @current > @total
    show_if_needed
    @previous = @current
  end

  def set (count)
    if count < 0 || count > @total
      raise "invalid count: #{count} (total: #{@total})"
    end
    @current = count
    show_if_needed
    @previous = @current
  end

  def inspect
    "#<ProgressBar:#{@current}/#{@total}>"
  end

end

class ReversedProgressBar < ProgressBar
  def do_percentage
    100 - super
  end
end
