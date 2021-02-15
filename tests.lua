local lusted = require 'lusted'

local describe, it = lusted.describe, lusted.it
local skipfail = os.getenv('LUSTED_TEST_SKIP_FAIL') == 'true'

describe("lusted", function()
  local b = false
  lusted.before(function()
    b = true
  end)

  lusted.after(function()
    b = false
  end)

  assert(not b)
  it("module1", function()
    assert(b)
  end)
  assert(not b)

  it("module2", function()
    assert(b)
    assert(skipfail)
  end)
  assert(not b)

  describe("nested", function()
    it("module3", function()
      assert(b)
      if not skipfail then
        error 'an error'
      end
    end)
    assert(not b)

    it("module4", function()
      assert(b)
      assert(true)
    end)
    assert(not b)
  end)
end)

lusted.report()
if skipfail then
  lusted.exit()
end
