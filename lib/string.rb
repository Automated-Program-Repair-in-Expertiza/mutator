class String
  #
  # I did not want to install ActiveSupport just for underscore method
  # so I monkey-patch underscore into String manually
  #
  def underscore
    string = self.dup
    string.gsub!(/::/, '/')
    string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    string.tr!("-", "_")
    string.downcase!
    string
  end

  #
  # camelize as the inverse of underscore
  #
  def camelize
    string = self.dup
    string = string.split('_')
    string = string.map(&:capitalize)
    string = string.inject('') {|word, string| word + string}
    string
  end
end