disk_uuid = "C843048949B3FCE550AEFDA374397D09"
fileName = '/smelterData.lua'
 

fs = filesystem
if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

drives = fs.childs("/dev")

-- Filtering out "serial"
for idx, drive in pairs(drives) do
    if drive == "serial" then table.remove(drives, idx) end
end

-- List all the drives
for i = 1, #drives do
    print(drives[i])
end


-- Mount our drive to root
fs.mount("/dev/"..disk_uuid, "/")

-- Execute named file
fs.doFile(fileName)