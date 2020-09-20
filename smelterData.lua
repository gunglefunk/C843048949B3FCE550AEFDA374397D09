factory = 'F:ModFrame'
area    = 'A:SmeltRoom'
thisLocation = factory .. ' ' .. area .. ' '

print('Location: '..thisLocation)

function dump (a)
   for _,m in pairs(a:getMembers()) do
      print(m)
   end
end

function dumpt (a)
   for _,m in pairs(a) do
      print(m)
   end
end

function unpack (t, i)
   i = i or 1
   if t[i] ~= nil then
      return t[i], unpack(t, i + 1)
   end
end

function togglePower ()
    local fuse = component.proxy(component.findComponent(thisLocation .. 'T:PowerFuse'))[1]
    if fuse:isConnected() then
        fuse:setConnected(false)
    else
        fuse:setConnected(true)
    end
end

function getStorageUsage (idTxt)
   local totalSize = 0
   local totalUsed = 0
   local usagePct  = 0
   local theBuffers = component.proxy(component.findComponent(thisLocation .. 'T:' .. idTxt))
   for k,v in pairs(theBuffers) do
      local invs = v:getInventories()
      for i=1,#invs do
         totalSize = totalSize + invs[i].size
         totalUsed = totalUsed + invs[i].itemCount
      end
   end

   usagePct = totalUsed / totalSize
   return usagePct
end

function toggleStandby (id)
   local smlt = component.proxy(component.findComponent(thisLocation .. 'T:Smelter ID:' .. id))[1]
   smlt.standby = not smlt.standby
end

function flushSmelter (id)
   local smlt = component.proxy(component.findComponent(thisLocation .. 'T:Smelter ID:' .. id))[1]
   local inQ = smlt:getInputInv()
   local outQ = smlt:getOutputInv()
   inQ:flush()
   outQ:flush()
end

function flushAllSmelters ()
   for i=1,#smelterData do
      flushSmelter(i)
   end
end

function flushInputBuffer ()
   local theBuffers = component.proxy(component.findComponent(thisLocation .. 'T:InStorage'))
   for k,v in pairs(theBuffers) do
      local invs = v:getInventories()
      for i=1,#invs do
         invs[i]:flush()
      end
   end
end

function flushOutputBuffer ()
   local theBuffers = component.proxy(component.findComponent(thisLocation .. 'T:OutStorage'))
   for k,v in pairs(theBuffers) do
      local invs = v:getInventories()
      for i=1,#invs do
         invs[i]:flush()
      end
   end
end

screen = component.proxy(component.findComponent(thisLocation .. 'T:Display ID:1'))[1]
gpu = computer.getGPUs()[1]
gpu:bindScreen(screen)
gpu:setSize(30,18)
w,h = gpu:getSize()

panel = component.proxy(component.findComponent(thisLocation .. 'T:Panel ID:1'))[1]

powerShunt = panel:getModule(4,6,2)
event.listen(powerShunt)

dispUseMonospace = true
dispFontSize = 30

displays = {}
displayCoords = {
   {1,9,1},
   {7,9,1},
   {1,7,1},
   {7,7,1},
   {1,5,1},
   {7,5,1},
   {1,3,1},
   {7,3,1},
   {1,1,1},
   {7,1,1},
   {1,10,0},
   {7,10,0},
   {1,8,0},
   {7,8,0},
   {1,6,0},
   {7,6,0}
}

for i=1,#displayCoords do
   displays[i] = panel:getModule(unpack(displayCoords[i]))
   displays[i]:setMonospace(dispUseMonospace)
   displays[i]:setSize(dispFontSize)
   displays[i]:setText("WAITING..")
end

standbyButtonOnColor = {0,1,0,0.2}
standbyButtonOffColor = {1,0,0,0.2}
standbyButtonWaitColor = {0,0,0.5,0.2}
standbyButtons = {}
standbyButtonCoords = {
   {0,9,1},
   {6,9,1},
   {0,7,1},
   {6,7,1},
   {0,5,1},
   {6,5,1},
   {0,3,1},
   {6,3,1},
   {0,1,1},
   {6,1,1},
   {0,10,0},
   {6,10,0},
   {0,8,0},
   {6,8,0},
   {0,6,0},
   {6,6,0}
}

for i=1,#standbyButtonCoords do
   standbyButtons[i] = panel:getModule(unpack(standbyButtonCoords[i]))
   standbyButtons[i]:setColor(unpack(standbyButtonWaitColor))
   event.listen(standbyButtons[i])
end

