--I'm going to actually use comments for this file because this is too complex for me to look at but if it
--turns out to be simpler then I will remove them because of reasons
local AST = {}
local function AST.node(type,content,children)
    return { type = type, content = content, children = children or {} }
end
main = {}
function parseMD(documentStr)
    local lines = {} --table containing each line
    for line in string.gmatch(documentStr .. "\n", "(.-)\n") do
        lines:insert(line)--populate table
    end
    local document = AST.node("document") --create parentest node
    local curContainer = document --Google ai is doing most of the heavy lifting but I'm pretty sure this is just the parent node being worked on so stuff like curContainer.children = node
    local lineInd = 1 --line index
    while lineInd<=#lines do
        local line = lines[lineInd]
        --check for heading
        local header = line:find("^#") --The original name of the variable was confusing
        if header then
            
    end
end