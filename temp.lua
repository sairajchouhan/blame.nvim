local function split_on_first_space(str)
  local splitTable = {}
  local firstItem, restItems = str:match("^(%S+)%s(.+)$")
  splitTable[1] = firstItem
  splitTable[2] = restItems
  return splitTable
end


P(split_on_first_space("summary Added: Datadog support in Error boundary"))
