local function is_utf8term()
  local lang = os.getenv('LANG')
  return lang:lower():match('utf%-8$') and true or false
end

local function getboolenv(varname, default)
  local val = os.getenv(varname)
  if val == 'true' then
    return true
  elseif val == 'false' then
    return false
  end
  return default
end

local lusted = {
  quiet = getboolenv('LUSTED_QUIET', false),
  colored = getboolenv('LUSTED_COLORED', true),
  show_traceback = getboolenv('LUSTED_SHOW_TRACEBACK', true),
  show_error = getboolenv('LUSTED_SHOW_ERROR', true),
  stop_on_fail = getboolenv('LUSTED_STOP_ON_FAIL', false),
  utf8term = getboolenv('LUSTED_UTF8TERM', is_utf8term()),
  filter = os.getenv('LUSTED_FILTER'),
  seconds = os.clock,
}

local lusted_start = nil
local last_succeeded = false
local level = 0
local successes = 0
local total_successes = 0
local failures = 0
local total_failures = 0
local start = 0
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
local colors = setmetatable({}, { __index = function(_, key)
  return lusted.colored and color_table[key] or ''
end})

function lusted.describe(name, fn)
  if level == 0 then
    start = lusted.seconds()
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
  names[level] = nil
  level = level - 1
  if level == 0 and not lusted.quiet and (successes > 0 or failures > 0) then
    local io_write = io.write
    local colors_reset, colors_green = colors.reset, colors.green
    io_write(failures == 0 and colors_green or colors.red, '[====] ',
             colors.magenta, name, colors_reset, ' | ',
             colors_green, successes, colors_reset, ' successes / ')
    if failures > 0 then
      io_write(colors.red, failures, colors_reset, ' failures / ')
    end
    io_write(colors.bright, string.format('%.6f', lusted.seconds() - start), colors_reset, ' seconds\n')
  end
end

local function xpcall_error_handler(err)
  return debug.traceback(tostring(err), 2)
end

local function show_error_line(err)
  local info = debug.getinfo(3)
  local io_write = io.write
  local colors_reset = colors.reset
  local short_src, currentline = info.short_src, info.currentline
  io_write(' (', colors.blue, short_src, colors_reset,
           ':', colors.bright, currentline, colors_reset)
  if err and lusted.show_traceback then
    local fnsrc = short_src..':'..currentline
    for cap1, cap2 in err:gmatch('\t[^\n:]+:(%d+): in function <([^>]+)>\n') do
      if cap2 == fnsrc then
        io_write('/', colors.bright, cap1, colors_reset)
        break
      end
    end
  end
  io_write(')')
end

local function show_test_name(name)
  local io_write = io.write
  local colors_reset = colors.reset
  for _,descname in ipairs(names) do
    io_write(colors.magenta, descname, colors_reset, ' | ')
  end
  io_write(colors.bright, name, colors_reset)
end

function lusted.it(name, fn)
  if lusted.filter then
    local fullname = table.concat(names, ' | ')..' | '..name
    if not fullname:match(lusted.filter) then
      return
    end
  end
  for _,levelbefores in ipairs(befores) do
    for _,beforefn in ipairs(levelbefores) do
      beforefn(name)
    end
  end
  local success, err
  if lusted.show_traceback then
    success, err = xpcall(fn, xpcall_error_handler)
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
  local io_write = io.write
  local colors_reset = colors.reset
  if not lusted.quiet then
    if success then
      io_write(colors.green, '[ OK ] ', colors_reset)
    else
      io_write(colors.red, '[FAIL] ', colors_reset)
    end
    show_test_name(name)
    if not success then
      show_error_line(err)
    end
    io_write('\n')
  else
    if success then
      local o = (lusted.utf8term and lusted.colored) and
                string.char(226, 151, 143) or 'o'
      io_write(colors.green, o, colors_reset)
    else
      io_write(last_succeeded and '\n' or '',
               colors.red, '[FAIL] ', colors_reset)
      show_test_name(name)
      show_error_line(err)
      io_write('\n')
    end
  end
  if err and lusted.show_error then
    if lusted.colored then
      local errfile, errline, errmsg, rest = err:match('^([^:\n]+):(%d+): ([^\n]+)\n(.*)')
      if errfile and errline and errmsg and rest then
        io_write(colors.blue, errfile, colors_reset,
                 ':', colors.bright, errline, colors_reset, ': ')
        if errmsg:match('^%w+') then
          io_write(colors.red, errmsg, colors_reset, '\n')
        else
          io_write(errmsg, '\n')
        end
        err = rest
      end
    end
    io_write(err, '\n\n')
  end
  io.flush()
  if not success and lusted.stop_on_fail then
    if lusted.quiet then
      io_write('\n')
      io.flush()
    end
    lusted.exit()
  end
  for _,levelafters in ipairs(afters) do
    for _,afterfn in ipairs(levelafters) do
      afterfn(name)
    end
  end
  last_succeeded = success
end

function lusted.before(fn)
  local levelbefores = befores[level]
  if not levelbefores then
    levelbefores = {}
    befores[level] = levelbefores
  end
  levelbefores[#levelbefores+1] = fn
end

function lusted.after(fn)
  local levelafters = afters[level]
  if not levelafters then
    levelafters = {}
    afters[level] = levelafters
  end
  levelafters[#levelafters+1] = fn
end

function lusted.report()
  local now = lusted.seconds()
  local colors_reset = colors.reset
  io.write(lusted.quiet and '\n' or '',
           colors.green, successes, colors_reset, ' successes / ',
           colors.red, failures, colors_reset, ' failures / ',
           colors.bright, string.format('%.6f', now - (lusted_start or now)), colors_reset, ' seconds\n')
  io.flush()
  return total_failures == 0
end

function lusted.exit()
  os.exit(total_failures == 0 and 0 or -1)
end

return lusted
