local lusted = require 'lusted'

local describe, it = lusted.describe, lusted.it

describe("utils", function()
  lusted.before(function()
  end)

  lusted.after(function()
  end)

  it("module1", function()

  end)

  it("module2", function()
    assert(false)
  end)

  it("module3", function()
    error 'an error'
  end)

  it("module4", function()
    assert(true)
  end)
end)

lusted.report()
lusted.exit()
