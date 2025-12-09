--implement the stuff from OC into here
local main = {}
function set(text,x,y,vertical)
    vertical = vertical or false
    term.setCursorPos(x,y)
    if not vertical then
        term.write(text)
    else
        local ycur = y
        for i=1,#text do
            term.setCursorPos(x,ycur)
            term.write(text[i])
            ycur = ycur+1
        end
    end
end
local main.set = set
function fill(x,y,h,w,char)
    term.setCursorPos(x,y)
    local str = ""
    for i=1,w do
        str = str+char
    end
    local ycur = y
    for i=1,h do
        term.setCursorPos(x,ycur)
        term.write(str)
        ycur = ycur+1
    end
end
local main.fill = fill
return main