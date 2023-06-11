M = {}


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


    local blame = _get_blame_for_current_line();

    local blame_string = "";

    blame_string = blame_string ..
        blame["author"] .. "  " .. os.date("%d %B %Y", tonumber(blame["author-time"])) .. "  " .. blame["summary"];


    local all_namespaces = vim.api.nvim_get_namespaces();

    local ns_id = nil;

    for key, value in pairs(all_namespaces) do
      if key == "blame" then
        ns_id = value
      else
        ns_id = vim.api.nvim_create_namespace("blame")
      end
    end

    local opts = {
      virt_text = { { blame_string, "Comment" } },
      virt_text_pos = 'eol',
    }

    local window = vim.api.nvim_get_current_win();
    local pos = vim.api.nvim_win_get_cursor(window);
    local line = pos[1];


    local mark_id = vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, opts)
  end, {})
end

return M
