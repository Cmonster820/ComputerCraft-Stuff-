--test printer functionality
printer = peripheral.find("printer")
if not printer.newPage() then
    error("Hey dumbass, you forgot paper or ink")
end
printer.setPageTitle("Hello, world!")
printer.write("Hello, world!")
printer.write("Hello, world!")
printer.write("Hello, world!")
printer.write("Hello, world!")
printer.write("Hello, world!")
if not printer.endPage() then
    error("Unable to end page, is there space?")
end