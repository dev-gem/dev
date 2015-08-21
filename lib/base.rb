puts __FILE__ if defined?(DEBUG)

['array','command','environment','file','gemspec',
 'hash','internet','project','projects','source',
 'string','text','timeout','timer','version'].each{|name| require_relative("base/#{name}.rb")}