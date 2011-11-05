class Snippet < ActiveRecord::Base
  attr_accessor :content

  def to_hash
    {
      :id => id,
      :name => file_name,
      :summary => summary,
      :content => content,
      :created_at => created_at,
      :updated_at => updated_at,
    }
  end

  def self.search_from_repository(repository_root, search_key)
    return [{}, []] unless File.exist? repository_root
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

  def self.search_from_db(search_key, ids)
    snippets = Arel::Table.new(:snippets)
    query = snippets[:id].in(ids)
    query = query.or(snippets[:file_name].matches("%#{search_key}%"))
    query = query.or(snippets[:description].matches("%#{search_key}%"))
    snippets.where(query).project(snippets[:id], snippets[:file_name]).to_a
  end

  def commits
    return [] if id.blank?
    return [] unless repository_exist?
    git = Git.open(Setting[:repository_root])
    return [] unless file_exist?(id)
    git.log.object("#{id}.txt")
  end

  def content(revision = 'HEAD')
    return '' if id.blank?
    return '' unless repository_exist?
    git = Git.open(Setting[:repository_root])
    return '' unless file_exist?(id)
    git.object("#{revision}:#{id}.txt").contents
  end

  def mode
    return nil if file_name.blank?
    mode, mime = ext2lang(File.extname(file_name))
    mode
  end

  def mime
    return nil if file_name.blank?
    mode, mime = ext2lang(File.extname(file_name))
    mime
  end

  def diff(before_commit, after_commit)
    return nil unless repository_exist?
    git = Git.open(Setting[:repository_root])
    return nil unless file_exist?(id)
    git.diff(before_commit, after_commit).path("#{id}.txt")
  end

  def repository_exist?
    File.exist? Setting[:repository_root]
  end

  def file_exist?(id)
    File.exist? "#{Setting[:repository_root]}/#{id}.txt"
  end

  def ext2lang(ext)
    return [nil, nil] if ext.blank?
    ext.gsub!(".", "")
    map = {
      'c'        => ['clike', 'text/x-csrc'],
      'h'        => ['clike', 'text/x-csrc'],
      'java'     => ['clike', 'text/x-java'],
      'cpp'      => ['clike', 'text/x-c++src'],
      'hpp'      => ['clike', 'text/x-c++src'],
      'cs'       => ['clike', 'text/x-java'],
      'clj'      => ['clojure', 'text/x-clojure'],
      'coffee'   => ['coffeescript', 'text/x-coffeescript'],
      'css'      => ['css', 'text/css'],
      'diff'     => ['diff', 'text/x-diff'],
      'patch'    => ['diff', 'text/x-diff'],
      'groovy'   => ['groovy', 'text/x-groovy'],
      'hs'       => ['haskell', 'text/x-haskell'],
      'html'     => ['html', 'text/html'],
      'htm'      => ['html', 'text/html'],
      'js'       => ['javascript', 'text/javascript'],
      'jinja2'   => ['jinja2', nil],
      'lua'      => ['lua', 'text/x-lua'],
      'md'       => ['markdown', 'text/x-markdown'],
      'markdown' => ['markdown', 'text/x-markdown'],
      'nt'       => ['ntriples', 'text/n-triples'],
      'pas'      => ['pascal', 'text/x-pascal'],
      'pp'       => ['pascal', 'text/x-pascal'],
      'p'        => ['pascal', 'text/x-pascal'],
      'pl'       => ['perl', 'text/x-perl'],
      'php'      => ['php', 'application/x-httpd-php'],
      'sql'      => ['plsql', 'text/x-plsql'],
      'py'       => ['python', 'text/x-python'],
      'r'        => ['r', 'text/x-rsrc'],
      'rst'      => ['rst', 'text/x-rst'],
      'rb'       => ['ruby', 'text/x-ruby'],
      'scm'      => ['scheme', 'text/x-scheme'],
      'st'       => ['smalltalk', 'text/x-stsrc'],
      'sparql'   => ['sparql', 'application/x-sparql-query'], # XXX
      'tex'      => ['stex', 'text/stex'],
      'vm'       => ['velocity', 'text/velocity'],
      'xml'      => ['xmlpure', 'application/xml'],
      'yml'      => ['yaml', 'text/x-yaml'],
      'yaml'     => ['yaml', 'text/x-yaml']}
    map[ext.downcase] || [nil, nil]
  end
end
