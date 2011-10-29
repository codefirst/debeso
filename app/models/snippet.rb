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
end
