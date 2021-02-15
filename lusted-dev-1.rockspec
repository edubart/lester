package = "lusted"
version = "dev-1"
source = {
  url = "git://github.com/edubart/lusted.git",
  branch = "master"
}
description = {
  summary = "Minimal test framework for Lua",
  homepage = "https://github.com/edubart/lusted",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ['lusted'] = 'lusted.lua',
  }
}
