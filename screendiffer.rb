module ScreenDiffer
  def self.grab urls, options={}
    ScreenGrabber.new(urls, options).grab
  end

  def self.compare path, options={}
    ScreenComparer.new(path, options).compare
  end

end

class ScreenGrabber

  attr_accessor :urls, :resolutions, :name, :path

  def initialize urls, options={}
    @urls = urls
    @resolutions = options[:resolutions] || "1920x3000,1024x3000"
    @name = options[:name] || "screengrab"
    @path = options[:path] || "./run01/"
  end

  def grab
    append_iteration_to_path

    `casperjs screengrabber.coffee --urls="#{urls.join(',')}" --resolutions="#{resolutions}" --path="#{path}" --name="#{name}"`
  end

  private

  def append_iteration_to_path
    if Dir.exists?("#{path}before/")
      path << "after/"
    else
      path << "before/"
    end
  end
end

class ScreenComparer

  attr_accessor :path

  def initialize path, options={}
    @path = path
  end

  def compare
    puts "-----"
    filenames_in_before.each do |filename|
      puts "#{filename}"
      if filenames_in_after.include?(filename)
        puts "matching after image found, diffing."

        `compare "#{path}before/#{filename}" "#{path}after/#{filename}" -compose src "#{path}diff_#{filename}"`
        sleep 2
        `compare "#{path}before/#{filename}" "#{path}after/#{filename}" "#{path}compare_#{filename}"`
      else
        puts "could not find after image"
        next
      end
      puts "-----"
    end
  end

  private

  def filenames_in_before
    @filenames_in_before ||= Dir.glob("#{path}before/*.png").map { |file| File.basename(file) }
  end

  def filenames_in_after
    @filenames_in_after ||= Dir.glob("#{path}after/*.png").map { |file| File.basename(file) }
  end
end
