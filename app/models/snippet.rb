class Snippet < ActiveRecord::Base
  attr_accessor :content

  def to_hash
    {
      :id => sha1_hash,
      :name => file_name,
      :summary => summary,
      :content => content,
      :created_at => created_at,
      :updated_at => updated_at,
    }
  end

  def self.find_by_hash(hash_id)
    snippet = Snippet.where(:sha1_hash => hash_id).first
    git = Git.open(Setting[:repository_root])
    file = "#{Setting[:repository_root]}/#{hash_id}.txt"
    open(file) {|f| content = f.read}
    snippet
  end

  def self.search_from_db(search_key, ids)
    snippets = Arel::Table.new(:snippets)
    query = snippets[:sha1_hash].in(ids)
    query = query.or(snippets[:file_name].matches("%#{search_key}%"))
    query = query.or(snippets[:description].matches("%#{search_key}%"))
    snippets.where(query).project(snippets[:sha1_hash], snippets[:file_name]).to_a
  end


  def commits
    commits = []
    unless sha1_hash.blank?
      git = Git.open(Setting[:repository_root])
      commits = git.log.object("#{sha1_hash}.txt")
    end
    commits
  end

  def content(revision = 'HEAD')
    return '' if sha1_hash.blank?
    git = Git.open(Setting[:repository_root])
    git.object(revision + ":" + sha1_hash + ".txt").contents
  end

  def mode    
    ext2lang(File.extname(file_name)) unless file_name.blank?
  end

  def diff(before_commit, after_commit)
    git = Git.open(Setting[:repository_root])
    git.diff(before_commit, after_commit).path("#{sha1_hash}.txt")
  end

  def ext2lang(ext)
    return nil if ext.blank?
    ext.gsub!(".", "")
    map = {'c' => 'clike',
      'h' => 'clike',
      'java' => 'clike',
      'cpp' => 'clike',
      'hpp' => 'clike',
      'cs' => 'clike',
      'clj' => 'clojure',
      'coffee' => 'coffeescript',
      'css' => 'css',
      'diff' => 'diff',
      'patch' => 'diff',
      'groovy' => 'groovy',
      'hs' => 'haskell',
      'html' => 'html',
      'htm' => 'html',
      'js' => 'javascript',
      'jinja2' => 'jinja2',
      'lua' => 'lua',
      'md' => 'markdown',
      'markdown' => 'markdown',
      'nt' => 'ntriples',
      'pas' => 'pascal',
      'pp' => 'pascal',
      'p' => 'pascal',
      'pl' => 'perl',
      'php' => 'php',
      'sql' => 'plsql',
      'py' => 'python',
      'r' => 'r',
      'rst' => 'rst',
      'rb' => 'ruby',
      'scm' => 'scheme',
      'st' => 'smalltalk',
      'sparql' => 'sparql', # XXX
      'tex' => 'stex',
      'vm' => 'velocity',
      'xml' => 'xmlpure',
      'yml' => 'yaml',
      'yaml' => 'yaml'}
    map[ext.downcase]
  end
end
