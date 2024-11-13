local function fail(s, ...) ya.notify { title = "bunny.yazi", content = string.format(s, ...), timeout = 5, level = "error" } end
local function info(s, ...) ya.notify { title = "bunny.yazi", content = string.format(s, ...), timeout = 3, level = "info" } end

local get_state_attr = ya.sync(function(state, attr)
  return state[attr]
end)

local sort_bookmarks = function(bookmarks, key1, key2)
  table.sort(bookmarks, function(x, y)
    if x[key1] == nil and y[key1] == nil then
      return x[key2] < y[key2]
    elseif x[key1] == nil then
      return false
    elseif y[key1] == nil then
      return true
    else
      return x[key1] < y[key1]
    end
  end)
end

-- https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/fzf.lua
-- https://github.com/sxyazi/yazi/blob/main/yazi-plugin/src/process/child.rs
local select_fuzzy = function(bookmarks, cli)
  local _permit = ya.hide()
  local child, err =
		Command(cli):stdin(Command.PIPED):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
  if not child then
		return fail("Spawn `%s` failed with error code %s. Do you have it installed?", cli, err)
	end
  -- Build fzf input string
  local input_lines = {};
  for _, item in pairs(bookmarks) do
    local line_elems = { item.tag, item.path, item.key }
    table.insert(input_lines, table.concat(line_elems, "\t"))
  end
  child:write_all(table.concat(input_lines, "\n"))
  child:flush()
	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `%s` output, error code %s", cli, err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`%s` exited with error code %s", cli, output.status.code)
	end
  -- Remove trailing newline
	local target = output.stdout:gsub("\n$", "")
	if not target or target == "" then
    return nil
	end
  local tag, path = string.match(target, "(.-)\t(.-)\t.*")
  return { tag = tag, path = path }
end

local select_key = function(bookmarks)
  local cands = {}
  for _, item in pairs(bookmarks) do
    if #item.tag ~= 0 then
      table.insert(cands, { desc = item.tag, on = item.key, path = item.path })
    end
  end
  if #cands == 0 then
    info("Empty bookmarks table")
    return nil
  end
  local idx = ya.which { cands = cands }
  if idx == nil then
    return nil
  end
  local selection = cands[idx]
  return { tag = selection.desc, path = selection.path }
end

local hop = function(selected_bookmark, notify)
  if not selected_bookmark or selected_bookmark.path == nil then
    fail("Hop failed")
    return
  end
  ya.manager_emit("cd", { selected_bookmark.path })
  if notify then
    info('Hopped to "' .. (selected_bookmark.tag or selected_bookmark.path) .. '"')
  end
end

return {
  setup = function(state, options)
    state.cli = options.cli or "fzf"
    state.notify = options.notify and true
    local bookmarks = options.bookmarks or {}
    sort_bookmarks(bookmarks, "key", "tag")
    state.bookmarks = bookmarks
  end,
  entry = function(_self, args)
    local cli, bookmarks, notify = get_state_attr("cli"), get_state_attr("bookmarks"), get_state_attr("notify")
    local action = args[1] or "select_key"
    if action == "select_key" then
      hop(select_key(bookmarks), notify)
    elseif action == "select_fuzzy" then
      hop(select_fuzzy(bookmarks, cli), notify)
    end
  end,
}


