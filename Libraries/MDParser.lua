--I'm going to actually use comments for this file because this is too complex for me to look at but if it
--turns out to be simpler then I will remove them because of reasons
--all regex is out of google ai because I'm not enough of a no-life to learn lua regex
local AST = {}
local function AST.node(type,content,children,parent,...)
    return { type = type, content = content, children = children or {},parent = parent or nil,{...} }
end
main = {}
function parseMD(documentStr)
    local lines = {} --table containing each line
    for line in string.gmatch(documentStr .. "\n", "(.-)\n") do
        lines:insert(line)--populate table
    end
    local document = AST.node("document") --create parentest node
    local curContainer = document
    local lineInd = 1 --line index
    local curParaLines = {} -- buffer to hold paragraph lines, I'm not even sure what I repurposed it into
    while lineInd<=#lines do
        local line = lines[lineInd]
        local isblank = string.gsub(line, "%s", "") == "" --Identify if the current line is blank, used for parsing paragraphs
        if curContainer.type == "cb" then
            if line:find("^%s*```") then
                curContainer = curContainer.parent
            else
                curContainer.content:insert(line)
            end
        elseif line:find("^#") then -- if #'s are present then do heading stuff
            local level = line:match("^(#+) ") --creates a string of pound symbols that the # operator can be used on to get the level
            local content = line:match("^#+ (.*)$")--extracts content
            curContainer.children:insert(AST.node("header",{content},_,curContainer,{level=#level}))
        elseif line:find("^%s*[%-%*][%-%*][%-%*]%s*$") then --check for horizontal rules
                curContainer.children:insert(AST.node("hrule",_,curContainer,{item=#curContainer.content}))
            end
        elseif line:find("^%s*[*-+]%s+") then --check for unordered lists
            local content = line:match("^%s*[*-+]%s+ (.*)$")--should extract content
            if curContainer == "document" then
                curContainer.children:insert(AST.node("list",{content},_,curContainer,{level=#(line:match("^(%s*)"))}))
                curContainer = curContainer.children[#curContainer.children]
            elseif curContainer.type == "list" then
                if #(line:match("^(%s*)"))==curContainer.level then
                    curContainer.content:insert(content)
                elseif #(line:match("^(%s*)"))>curContainer.level then
                    curContainer.children:insert(AST.node("list",{content},_,curContainer,{item=#curContainer.content},{level=#(line:match("^(%s*)"))})))
                    curContainer = curContainer.children[#curContainer.children]
                else
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                end
            elseif curContainer.type == "olist" then
                if #(line:match("^(%s*)"))==curContainer.level then
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                elseif #(line:match("^(%s*)"))<curContainer.level then
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                else
                    curContainer.children:insert(AST.node("list",{content},_,curContainer,{item=#curContainer.content},{level=#(line:match("^(%s*)"))}))
                    curContainer = curContainer.childrent[#curContainer.children]
                end
            else
                curContainer.children:insert(AST.node("list",{content},_,curContainer,{item=#curContainer.content},{level = #(line:match("^(%s*)"))}))
                curContainer = curContainer.children[#curContainer.children]
            end
        elseif line:find("^%s*%d+%.%s+") then --detect ordered lists
            local content = line:match("^%s*%d+%.%s+ (.*$)")
            if curContainer.type == "document" then
                curContainer.children:insert(AST.node("olist",{content},_,curContainer,{level=#(line:match("^(%s*)"))}))
                curContainer = curContainer.children[#curContainer.children]
            elseif curContainer.type == "olist" then
                if #(line:match("^(%s*)")) == curContainer.level then
                    curContainer.content:insert(content)
                    curContainer = curContainer.children[#curContainer.children]
                elseif #(line:match("^(%s*)"))>curContainer.level then
                    curContainer.children:insert(AST.node("olist",{content},_,curContainer,{item=#curContainer.content},{level=#(line:match("^(%s*)"))}))
                    curContainer = curContainer.children[#curContainer.children]
                else
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                end
            elseif curContainer.type == "list" then
                if #(line:match("^(%s*)"))==curContainer.level then
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                elseif #(line:match("^(%s*)"))<curContainer.level then
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                else
                    curContainer.children:insert(AST.node("olist",{content},_,curContainer,{item=#curContainer.content},{level=#(line:match("^(%s*)"))}))
                    curContainer = curContainer.childrent[#curContainer.children]
                end
            else
                curContainer.children:insert(AST.node("olist",{content},_,curContainer,{item=#curContainer.content},{level=#(line:match("^(%s*)"))}))
                curContainer = curContainer.children[#curContainer.children]
            end
        elseif line:find("^%s*>") then --check blockquotes
            local content = line:match("^%s*> (.*$)")
            local level = #(line:match("^(%s*)"))
            if curContainer.type=="list" or curContainer.type=="olist" then
                if curContainer.level == level then
                    curContainer.children:insert(AST.node("bq",{content},_,curContainer,{item = #curContainer.content},{level=level}))
                    curContainer = curContainer.children[#curContainer.children]
                else
                    curContainer = curContainer.parent
                    curContainer.children:insert(AST.node("bq",{content},_,curContainer,{item = #curContainer.content},{level=level}))
                end
            elseif curContainer.type=="document" then
                curContainer.children:insert(AST.node("bq",{content},_,curContainer,{level=level}))
            elseif curContainer.type =="bq" then
                if curContainer.level==level then
                    curContainer.content:insert(content)
                elseif curContainer.level<level then
                    curContainer.children:insert(AST.node("bq",{content},_,curContainer,{item=#curContainer.content},{level=level}))
                    curContainer = curContainer.children[#curContainer.children]
                else
                    curContainer = curContainer.parent
                    lineInd = lineInd-1
                end
            elseif curContainer.type =="paragraph" then
                curContainer.children:insert(AST.node("bq",{content},_,curContainer,{item=#curContainer},{level=level}))
                curContainer=curContainer.children[#curContainer.children]
            end
        elseif line:find("^%s*```") then -- check for code blocks, no special formatting inside them
            if curContainer.type~="cb" then
                curContainer = curContainer.parent
            elseif curContainer.type=="document" then
                curContainer.children:insert(AST.node("cb",{},_,curContainer))
                curContainer = curContainer.children[#curContainer.children]
            else
                curContainer.children:insert(AST.node("cb",{},_,curContainer,{item=#curContainer.content},{level=curContainer.level}))
            end 
        elseif isblank then --split blocks
            curContainer = document
        else --paragraph processing
            if curContainer.type~="paragraph" then
                curContainer.children:insert(AST.node("paragraph",{line},_,curContainer))
            else
                curContainer.content:insert(line)
            end
        end
        lineInd = lineInd+1
    end
end