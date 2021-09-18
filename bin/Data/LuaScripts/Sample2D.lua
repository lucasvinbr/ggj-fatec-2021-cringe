local uiManager = require "LuaScripts/ui/UI_Manager"

CAMERA_MIN_DIST = 0.1
CAMERA_MAX_DIST = 6

MOVE_SPEED_X = 3.5 -- Movement speed for isometric maps
MOVE_SPEED_SCALE = 1 -- Scaling factor based on tiles' aspect ratio

PROJECTILES_BASE_SPEED = 2.8

DISTANCE_MIN_BETWEEN_GENERATORS = 4.0

GENERATORS_SPAWNED_MAX = 8
GENERATORS_SPAWNED_MIN = 4

COLMASK_WORLD = 1
COLMASK_PLAYER = 2
COLMASK_ENEMY = 4
COLMASK_PROJECTILE = 8

TAG_PROJECTILE_SHOCKWAVE = "shockwave"
TAG_PROJECTILE_PLAYERBALL = "ball"
TAG_PROJECTILE_ENEMY_BARBECUE = "barbecue_proj"
TAG_PLAYER = "player"
TAG_ENEMY = "enemy"

SCALE_WORLD = Vector2(2.0, 2.0)

---@type CringeEnemyGenerator[]
SpawnedGenerators = {}

GeneratorsDestroyed = 0

-- assuming world is a square
WORLD_BOUNDS_UNSCALED = Vector2(5, 5)

CurCameraZoom = 2 -- Speed is scaled according to zoom
DemoFilename = "cringe"
CringePlayerNode = nil

---@type Node
DynamicContentParent = nil

GameEnded = false

function CreateCharacter(info, createObject, friction, position, scale)
    CringePlayerNode = DynamicContentParent:CreateChild("Player")
    CringePlayerNode.position = position
    CringePlayerNode:SetScale(scale)

    ---@type AnimatedSprite2D
    local animatedSprite = CringePlayerNode:CreateComponent("AnimatedSprite2D")
    local animationSet = cache:GetResource("AnimationSet2D", "Urho2D/cringe/player.scml")
    animatedSprite.animationSet = animationSet
    animatedSprite.animation = "idle"
    animatedSprite:SetLayer(3) -- Put character over tile map (which is on layer 0) and over Orcs (which are on layer 1)

    ---@type RigidBody2D
    local body = CringePlayerNode:CreateComponent("RigidBody2D")
    body:SetGravityScale(0.0)
    body.bodyType = BT_DYNAMIC
    body.allowSleep = false

    ---@type CollisionCircle2D
    local shape = CringePlayerNode:CreateComponent("CollisionCircle2D")
    shape.radius = 1.1 -- Set shape size
    shape.friction = friction -- Set friction
    shape.restitution = 0.1 -- Slight bounce
    shape:SetCategoryBits(COLMASK_PLAYER)
    if createObject then
        CringePlayerNode:CreateScriptObject("CringePlayer") -- Create a ScriptObject to handle character behavior
    end

    -- add a BG that follows the player
    local bgNode = CringePlayerNode:CreateChild("FollowerBG")

    ---@type StaticSprite2D
    local bgRenderer = bgNode:CreateComponent("StaticSprite2D")
    bgRenderer.sprite = cache:GetResource("Sprite2D", "Urho2D/cringe/HorizonBG.png")
    bgRenderer:SetLayer(-1)

    bgNode:SetScale(2.5)
    -- Scale character's speed on the Y axis according to tiles' aspect ratio (for isometric only)
    -- MOVE_SPEED_SCALE = info.tileHeight / info.tileWidth
end


function GameLost()

    if GameEnded then return end

    GameEnded = true

    Cleanup()

    ---@type EndGameScreenData
    local endgameData = {}
    endgameData.hasWon = false

    uiManager.ShowUI("Endgame", endgameData)
end

