class Setting
  SETTING_PATH = File.dirname(__FILE__) + '/../../config/setting.yml'
  @@available_settings = File.exist?(SETTING_PATH) ?
                         YAML.load(File.open(SETTING_PATH)) :
                         { 'repository_root' => File.dirname(__FILE__) + "/../../tmp/debeso"}
  def self.[](key)
    @@available_settings[key.to_s]
  end
end
