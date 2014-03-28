# This file is separate so that users don't get an error in ruby < 1.9, and can
# choose whether to extend Enumerator with a new method.
class Enumerator
  def progressbar(label = "Progress")
    enum = ProgressBar.iterator(self, label)
    if block_given?
      enum.each { |*args| yield(*args) }
    else
      enum
    end
  end
end
