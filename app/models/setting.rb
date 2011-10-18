class Setting
  SETTING_PATH = File.dirname(__FILE__) + "/../../config/setting.yml"
  @@available_settings = YAML.load(File.open(SETTING_PATH))
  def self.[](key)
    @@available_settings[key.to_s]
  end
end
