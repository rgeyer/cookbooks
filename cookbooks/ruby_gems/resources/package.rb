actions :install, :remove

attribute :name, :kind_of => [ String ], :name_attribute => true, :required => true
attribute :version, :kind_of => [ String ]
attribute :source, :kind_of => [ String ]