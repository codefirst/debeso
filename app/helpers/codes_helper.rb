# Helper methods defined here can be accessed in any controller or view in the application

#Debeso.helpers do
module CodesHelper

  def t(str)
    I18n.t str
  end

  def get_lines(content, num)
    lines = content.rstrip.split(/\r?\n/)
    if lines.size < num
      lines.join("\n")
    else
      lines[0..(num - 1)].join("\n")
    end
  end

  def message_tags
    tags = ''
    [:info, :error, :warning].each do |level|
      if flash[level].class == String
        tags << message_tag(level, flash[level])
      elsif flash[level].class == Array
        flash[level].each do |message|
          tags << message_tag(level, message)
        end
      end
    end
    tags
  end

  def message_tag(level, message)
    tag = ''
    tag << "<div class='alert-message #{level.to_s}'>"
    tag << "<span class='label #{level.to_s}'>#{level}</span>"
    tag << "<span class='message'>#{message}</span>"
    tag << "</div>"
    tag
  end

  def save_to_repository(id, file_name, content)
    dir = Setting[:repository_root]
    fullpath = dir + "/#{id}.txt"
    git = Git.open(dir)
    git.add(fullpath) if git.ls_files(fullpath).blank?
    old_content = ""
    open(fullpath) {|f| old_content = f.read} if File.exists?(fullpath)
    unless old_content == content
      open(fullpath, "w") {|f| f.write(content)}
      git.commit_all("update #{file_name}")
    end
  end

  def save_snippet(id, file_name, description, content)
    snippet = Snippet.find_by_hash(id)
    snippet.file_name = file_name
    snippet.description = description
    snippet.summary = get_lines(content, 3)
    snippet.updated_at = Time.now
    snippet.save
    snippet
  end

  def create_snippet
    git = Git.init(@repository_root)
    id = Digest::SHA1.hexdigest(Time.now.to_s)
    # add "id_" to avoid implicit binary translation
    id = "id_" + id
    filename = "#{id}.txt"
    fullpath = "#{@repository_root}/#{filename}"
    open(fullpath, "w") {}
    snippet = Snippet.new(:sha1_hash => id, :created_at => Time.now, :updated_at => Time.now)
    snippet.save
    id
  end

  def get_snippet(id)
    snippet = nil
    unless id.blank?
      snippet = Snippet.find_by_hash(id)
    end
    snippet ||= Snippet.new
    snippet
  end

  def save_action(id, file_name, description, content)
    save_to_repository(id, file_name, content)
    save_snippet(id, file_name, description, content)
  end

  def url_for_with_host(controller, action, option = {})
    root = request.scheme + '://' + request.host
    root += ":#{request.port}" unless request.port == 80
    root + url_for(controller, action, option)
  end

end
