local gun = script.Parent
local trigger = gun:WaitForChild("Trigger") -- Assuming the gun has a Trigger part
local equipped = false
local projectileSpeed = 100 -- Adjust as needed
local maxTargetDistance = 100 -- Maximum distance to detect targets
local sheriffTeam = game.Teams.Sheriff -- Adjust to match your team setup
local murdererTeam = game.Teams.Murderer -- Adjust to match your team setup
local shootInterval = 1 -- Adjust interval between shots (in seconds)
local lastShotTime = 0 -- Variable to track last shot time

-- Function to find the nearest enemy (Murderer for Sheriff and Sheriff for Murderer)
local function findNearestEnemy(player)
    local minDistance = math.huge
    local nearestEnemy = nil
    local myTeam = player.Team

    -- Determine which team is considered the enemy
    local enemyTeam = (myTeam == sheriffTeam) and murdererTeam or sheriffTeam

    -- Iterate through all players to find the nearest enemy from the opposing team
    for _, enemyPlayer in ipairs(enemyTeam:GetPlayers()) do
        local character = enemyPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then -- Check if enemy is alive
                local distance = (character.HumanoidRootPart.Position - gun.Position).magnitude
                if distance < minDistance and distance <= maxTargetDistance then
                    minDistance = distance
                    nearestEnemy = {
                        Humanoid = humanoid,
                        Position = character.HumanoidRootPart.Position,
                        Player = enemyPlayer
                    }
                end
            end
        end
    end

    return nearestEnemy
end

-- Function to predict the target's next position based on current velocity
local function predictTargetPosition(targetPlayer)
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        return nil
    end

    local targetPosition = targetCharacter.HumanoidRootPart.Position
    local targetVelocity = targetCharacter.HumanoidRootPart.Velocity
    local timeToReach = (targetPosition - gun.Position).magnitude / projectileSpeed
    local predictedPosition = targetPosition + targetVelocity * timeToReach
    return predictedPosition
end

-- Function to check if there's an obstacle in the path
local function isObstacleInPath(startPosition, endPosition)
    local direction = (endPosition - startPosition).unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {gun.Parent} -- Exclude gun and its parent from raycast
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(startPosition, direction * maxTargetDistance, raycastParams)
    if raycastResult and raycastResult.Instance and raycastResult.Instance:IsA("BasePart") then
        return true -- There's an obstacle in the path
    end
    return false
end

-- Function to handle firing a projectile towards a predicted target position
local function fireProjectileTowards(predictedPosition)
    local projectile = Instance.new("Part")
    projectile.Size = Vector3.new(1, 1, 1)
    projectile.Position = gun.Position
    projectile.Anchored = false
    projectile.Parent = game.Workspace

    -- Set up collision filtering to avoid self-collisions
    local noCollision = {projectile, gun}
    for _, v in ipairs(noCollision) do
        local collision = Instance.new("ObjectValue")
        collision.Value = v
        collision.Name = "NoCollision"
        collision.Parent = projectile
    end

    -- Fire the projectile towards the predicted position
    local direction = (predictedPosition - gun.Position).unit
    projectile.Velocity = direction * projectileSpeed

    -- Function to handle projectile hit events
    local function onProjectileHit(hit)
        local hitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if hitHumanoid then
            print("Enemy hit!")
            hitHumanoid:TakeDamage(hitHumanoid.Health) -- Instantly eliminate the enemy (no damage calculation)
            projectile:Destroy() -- Destroy the projectile
        end
    end

    -- Connect the hit event
    projectile.Touched:Connect(onProjectileHit)
end

-- Function to equip the weapon
local function equipWeapon()
    equipped = true
end

-- Function to unequip the weapon
local function unequipWeapon()
    equipped = false
end

-- Function to handle detection and automatic shooting
local function handleDetection(player)
    if player and equipped then
        local nearestEnemy = findNearestEnemy(player)
        if nearestEnemy then
            -- Predict the target's next position based on current velocity
            local predictedPosition = predictTargetPosition(nearestEnemy.Player)
            
            if predictedPosition then
                -- Check for obstacles in the path
                local isObstacle = isObstacleInPath(gun.Position, predictedPosition)
                
                if not isObstacle then
                    print(player.Name .. " is shooting at " .. nearestEnemy.Player.Name .. " at position " .. predictedPosition)
                    fireProjectileTowards(predictedPosition)
                else
                    print("Obstacle detected between gun and enemy.")
                end
            else
                print("Failed to predict enemy position.")
            end
        else
            print("No valid enemy found within range or on opposing team.")
        end
    end
end

-- Function to connect trigger events to detection handling
local function connectTriggerEvents()
    if not trigger or not trigger:IsA("BasePart") then
        warn("Trigger not found or invalid.")
        return
    end
    trigger.Touched:Connect(function(other)
        local humanoid = other.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local player = game.Players:GetPlayerFromCharacter(other.Parent)
            handleDetection(player)
        end
    end)
end

-- Function to disconnect trigger events
local function disconnectTriggerEvents()
    if trigger and trigger:IsA("BasePart") then
        trigger.Touched:Disconnect()
    end
end

-- Function to handle player added events
local function onPlayerAdded(player)
    if not player then return end

    player.CharacterAdded:Connect(function(character)
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool.Name == gun.Name then
            equipWeapon()
        end
    end)

    player.CharacterRemoving:Connect(function(character)
        unequipWeapon()
    end)
end

-- Function to connect player events
local function connectPlayerEvents()
    game.Players.PlayerAdded:Connect(onPlayerAdded)
end

-- Call the functions to initially connect events
connectTriggerEvents()
connectPlayerEvents()

-- Automatic shooting loop (executed every frame)
game:GetService("RunService").Stepped:Connect(function()
    if equipped and os.time() - lastShotTime >= shootInterval then
        -- Simulate player for testing in standalone mode
        local player = game.Players.LocalPlayer or game.Players:GetPlayers()[1]
        if player and player.Character then
            handleDetection(player)
            lastShotTime = os.time()
        end
    end
end)

-- Example: Disconnecting events (not typically needed in a running game, shown for completeness)
-- disconnectTriggerEvents()