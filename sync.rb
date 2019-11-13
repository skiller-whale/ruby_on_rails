require "digest/md5"
require "net/https"
require "uri"
require "json"


class FileUploader
  def initialize(attendance_id)
    @attendance_id = attendance_id.strip
  end

  def send_update(path)
    uri = updates_uri
    data = file_json(path)

    headers = {
      "Content-Type" => "application/json",
      "Content-Length" => data.size.to_s,
    }

    req = Net::HTTP::Post.new(uri.path, headers)
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
  WATCHED_EXTS = [".rb"]
  IGNORE_DIRS = [".git"]

  def initialize(updater: nil)
    @updater = updater
    @file_hashes = Hash.new
  end

  def poll_directory_for_changes(dir_path)
    return if IGNORE_DIRS.include? File::basename(dir_path)

    Dir.entries(dir_path).each do |filename|
      # This includes '.' and '..' so we need to remove these
      next if filename == '.' or filename == '..'

      path = File.join(dir_path, filename)

      if File::file? path
        if WATCHED_EXTS.include? File::extname(path)
          update_file_hash(path)
        end
      else
        poll_directory_for_changes(path)
      end
    end
  end

  private

  attr_reader :updater
  attr_reader :file_hashes

  def update_file_hash(path)
    hashed = hash_file(path)
    if (file_hashes.key? path) && (hashed != file_hashes[path])
      puts "File changed, sending update: #{path}"
      updater.send_update(path)
    end

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

  while true
    watcher.poll_directory_for_changes(".")
    sleep 1
  end
end

swsync
