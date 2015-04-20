Rails.configuration.after_initialize do
  JASPER_CONFIG = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'jasperserver.yml'))).result).deep_symbolize_keys[Rails.env.to_sym]
end