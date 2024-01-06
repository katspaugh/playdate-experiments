import 'CoreLibs/sprites.lua'
import 'CoreLibs/graphics.lua'
import 'CoreLibs/timer.lua'

gfx = playdate.graphics
timer = playdate.timer

local currentSuit = 1
local selectorX = 50
local selectorY = 200
local selectorGap = 100

local imagesPath = 'images/'

local imageNames = {
   'hearts',
   'spades',
   'diamonds',
   'clubs',
}

local cells = {}
local maxCols = 10
local maxRows = 4
local maxCells = maxCols * maxRows

local images = {}
local sprites = {}

function renderCell(cellIndex)
   if not cells[cellIndex] then
      if sprites[cellIndex] then
         sprites[cellIndex]:remove()
         sprites[cellIndex] = nil
      end
      return
   end

   if not sprites[cellIndex] then
      local row = math.floor((cellIndex - 1) / maxCols)
      local col = (cellIndex - 1) % maxCols
      local cellType = cells[cellIndex]
      local sprite = gfx.sprite.new(images[cellType])
      sprite:moveTo(col * 40 + 20, row * 40 + 20)
      sprite:add()
      sprites[cellIndex] = sprite
   end
end

function removeCell(cellIndex)
   cells[cellIndex] = nil
end

function addCell(imageIndex, cellIndex)
   cells[cellIndex] = imageIndex
end

function placeRandom()
   local randomCell = math.random(1, maxCells)
   for i = 1, maxCells do
      if cells[randomCell] then
         randomCell = math.random(1, maxCells)
      end
   end
   addCell(currentSuit, randomCell)
end

function playerAction()
   placeRandom()
end

local myInputHandlers = {
   leftButtonDown = function()
      currentSuit = (currentSuit - 1 - 1) % 4 + 1
      print('left', currentSuit)
   end,
   rightButtonDown = function()
      currentSuit = (currentSuit - 1 + 1) % 4 + 1
      print('right', currentSuit)
   end,
   AButtonDown = function()
      playerAction()
   end,
   BButtonDown = function()
      computeState()
   end,
}

function computeState()
   for i = 1, maxCells do
      if cells[i] then
         local row = math.floor((i - 1) / maxCols)
         local col = (i - 1) % maxCols
         local type = cells[i]
         local randomType = math.random(1, 4)

         if type == 1 then -- hearts
            -- add a random cell in an adjacent empty cell
            if row > 0 and not cells[i - maxCols] then
               addCell(randomType, i - maxCols)
            elseif row < maxRows - 1 and not cells[i + maxCols] then
               addCell(randomType, i + maxCols)
            elseif col > 0 and not cells[i - 1] then
               addCell(randomType, i - 1)
            elseif col < maxCols - 1 and not cells[i + 1] then
               addCell(randomType, i + 1)
            end
         elseif type == 2 then -- spades
            -- remove an adjacent cell
            if row > 0 and cells[i - maxCols] then
               removeCell(i - maxCols)
            elseif row < maxRows - 1 and cells[i + maxCols] then
               removeCell(i + maxCols)
            elseif col > 0 and cells[i - 1] then
               removeCell(i + maxCols)
            elseif col < maxCols - 1 and cells[i + 1] then
               removeCell(i + maxCols)
            end
         elseif type == 3 then -- diamonds
            -- replace an adjacent cells with a random one
            if row > 0 and cells[i - maxCols] then
               addCell(randomType, i - maxCols)
            elseif row < maxRows - 1 and cells[i + maxCols] then
               addCell(randomType, i + maxCols)
            elseif col > 0 and cells[i - 1] then
               addCell(randomType, i - 1)
            elseif col < maxCols - 1 and cells[i + 1] then
               addCell(randomType, i + 1)
            end
         elseif type == 4 then -- clubs
            -- do nothing
         end
      end
   end
end

function playdate.update()
   timer.updateTimers()
   for i = 1, maxCells do
      renderCell(i)
   end
   gfx.sprite.update()
   gfx.drawRoundRect(selectorX - 40, selectorY - 30, 380, 60, 6)
   gfx.drawRoundRect(selectorX + selectorGap * (currentSuit - 1) - 20, selectorY - 20, 40, 40, 6)
   timer.performAfterDelay(600, computeState)
end

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)
gfx.setLineWidth(2)

for i, name in ipairs(imageNames) do
   local image = gfx.image.new(imagesPath .. name)
   assert(image)
   images[i] = image
   local sprite = gfx.sprite.new(image)
   sprite:moveTo(selectorGap * (i - 1) + selectorX, selectorY)
   sprite:add()
end

playdate.inputHandlers.push(myInputHandlers)