flushButtons = {}
flushButtonCoords = {
   {0,8,1},
   {6,8,1},
   {0,6,1},
   {6,6,1},
   {0,4,1},
   {6,4,1},
   {0,2,1},
   {6,2,1},
   {0,0,1},
   {6,0,1},
   {0,9,0},
   {6,9,0},
   {0,7,0},
   {6,7,0},
   {0,5,0},
   {6,5,0}
}
flushButtonColor = {1,1,0,0.1}
  
for i=1,#flushButtonCoords do
   flushButtons[i] = panel:getModule(unpack(flushButtonCoords[i]))
   flushButtons[i]:setColor(unpack(flushButtonColor))
   event.listen(flushButtons[i])
end

flushInputBtn = panel:getModule(4,3,0)
flushInputBtn:setColor(unpack(flushButtonColor))
event.listen(flushInputBtn)

storageUsageFontSize = 100

inputUsageDisplay = panel:getModule(1,2,0)
inputUsageDisplay:setMonospace(true)
inputUsageDisplay:setSize(storageUsageFontSize)
inputUsageDisplay:setText("WAITING..")

outputUsageDisplay = panel:getModule(6,2,0)
outputUsageDisplay:setMonospace(true)
outputUsageDisplay:setSize(storageUsageFontSize)
outputUsageDisplay:setText("WAITING..")

flushAllSmeltersBtn = panel:getModule(5,3,0)
flushAllSmeltersBtn:setColor(unpack(flushButtonColor))
event.listen(flushAllSmeltersBtn)

flushOutputBtn = panel:getModule(6,3,0)
flushOutputBtn:setColor(unpack(flushButtonColor))
event.listen(flushOutputBtn)

smelterUUIDs = component.findComponent(thisLocation .. 'T:Smelter')
theSmelters = component.proxy(smelterUUIDs)
smelterData = {}

while true do 
   evt,sender,args = event.pull(0.25)
   if evt ~= nil then
      
      for i=1,#standbyButtons do
         if sender == standbyButtons[i] then
            toggleStandby(i)
            break
         end
      end

      for i=1,#flushButtons do
         if sender == flushButtons[i] then
            flushSmelter(i)
            break
         end
      end
      if sender == powerShunt then
        togglePower()
      elseif sender == flushInputBtn then
         flushInputBuffer()
      elseif sender == flushAllSmeltersBtn then
         flushAllSmelters()
      elseif sender == flushOutputBtn then
         flushOutputBuffer()
      end
   end

   for key,val in pairs(theSmelters) do
      loclen = string.len(thisLocation .. ' T:Smelter ')
      shortName = string.sub(val.nick, loclen)
      idStr = string.sub(shortName,4)
      idNumber = tonumber(idStr)
      isStandby = val.standby
      prettyProductivity = tonumber(string.format("%.1f",val.productivity * 100))
      outQ = val:getOutputInv().itemCount
      inQ = val:getInputInv().itemCount
      smelterData[idNumber] = {prod=prettyProductivity,inputQ=inQ,outputQ=outQ,standby=isStandby}
   end

   gpu:setBackground(0,0,0,1)
   gpu:setForeground(0,0,0,1)
   gpu:fill(0,0,w,h," ")
   gpu:flush()
   gpu:setForeground(0,1,0,1)
   outputBuffer = ""
   for i=1,#smelterData do

      if smelterData[i]["standby"] ~= nil then
         if smelterData[i]["standby"] == true then
            if standbyButtons[i] ~= nil then
               standbyButtons[i]:setColor(unpack(standbyButtonOffColor))
            end
         else
            if standbyButtons[i] ~= nil then
               standbyButtons[i]:setColor(unpack(standbyButtonOnColor))
            end
         end
      end

      text = string.format("%02d | %5.1f | %3d | %3d", i,
                                                       smelterData[i]["prod"],
                                                       smelterData[i]["inputQ"],
                                                       smelterData[i]["outputQ"])
      outputBuffer = outputBuffer .. "\r\n" .. text
      if displays[i] ~= nil then
         stbyTxt = ''
         if smelterData[i]["standby"] == true then
            stbyTxt = '(STANDBY)'
         end
         line0 = string.format("%1s : %02d %9s", 'Smelter', i, stbyTxt)
         line1 = string.format("%1s : %5.1f", 'Efficiency', smelterData[i]["prod"])
         line2 = string.format("%1s : %3d", 'Input Queue', smelterData[i]["inputQ"])
         line3 = string.format("%1s : %3d", 'Output Queue', smelterData[i]["outputQ"])
         displays[i]:setText(line0 .. '\r\n' .. line1 .. '\r\n' .. line2 .. '\r\n' .. line3 )
      end

      inputUsageDisplay:setText(string.format("%5.1f", getStorageUsage('InStorage')))
      outputUsageDisplay:setText(string.format("%5.1f", getStorageUsage('OutStorage')))

   end

   gpu:setText(0,0,outputBuffer)
   gpu:flush()
end