M = {}


local function _set_timeout(callback, timeout)
  local timer = vim.loop.new_timer()

  if not timer then
    return
  end

  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end


local function _debounce(callback, timeout)
  local paused = false;

  return function()
    if paused then
      return
    end

    local return_val = callback()

    paused = true

    _set_timeout(function()
      paused = false
    end, timeout)

    return return_val
  end
end

local function _split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end

  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end

  return t
end

local function _split_on_first_space(str)
  local splitTable = {}
  local firstItem, restItems = str:match("^(%S+)%s(.+)$")
  splitTable[1] = firstItem
  splitTable[2] = restItems
  return splitTable
end



local function _get_blame_for_current_line()
  local window = vim.api.nvim_get_current_win();
  local line = vim.api.nvim_win_get_cursor(window);
  local row = line[1];
  local file = vim.api.nvim_buf_get_name(0);
  local cmd = "git blame " .. file .. " -L " .. row .. "," .. row .. " -p";
  local output = vim.fn.system(cmd);
  local newline_split = _split(output, "\n");
  local results = {}

  for _, value in ipairs(newline_split) do
    local space_split = _split_on_first_space(value);
    local i_need = { "author", "author-time", "summary" }

    for _, needed in ipairs(i_need) do
      if space_split[1] == needed then
        results[space_split[1]] = space_split[2];
      end
    end
  end


  return results;
end


local function _get_current_line()
  local window = vim.api.nvim_get_current_win();
  local pos = vim.api.nvim_win_get_cursor(window);
  local line = pos[1];

  return line
end

function M.blame(ns_id)
  local blame = _get_blame_for_current_line();

  local blame_string = "";

  blame_string = blame_string ..
      "    " .. blame["author"] .. "  " ..
      os.date("%d %B %Y", tonumber(blame["author-time"])) .. "  " .. blame["summary"];

  local opts = {
    virt_text = { { blame_string, "Comment" } },
    virt_text_pos = 'eol',
  }

  local line = _get_current_line();

  local mark_id = vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, opts);

  return mark_id;
end

function M.setup()
  vim.api.nvim_create_user_command("BlameLine", function()
    local is_git_initialized = vim.fn.system("git rev-parse --is-inside-work-tree");

    if not is_git_initialized == "true" then
      print("directory is not a git repository")
      return nil
    end

    local has_any_commits = vim.fn.system("git log --oneline -n 1");

    if string.find(has_any_commits, "does not have any commits yet") then
      print("repository does not have any commits yet")
      return nil
    end



    local all_namespaces = vim.api.nvim_get_namespaces();

    local ns_id = nil;

    for key, value in pairs(all_namespaces) do
      if key == "blame" then
        ns_id = value
      else
        ns_id = vim.api.nvim_create_namespace("blame")
      end
    end

    local mark_id = M.blame(ns_id);

    local group = vim.api.nvim_create_augroup("BlameLine", {
      clear = true
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = function()
        if mark_id then
          vim.api.nvim_buf_del_extmark(0, ns_id, mark_id)
        end
        -- mark_id = M.blame(ns_id)

        -- _debounce(function()
        --   mark_id = M.blame(ns_id)
        -- end, 1000)()
      end,
      group = group,
      buffer = 0
    })
  end, {})
end

return M
