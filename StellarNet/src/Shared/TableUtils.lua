-- Utility functions for working with tables
local TableUtils = {}

function TableUtils.ShallowCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

function TableUtils.DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = TableUtils.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function TableUtils.Size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count += 1
    end
    return count
end

function TableUtils.Merge(a, b)
    local result = TableUtils.DeepCopy(a)
    for k, v in pairs(b) do
        result[k] = v
    end
    return result
end

return TableUtils
