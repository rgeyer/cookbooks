default[:rs_sandbox][:home] = "/opt/rightscale/sandbox/"
default[:rs_sandbox][:gem_bin] = "/opt/rightscale/sandbox/bin/gem"
# TODO: Haven't found a use for this in Linux yet, nor have I found an elegant way to find it. Check the
# default recipe to see how I'm setting this for windows.
default[:rs_sandbox][:rl_user_home_dir] = nil