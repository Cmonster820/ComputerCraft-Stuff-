--I'm going to actually use comments for this file because this is too complex for me to look at but if it
--turns out to be simpler then I will remove them because of reasons
--all regex is out of google ai because I'm not enough of a no-life to learn lua regex
local AST = {}
local function AST.node(type,content,children)
    return { type = type, content = content, children = children or {} }
end
main = {}
local function is_block_start(line) --this entire function is copy pasted from google ai because of the amount of RegEx
    -- Check for Headers
    if string.find(line, "^#") then return true end
    -- Check for Horizontal Rules (--- or ***)
    if string.find(line, "^%s*[%-%*][%-%*][%-%*]%s*$") then return true end
    -- Check for List items
    if string.find(line, "^%s*[*-+]%s+") then return true end
    -- Check for Blockquotes
    if string.find(line, "^%s*>") then return true end
    -- Check for Code Fences
    if string.find(line, "^%s*```") then return true end
    return false
end
function parseMD(documentStr)
    local lines = {} --table containing each line
    for line in string.gmatch(documentStr .. "\n", "(.-)\n") do
        lines:insert(line)--populate table
    end
    local document = AST.node("document") --create parentest node
    local curContainer = document --Google ai is doing most of the heavy lifting but I'm pretty sure this is just the parent node being worked on so stuff like curContainer.children = node
    local lineInd = 1 --line index
    local curParaLines = {} -- buffer to hold paragraph lines, I'm not even sure what I repurposed it into
    while lineInd<=#lines do
        local line = lines[lineInd]
        local isblank = string.gsub(line, "%s", "") == "" --Identify if the current line is blank, used for parsing paragraphs
        if line:find("^#") then -- if #'s are present then do heading stuff
            local level = line:match("^(#+) ") --creates a string of pound symbols that the # operator can be used on to get the level
            local content = line:match("^#+ (.*)$")--extracts content
            curContainer.children:insert(AST.node("header",{content},{level=#level}))
            lineInd = lineInd+1
        elseif line:find("^%s*[%-%*][%-%*][%-%*]%s*$") then --check for horizontal rules
            if curContainer.type=="list" or curContainer.type=="Olist" or curContainer.type=="bq" then
                curContainer.children:insert(AST.node("hrule",nil,nil))
            elseif curContainer.type~="cb" then
                curContainer.content:insert(line)
            else
                if #curParaLines>0 then
                    curContainer = document
                    curContainer.children:insert(AST.node("hrule",nil,nil))
                end
            end
        elseif line:find("^%s*[*-+]%s+") then --check for unordered lists
            local content = line:match("^%s*[*-+]%s+ (.*)$")--should extract content
            if curContainer == document then
                curContainer.children:insert(AST.node("list",{content}))
                curContainer = curContainer.children[#curContainer.children]
            elseif curContainer == "list" then
                curContainer.content:insert(content)
            else
                curContainer.children:insert(AST.node("list",{content},{item=#curContainer.content}))
                curContainer = curContainer.children[#curContainer.children]
            end
        elseif isblank then --check terminator
            if #curParaLines>0 then
                curContainer = document --leave the paragraph node
            end
            --I'll finish this up last because paragraph stuff is the final case
        end
    end
end