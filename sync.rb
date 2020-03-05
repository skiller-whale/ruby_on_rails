require "digest/md5"
require "net/https"
require "uri"
require "json"


class FileUploader
  def initialize(attendance_id)
    @attendance_id = attendance_id.strip
  end

  def send_update(path)
    print "Uploading: #{path}\t"

    if attendance_id.empty?
      puts "No attendance id set; file update not sent."
      return
    end

    uri = updates_uri
    data = file_json(path)

    req = Net::HTTP::Post.new(uri.path, headers(data))
    req.body = data

    sender = Net::HTTP.new(uri.host, uri.port)
    sender.use_ssl = (uri.scheme == "https")
    response = sender.request(req)

    puts response.code
    txt = response.body
    puts txt if txt
  end

  private

  attr_reader :attendance_id

  def headers(data)
    headers = {
      "Content-Type" => "application/json",
      "Content-Length" => data.size.to_s,
    }
  end

  def file_json(path)
    {
      relative_path: path,
      contents: File.read(path)
    }.to_json
  end

  def updates_uri
    URI([hostname, "attendances", attendance_id, "file_snapshots"].join("/"))
  end

  def hostname
    ENV["SW_SERVER_URL"] || "https://train.skillerwhale.com"
  end
end


class FileWatcher
  WATCHED_EXTS = [".rb", ".erb"]
  IGNORE_DIRS = [".git"]

  def initialize(updater:, directory: ".")
    @updater = updater
    @directory = directory
    @file_hashes = Hash.new
    # Tracks whether this is the first pass of the directory tree. If not,
    # then any new file encountered will be treated as an update.
    @first_pass = true
  end

  def poll_for_changes(wait_time: 1)
    while true
      check_dir_for_changes(directory)
      @first_pass = false
      sleep wait_time
    end
  end

  private

  attr_reader :updater
  attr_reader :directory
  attr_reader :file_hashes

  def check_dir_for_changes(dir_path)
    return if IGNORE_DIRS.include? File::basename(dir_path)

    Dir.entries(dir_path).each do |filename|
      # This includes '.' and '..' so we need to remove these
      next if filename == '.' or filename == '..'

      path = File.join(dir_path, filename)

      # Symbolic links count as files
      File::file?(path) ? post_file_if_changed(path) : check_dir_for_changes(path)
    end
  end

  def post_file_if_changed(path)
    return unless WATCHED_EXTS.include? File::extname(path)

    hashed = hash_file(path)
    updater.send_update(path) unless @first_pass || (hashed == file_hashes[path])

    file_hashes[path] = hashed
  end

  def hash_file(path)
    Digest::MD5.hexdigest(File.read(path))
  end
end


def swsync
  puts "  _____ _    _ _ _            __          ___           _      "
  puts " / ____| |  (_) | |           \\ \\        / / |         | |     "
  puts "| (___ | | ___| | | ___ _ __   \\ \\  /\\  / /| |__   __ _| | ___ "
  puts " \\___ \\| |/ / | | |/ _ \\ '__|   \\ \\/  \\/ / | '_ \\ / _` | |/ _ \\"
  puts " ____) |   <| | | |  __/ |       \\  /\\  /  | | | | (_| | |  __/"
  puts "|_____/|_|\\_\\_|_|_|\\___|_|        \\/  \\/   |_| |_|\\__,_|_|\\___| "
  puts ""
  puts "Please copy and paste your ID from the course page here and press enter.\n"
  attendance_id = gets
  puts ""
  puts "Great! We're going to start watching this directory for changes so that the trainer can see your progress."
  puts "Hit Ctrl+C to stop."

  uploader = FileUploader.new(attendance_id)
  watcher = FileWatcher.new(updater: uploader)
  watcher.poll_for_changes
end

swsync