function GameEndCheck()

    if GameEnded then return end

    if DynamicContentParent ~= nil then
        if GeneratorsDestroyed >= #SpawnedGenerators then

            GameEnded = true
            --victory!
            Cleanup()

            ---@type EndGameScreenData
            local endgameData = {}
            endgameData.hasWon = true

            uiManager.ShowUI("Endgame", endgameData)
        end
    end

end

function Cleanup()
    if DynamicContentParent ~= nil then
        GeneratorsDestroyed = 0
        DynamicContentParent:Remove()
        DynamicContentParent = nil

        GameEnded = false
    end
end

function SetupGenerators()
    local attempts = 0

    SpawnedGenerators = {}

    local uiLoading = require "LuaScripts/ui/screens/cringe_UI_Loading"

    coroutine.start(function()
        while attempts < 100 and #SpawnedGenerators < GENERATORS_SPAWNED_MAX do
            local pickedPos = Vector2(Random(-WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x, WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x), Random(-WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y))
            local positionIsValid = true
    
            for _, spawnedGen in pairs(SpawnedGenerators) do
                if DistanceBetween(spawnedGen.node.position2D, pickedPos) < DISTANCE_MIN_BETWEEN_GENERATORS then
                    positionIsValid = false
                    break
                end
            end
    
            if positionIsValid then
                table.insert(SpawnedGenerators, CreateEnemyGenerator(pickedPos))

                uiLoading.AddRandomText()
                if Random(0, 3) >= 2 then uiLoading.AddRandomText() end
            end
    
            attempts = attempts + 1

            coroutine.sleep(0.08)
        end

        uiLoading.LoadingDone()
    end)
end

---@param spawnPos Vector2
function CreateEnemyGenerator(spawnPos)
    local node = DynamicContentParent:CreateChild("EnemyGenerator")
    node.position2D = spawnPos
    node:SetScale(0.4)
    
    ---@type CringeEnemyGenerator
    local enemyGenScript = node:CreateScriptObject("CringeEnemyGenerator")

    enemyGenScript.animatedSprite:SetAnimationSet(cache:GetResource("AnimationSet2D", "Urho2D/cringe/enemies/enemy_generator.scml"))
    enemyGenScript.animatedSprite.animation = "idle"

    return enemyGenScript
end


---@param spawnPos Vector2
function CreateEnemy(spawnPos, scale)
    local node = DynamicContentParent:CreateChild("Enemy")
    node.position2D = spawnPos
    node:SetScale(scale)
    
    ---@type CringeEnemy
    local enemyScript = node:CreateScriptObject("CringeEnemyBarbecue")

    enemyScript.animatedSprite:SetAnimationSet(cache:GetResource("AnimationSet2D", "Urho2D/cringe/enemies/enemy_barbecue.scml"))
    enemyScript.animatedSprite.animation = "idle"

    return node
end

function SpawnEffect(node)
    local particleNode = Scene_:CreateChild("Emitter")
    particleNode:SetPosition2D(node.position)
    particleNode:SetScale(node.scale.x * 3)
    ---@type ParticleEmitter2D
    local particleEmitter = particleNode:CreateComponent("ParticleEmitter2D")
    particleEmitter:SetLayer(2)
    particleEmitter.effect = cache:GetResource("ParticleEffect2D", "Urho2D/sun.pex")
    
    coroutine.start(function()
        coroutine.sleep(1.5)
        particleNode:Remove()
    end)
end

function PlaySound(soundName)
    local soundNode = Scene_:CreateChild("Sound")
    ---@type SoundSource
    local source = soundNode:CreateComponent("SoundSource")
    source:Play(cache:GetResource("Sound", "Sounds/" .. soundName))
end


---@param from Vector2
---@param to Vector2
---@return number
function DistanceBetween(from, to)

    ---@type Vector2
    local subtractedVec = to - from

    return subtractedVec:Length()

end

function SaveScene(initial)
    local filename = DemoFilename
    if not initial then
        filename = DemoFilename .. "InGame"
    end

    Scene_:SaveXML(fileSystem:GetProgramDir() .. "Data/Scenes/" .. filename .. ".xml")
end
