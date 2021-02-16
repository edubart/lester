package = "lester"
version = "dev-1"
source = {
  url = "git://github.com/edubart/lester.git",
  branch = "main"
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
