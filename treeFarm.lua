local computer = require("computer");--Only used for computer.energy();
local term = require("term");--Only used for clear the console
local robot = require("robot");


--Configuration of the tree farm
local sizeX = 7;
local sizeZ = 7;
local minimumEnergyToWork = 3000;
local timerMultiplier = 5;




-- Clrear console
if term.isAvailable() then 
    term.clear();
end

--Sapling position in the robot inventory
robot.select(1);


--Plant function, return true if plant the sapling, false if not
local function tryPlant()
    if robot.count(1) == 1 then--Not Enough saplings, must have at least 1
        print("Need more saplings");
        os.sleep(20);
        return false;
    
    else--Plant the tree
        robot.placeDown();
        return true;
    end
end

-- function for cut down a tree
local function cutTree()
    local treeHeight = 0;
    while( robot.detectUp() or robot.detect())
    do
        robot.swingUp();
        if robot.up() == nil then
            break
        end
        treeHeight = treeHeight +1;
    end
    robot.swing();
    robot.down();
    robot.turnLeft();
    for y = 1, treeHeight, 1 do -- Loop in the height of the tree
        for i = 0,7,1 do -- Loop around the wood block clearing all, for get saplings
            robot.turnLeft();
            robot.swing();
            robot.turnRight();
            robot.swing();
            if i%2 == 0 then
                robot.forward();
            else
                robot.turnRight();
                robot.swing();
                robot.forward();
            end
        end
        robot.turnRight();
        robot.swing();
        if y ~= treeHeight then
            robot.swingDown();
            robot.down();
            robot.turnLeft();
        end
    end
    robot.forward();
    robot.swingDown();
    robot.placeDown();
end

-- Loop function, farm the trees and replant
local function farming()
    for x = 0,sizeX-1,3 do 
        for z = 0,sizeZ-4,3 do
            robot.swing(); --Clear posible leaves
            robot.forward();
            robot.swing(); --Clear posible leaves
            robot.forward();
            if robot.detect() then --Tree detected
                cutTree();
            else
                robot.forward();
            end
        end
        if  x ~= sizeX-1 then 
            if x%6 == 0 then     -- x = 0 postion
                robot.turnRight();
                robot.swing(); --Clear posible leaves
                robot.forward();
                robot.swing(); --Clear posible leaves
                robot.forward();
                if robot.detect() then --Tree detected
                    cutTree();
                else
                    robot.forward();
                end
                robot.turnRight();
                
            else                 -- x = max position
                robot.turnLeft();
                robot.swing(); --Clear posible leaves
                robot.forward();
                robot.swing(); --Clear posible leaves
                robot.forward();
                if robot.detect() then --Tree detected
                    cutTree();
                else
                    robot.forward();
                end
                robot.turnLeft();
            end
        else                    -- finish planting
            robot.turnAround();
            while(computer.energy() < minimumEnergyToWork) do
                print("AFK mode, need solar charging...");
                os.sleep(60 * timerMultiplier);
            end
        end
    end
end

--Inicial loop for plant all the saplings of the farm
local function plantSplings()
    robot.up();
    for x = 0,sizeX-1,3 do 
        for z = 0,sizeZ-1,3 do
            if tryPlant() then
                if z ~= sizeX-1 then
                    robot.forward();
                    robot.forward();
                    robot.forward();
                end
            else--Can't plant, wait for more sapligns
                z = z -3;
            end
        end
        if  x ~= sizeX-1 then 
            if x%6 == 0 then     -- x = 0 postion
                robot.turnRight();
                robot.forward();
                robot.forward();
                robot.forward();
                robot.turnRight();
            else                 -- x = max position
                robot.turnLeft();
                robot.forward();
                robot.forward();
                robot.forward();
                robot.turnLeft();
            end
        else                    -- finish planting
            robot.turnAround();
            print("Finish the initial planting, waiting some time...");
            os.sleep(200);--Wait initial Time, for some trees finish to grow
        end
    end
end

print("Running treeFarmer program...");
--Check have enough energy
while(computer.energy() < minimumEnergyToWork) do
    print("AFK mode, need solar charging...");
    os.sleep(60 * timerMultiplier);
end

while(robot.count(1) == 0) do
    print("Need saplings in the slot 1 of the inventory. Recomended: Spruce or Birch");
    os.sleep(20);
end

plantSplings();
print("Llega");
while(true) do
    print("Llega2");
    farming();
    print("Iteration end, waiting some time to the next...")
    os.sleep(40 * timerMultiplier);
end
print("No deberia llegar");