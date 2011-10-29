# Helper methods defined here can be accessed in any controller or view in the application

#Debeso.helpers do
module CodesHelper

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
    tag << "<div>"
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

  def search_from_repository(repository_root, search_key)
    git = Git.open(repository_root)
    results = git.grep(search_key, nil, :ignore_case => true)
    search_result = {}
    ids = results.map do |key, value|
      id = key.split(":")[1]
      id = id.sub(File.extname(id), "")
      value.each do |result|
        search_result[id] ||= {}
        search_result[id][result[0]] = result[1]
      end
      id
    end
    [search_result, ids]
  end

  def search_from_db(search_key, ids)
    snippets = Arel::Table.new(:snippets)
    query = snippets[:sha1_hash].in(ids)
    query = query.or(snippets[:file_name].matches("%#{search_key}%"))
    query = query.or(snippets[:description].matches("%#{search_key}%"))
    snippets.where(query).project(snippets[:sha1_hash], snippets[:file_name]).to_a
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

end
