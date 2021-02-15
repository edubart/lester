local lusted = {}

--TODO: filters
local config = {
  quiet = false,
  colored = true,
  show_error_traceback = true,
  show_error = true,
  stop_on_failure = false,
}
lusted.config = config
local level = 0
local successes = 0
local total_successes = 0
local failures = 0
local total_failures = 0
local start = 0
local lusted_start
local befores = {}
local afters = {}
local names = {}
local color_table = {
  reset = string.char(27) .. '[0m',
  bright = string.char(27) .. '[1m',
  red = string.char(27) .. '[31m',
  green = string.char(27) .. '[32m',
  blue = string.char(27) .. '[34m',
  magenta = string.char(27) .. '[35m',
}
local colors = setmetatable({}, {
  __index = function(_, key)
    if config.colored then
      return color_table[key]
    else
      return ''
    end
  end
})

local function elapsed(last)
  return string.format('%.6f', os.clock() - last)
end

function lusted.describe(name, fn)
  if level == 0 then
    start = os.clock()
    if not lusted_start then
      lusted_start = start
    end
  end
  failures = 0
  successes = 0
  level = level + 1
  names[level] = name
  fn()
  afters[level] = nil
  befores[level] = nil
  level = level - 1
  if level == 0 and not config.quiet then
    if failures == 0 then
      io.write(colors.green, '[====]')
    else
      io.write(colors.red, '[====]')
    end
    io.write(' ', colors.magenta, name, colors.reset,' | ',
             colors.green, successes, colors.reset, ' successes / ')
    if failures > 0 then
      io.write(colors.red, failures, colors.reset, ' failures / ')
    end
    io.write(colors.bright, elapsed(start), colors.reset, ' seconds\n')
  end
end

local function error_handler(err)
  return debug.traceback(tostring(err), 2)
end

local function show_error_line(err)
  local info = debug.getinfo(3)
  io.write(' (', colors.blue, info.short_src, colors.reset,
           ':', colors.bright, info.currentline, colors.reset)
  local fnsrc = info.short_src..':'..info.currentline
  if err and config.show_error_traceback then
    local line2
    for cap1, cap2 in err:gmatch('\t[^\n:]+:(%d+): in function <([^>]+)>\n') do
      if cap2 == fnsrc then
        line2 = tonumber(cap1)
        break
      end
    end
    if line2 then
      io.write('/', colors.bright, line2, colors.reset)
    end
  end
  io.write(')')
end

local last_succeeded
function lusted.it(name, fn)
  for _,levelbefores in ipairs(befores) do
    for _,beforefn in ipairs(levelbefores) do
      beforefn(name)
    end
  end
  local success, err
  if config.show_error_traceback then
    success, err = xpcall(fn, error_handler)
  else
    success, err = pcall(fn)
  end
  if success then
    successes = successes + 1
    total_successes = total_successes + 1
  else
    failures = failures + 1
    total_failures = total_failures + 1
  end
  if not config.quiet then
    if success then
      io.write(colors.green, '[ OK ]', colors.reset)
    else
      io.write(colors.red, '[FAIL]', colors.reset)
    end
    for _,descname in ipairs(names) do
      io.write(' ', colors.magenta, descname, colors.reset, ' | ')
    end
    io.write(colors.bright, name, colors.reset)
    if not success then
      show_error_line(err)
    end
    io.write('\n')
  else
    if success then
      io.write(colors.green, 'O', colors.reset)
    else
      if last_succeeded then
        io.write('\n')
      end
      io.write(colors.red, 'FAIL', colors.reset)
      if not success then
        show_error_line(err)
        io.write('\n')
      end
    end
  end
  if err and config.show_error then
    io.write(err, '\n\n')
  end
  io.flush()
  if not success and config.stop_on_failure then
    if config.quiet then
      io.write('\n')
    end
    os.exit(-1)
  end
  for _,levelafters in ipairs(afters) do
    for _,afterfn in ipairs(levelafters) do
      afterfn(name)
    end
  end
  last_succeeded = success
end

function lusted.before(fn)
  befores[level] = befores[level] or {}
  table.insert(befores[level], fn)
end

function lusted.after(fn)
  afters[level] = afters[level] or {}
  table.insert(afters[level], fn)
end

function lusted.report()
  if config.quiet then
    io.write('\n')
  end
  io.write(colors.green, successes, colors.reset, ' successes / ',
           colors.red, failures, colors.reset, ' failures / ',
           colors.bright, elapsed(lusted_start), colors.reset, ' seconds\n')
  io.flush()
  return total_failures == 0
end

function lusted.exit()
  os.exit(total_failures == 0 and 0 or -1)
end

return lusted
