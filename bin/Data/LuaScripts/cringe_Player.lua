local uiManager = require "LuaScripts/ui/UI_Manager"
---@class CringePlayer : LuaScriptObject

local greenBallSfxNames = {
    "Sounds/cringe/sfx_tiro_v1.ogg",
    "Sounds/cringe/sfx_tiro_v2.ogg",
    "Sounds/cringe/sfx_tiro_v3.ogg",
  }


-- Character2D script object class
---@type CringePlayer
CringePlayer = ScriptObject()

function CringePlayer:Start()
    self.killed = false
    self.shotInterval = 0.65
    self.timeSinceLastShot = self.shotInterval
    self.shootAnimTime = 0.2
    ---@type AnimatedSprite2D
    self.animatedSprite = self.node:GetComponent("AnimatedSprite2D")
    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "CringePlayer:HandleCollisionStart")
end

function CringePlayer:Update(timeStep)

    --don't move nor animate normally if we're dead
    if self.killed then return end

    self.timeSinceLastShot = self.timeSinceLastShot + timeStep

    local node = self.node

    -- Set direction
    ---@type Vector3
    local moveDir = Vector3.ZERO -- Reset
    local speedX = Clamp(MOVE_SPEED_X / CurCameraZoom, 0.4, MOVE_SPEED_X)
    local speedY = speedX

    if input:GetKeyDown(KEY_LEFT) or input:GetKeyDown(KEY_A) then
        moveDir = moveDir + Vector3.LEFT * speedX
        self.animatedSprite.flipX = true -- Flip sprite (reset to default play on the X axis)
    end
    if input:GetKeyDown(KEY_RIGHT) or input:GetKeyDown(KEY_D) then
        moveDir = moveDir + Vector3.RIGHT * speedX
        self.animatedSprite.flipX = false -- Flip sprite (flip animation on the X axis)
    end

    if not moveDir:Equals(Vector3.ZERO) then
        speedY = speedX * MOVE_SPEED_SCALE
    end

    if input:GetKeyDown(KEY_UP) or input:GetKeyDown(KEY_W) then
        moveDir = moveDir + Vector3.UP * speedY
    end
    if input:GetKeyDown(KEY_DOWN) or input:GetKeyDown(KEY_S) then
        moveDir = moveDir + Vector3.DOWN * speedY
    end

    -- Move
    if not moveDir:Equals(Vector3.ZERO) then
        node:Translate(moveDir * timeStep)
    end

    local firingShockwave = input:GetKeyDown(KEY_SPACE)
    local firingBall = input:GetKeyDown(KEY_CTRL)

    if (firingBall or firingShockwave) and self.timeSinceLastShot > self.shotInterval then

        self.timeSinceLastShot = 0.0

        if self.animatedSprite.animation ~= "shoot" then
            self.animatedSprite:SetAnimation("shoot")
        end

        -- offset projectile spawns a little, depending on the type
        -- (offset values determined by looking at the editor)
        local projSpawnOffset = nil

        if firingBall then
            projSpawnOffset = Vector2(0.281187, 0.075)
        else
            projSpawnOffset = Vector2(0.168457, -0.1)
        end

        --figure out proj direction
        local projDirection = moveDir

        if self.animatedSprite.flipX then
            projDirection = moveDir + Vector2.LEFT
            projSpawnOffset.x = projSpawnOffset.x * -1
        else
            projDirection = moveDir + Vector2.RIGHT
        end

        -- shoot (find out which one we wanted to fire)
        local projectileNode = DynamicContentParent:CreateChild("PlayerProjectile")
        projectileNode:SetPosition2D(self.node.position + projSpawnOffset)

        ---@type CringeProjectile
        local projectileScript = projectileNode:CreateScriptObject("CringeProjectile")
        --player projs should only collide with the world and enemies
        projectileScript.collisionShape:SetMaskBits(COLMASK_ENEMY + COLMASK_WORLD)

        projectileScript.staticSprite.flipX = self.animatedSprite.flipX
        projectileScript.rigidbody:SetLinearVelocity(projDirection:Normalized() * projectileScript.speed)

        if firingShockwave then
            -- fire shockwave
            projectileNode:AddTag(TAG_PROJECTILE_SHOCKWAVE)
            projectileScript.staticSprite.sprite = cache:GetResource("Sprite2D", "Urho2D/cringe/projectiles/shockwave.png")
            local collisionOffset = Vector2(0.2, -0.2)

            PlayOneShotSound("Sounds/cringe/sfx_onda_choque.ogg", 0.6)

            if projectileScript.staticSprite.flipX then
                collisionOffset.x = collisionOffset.x * -1
            end

            projectileScript.collisionShape:SetCenter(collisionOffset)
            projectileScript.collisionShape:SetRadius(0.2)
        else
            -- fire ball
            projectileNode:AddTag(TAG_PROJECTILE_PLAYERBALL)
            projectileScript.staticSprite.sprite = cache:GetResource("Sprite2D", "Urho2D/cringe/projectiles/greenBall.png")
            PlayOneShotSound(greenBallSfxNames[RandomInt(1 , #greenBallSfxNames + 1)], 1.0)
        end
    else
        -- if it's been long enough since the last shot, animate normally
        if self.timeSinceLastShot > self.shootAnimTime then
            if not moveDir:Equals(Vector3.ZERO) then
                if self.animatedSprite.animation ~= "move" then
                    self.animatedSprite:SetAnimation("move")
                end
            elseif self.animatedSprite.animation ~= "idle" then
                self.animatedSprite:SetAnimation("idle")
            end
        end
    end
end


function CringePlayer:Die()
    self.killed = true

    self.animatedSprite:SetAnimation("shoot")

    SpawnEffect(self.node)
    PlayOneShotSound("Sounds/cringe/sfx_explosao_personagem.ogg", 1.1)

    coroutine.start(function ()
        coroutine.sleep(1.0)
        GameLost()
    end)
end

function CringePlayer:HandleCollisionStart(eventType, eventData)

    if self.killed then return end

    --die if we touch an enemy
    ---@type Node
    local otherNode = eventData["OtherNode"]:GetPtr("Node")

    if otherNode:HasTag(TAG_ENEMY) or otherNode:HasTag(TAG_PROJECTILE_ENEMY_BARBECUE) then
        self:Die()
    end
end