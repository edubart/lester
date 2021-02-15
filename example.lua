local lusted = require 'lusted'
local describe, it, expect = lusted.describe, lusted.it, lusted.expect

-- Customize lusted configuration.
lusted.show_traceback = false

describe('my project', function()
  lusted.before(function()
    -- This gets run before every test.
  end)

  describe('module1', function() -- Can be nested.
    it('feature1', function()
      expect.equal('astring', 'astring') -- Pass.
    end)

    it('feature2', function()
      expect.exist(nil) -- Fail.
    end)
  end)
end)

lusted.report() -- Print overall statistic of the tests run.
lusted.exit() -- Exit with success if all tests passed.
