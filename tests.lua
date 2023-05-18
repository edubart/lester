local lester = require 'lester'

local describe, it, expect = lester.describe, lester.it, lester.expect
local skipfail = os.getenv('LESTER_TEST_SKIP_FAIL') == 'true'

lester.parse_args()

describe("lester", function()
  local b = false
  lester.before(function()
    b = true
  end)

  lester.after(function()
    b = false
  end)

  assert(not b)
  it("before and after", function()
    assert(b)
  end)
  assert(not b)

  it("assert", function()
    assert(true)
  end, true)

  it("skip", function() assert(false) end, false)

  it("expect", function()
    expect.fail(function() error() end)
    expect.fail(function() error'an error' end, 'an error')
    expect.fail(function() error'got my error' end, 'my error')
    expect.not_fail(function() end)
    expect.truthy(true)
    expect.falsy(false)
    expect.exist(1)
    expect.exist(false)
    expect.exist(true)
    expect.exist('')
    expect.not_exist(nil)
    expect.equal(1, 1)
    expect.equal(false, false)
    expect.equal(nil, nil)
    expect.equal(true, true)
    expect.equal('', '')
    expect.equal('asd', 'asd')
    expect.equal('\x01\x02', '\x01\x02')
    expect.equal({a=1}, {a=1})
    expect.equal({a=1}, {a=1})
    expect.not_equal('asd', 'asf')
    expect.not_equal('\x01\x02', '\x01\x03')
    expect.not_equal(1,2)
    expect.not_equal(true,false)
    expect.not_equal(nil,false)
    expect.not_equal({a=2},{a=1})
  end)

  describe("fails", function()
    if not skipfail then
      it("empty error", function()
        error()
      end)
      it("string error", function()
        error 'an error'
      end)
      it("string error with lines", function()
        error '@somewhere:1: an error'
      end)
      it("table error", function()
        error {}
      end)

      it("empty assert", function()
        assert()
      end)
      it("assert false", function()
        assert(false)
      end)
      it("assert false with message", function()
        assert(false, 'my message')
      end)

      it("fail", function()
        expect.fail(function() end)
      end)
      it("fail message", function()
        expect.fail(function() error('error1') end, 'error2')
      end)
      it("not fail", function()
        expect.not_fail(function() error() end)
      end)

      it("exist", function()
        expect.exist(nil)
      end)
      it("not exist", function()
        expect.not_exist(true)
      end)

      it("truthy", function()
        expect.truthy()
      end)
      it("falsy", function()
        expect.falsy(1)
      end)

      it("equal", function()
        expect.equal(1, 2)
      end)
      it("not equal", function()
        expect.not_equal(1, 1)
      end)

      it("equal (table)", function()
        expect.equal({a=1}, {a=2})
      end)

      it("not equal (table)", function()
        expect.not_equal({a=1}, {a=1})
      end)

      it("equal (binary)", function()
        expect.equal('\x01\x02', '\x01\x03')
      end)

      it("not equal (binary)", function()
        expect.not_equal('\x01\x02', '\x01\x02')
      end)
    end
  end)
end)

lester.report()
if skipfail then
  lester.exit()
end
