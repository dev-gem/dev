puts __FILE__ if defined?(DEBUG)

['array','command','dir','environment','file','gemspec',
 'hash','history','internet','project','projects','source',
 'string','text','timeout','timer','version'].each{|name| require_relative("base/#{name}.rb")}