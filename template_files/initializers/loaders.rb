# First load all simple serializers
Dir["#{Rails.root}/lib/serializers/{**, **/**}/simple_*.rb"].each {|file|
  require File.expand_path(file)
}

# Complete serializer depends on simple serializers
Dir["#{Rails.root}/lib/serializers/{**, **/**}/*.rb"].each {|file|
  require File.expand_path(file)
}
