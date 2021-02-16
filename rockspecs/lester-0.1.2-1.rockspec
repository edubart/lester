package = "lester"
version = "0.1.2-1"
source = {
  url = "git://github.com/edubart/lester.git",
  tag = "v0.1.2"
}
description = {
  summary = "Minimal test framework for Lua",
  homepage = "https://github.com/edubart/lester",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ['lester'] = 'lester.lua',
  }
}
