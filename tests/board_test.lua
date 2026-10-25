-- Standalone tests for the board model. Run from the plugin root:
--   luajit tests/board_test.lua   (or: lua tests/board_test.lua)

local function stubModule()
    return setmetatable({}, {
        __index = function()
            return function() end
        end,
    })
end

local function stubWidgetClass()
    local class = {}
    function class:extend(fields)
        local subclass = fields or {}
        subclass.__index = subclass
        setmetatable(subclass, { __index = self })
        function subclass:new(obj)
            obj = obj or {}
            setmetatable(obj, self)
            return obj
        end
        return subclass
    end
    return class
end

local stubs = {
    ["device"] = function()
        return {
            screen = { getWidth = function() return 600 end, getHeight = function() return 800 end },
            hasKeys = function() return false end,
        }
    end,
    ["ffi/blitbuffer"] = function()
        return { COLOR_BLACK = 0, COLOR_WHITE = 15, COLOR_GRAY = 8, COLOR_GRAY_D = 13, COLOR_GRAY_E = 14 }
    end,
    ["ffi/util"] = function()
        return {
            template = function(str, ...)
                local args = { ... }
                return (str:gsub("%%(%d+)", function(i)
                    return tostring(args[tonumber(i)])
                end))
            end,
        }
    end,
    ["gettext"] = function()
        return function(s) return s end
    end,
    ["ui/widget/container/inputcontainer"] = stubWidgetClass,
    ["ui/widget/container/widgetcontainer"] = stubWidgetClass,
}
for _, name in ipairs({
    "datastorage", "luasettings", "ui/font", "ui/gesturerange", "ui/geometry", "ui/rendertext",
    "ui/size", "ui/uimanager", "ui/widget/buttontable", "ui/widget/container/framecontainer",
    "ui/widget/container/scrollablecontainer", "ui/widget/infomessage", "ui/widget/textwidget",
    "ui/widget/verticalgroup", "ui/widget/verticalspan",
}) do
    stubs[name] = stubModule
end
for name, loader in pairs(stubs) do
    package.preload[name] = loader
end

local script_dir = (arg and arg[0] or ""):match("^(.*)[/\\]") or "."
local main_path = script_dir .. "/../main.lua"
local file = assert(io.open(main_path, "r"))
local source = file:read("*a")
file:close()

local patched, count = source:gsub(
    "return Nonogram%s*$",
    "return { NonogramBoard = NonogramBoard, buildPuzzleFromBooleanGrid = buildPuzzleFromBooleanGrid }\n"
)
assert(count == 1, "could not find final 'return Nonogram' in main.lua")
local chunk = assert((loadstring or load)(patched, "@main.lua"))
local M = chunk()
local NonogramBoard = M.NonogramBoard
local buildPuzzleFromBooleanGrid = M.buildPuzzleFromBooleanGrid

local function boardFromLines(lines)
    local grid = {}
    for r, line in ipairs(lines) do
        grid[r] = {}
        for c = 1, #line do
            grid[r][c] = line:sub(c, c) == "#"
        end
    end
    local board = NonogramBoard:new()
    board:setCurrentPuzzle(buildPuzzleFromBooleanGrid(grid, "test"))
    return board
end

local function setUserGrid(board, lines)
    for r, line in ipairs(lines) do
        for c = 1, #line do
            local ch = line:sub(c, c)
            board.user_grid[r][c] = (ch == "#" and 1) or (ch == "x" and 0) or -1
        end
    end
end

local tests = {}

tests["anti-diagonal solves the 2x2 diagonal puzzle"] = function()
    local board = boardFromLines({ "#.", ".#" })
    setUserGrid(board, { ".#", "#." })
    assert(board:isRowSatisfied(1) and board:isRowSatisfied(2), "rows should be satisfied")
    assert(board:isColSatisfied(1) and board:isColSatisfied(2), "cols should be satisfied")
    assert(board:isSolved() == true, "alternative solution should count as solved")
end

tests["extra filled cell breaks the row"] = function()
    local board = boardFromLines({ "##..#", "....." })
    setUserGrid(board, { "##..#", "....." })
    assert(board:isRowSatisfied(1), "row should be satisfied before the extra cell")
    setUserGrid(board, { "###.#", "....." })
    assert(not board:isRowSatisfied(1), "extra cell should break the row")
    assert(not board:isSolved(), "board should not be solved")
end

tests["crosses inside a row do not break it"] = function()
    local board = boardFromLines({ "##.#." })
    setUserGrid(board, { "##x#x" })
    assert(board:isRowSatisfied(1), "crosses must count as empty")
end

tests["row with hint 0 is satisfied on an empty board"] = function()
    local board = boardFromLines({ "#.#", "...", "##." })
    assert(board:getRowHints(2)[1] == 0, "expected hint {0}")
    assert(board:isRowSatisfied(2), "empty row with hint 0 should be satisfied")
    assert(not board:isRowSatisfied(1), "non-empty hint row should not be satisfied")
end

tests["board filled from the reference solution is solved"] = function()
    local lines = { "#.##.", ".###.", "#...#", "#####", "....." }
    local board = boardFromLines(lines)
    assert(not board:isSolved(), "empty board should not be solved")
    setUserGrid(board, lines)
    assert(board:isSolved() == true, "reference solution should be solved")
end

local names = {}
for name in pairs(tests) do
    names[#names + 1] = name
end
table.sort(names)

local failed = 0
for _, name in ipairs(names) do
    local ok, err = pcall(tests[name])
    if ok then
        print("ok   " .. name)
    else
        failed = failed + 1
        print("FAIL " .. name .. ": " .. tostring(err))
    end
end
print(string.format("%d passed, %d failed", #names - failed, failed))
os.exit(failed == 0 and 0 or 1)
