module DomainsHelper

  def encode_domain_name(name)
    name.gsub('.', '_')
  end

  def decode_domain_name(name)
    name.gsub('_', '.')
  end

  def domain_name_valid?(name)
    name =~ /^([a-z0-9-]+\.)+[a-z]{2,5}/i
  end
end
