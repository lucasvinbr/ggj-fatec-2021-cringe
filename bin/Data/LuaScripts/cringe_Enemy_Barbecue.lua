require "LuaScripts/cringe_Enemy"

---@class CringeEnemyBarbecue : CringeEnemy

---@type CringeEnemyBarbecue
CringeEnemyBarbecue = {}

setmetatable(CringeEnemyBarbecue, CringeEnemy)
local super = CringeEnemy
--CringeEnemy.__index = CringeEnemy

function CringeEnemyBarbecue:Start()
    super.Start(self)

    log:Write(LOG_DEBUG, "Barbecue start!")

    self.shotInterval = 2.0
    self.timeSinceLastShot = 0.0
    self.shootAnimTime = 0.2
    self.firing = false

    self.shootRange = 1.6

    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "CringeEnemyBarbecue:HandleCollisionStart")
end

function CringeEnemyBarbecue:Update(timeStep)

    if self.killed then
        return
    end

    local node = self.node
    local moveSpeed = self.moveSpeed

    if not self.chargingAtPlayer then
        -- walk slower when not in combat
        moveSpeed = moveSpeed / 2
    else
        self.moveTarget = CringePlayerNode.position2D
    end

    ---@type Vector2
    local moveDir = (self.moveTarget - node.position2D):Normalized()
    local distanceToTarget = DistanceBetween(node.position2D, self.moveTarget)

    if distanceToTarget > 0.1 then
        node:Translate(Vector3(moveDir.x, moveDir.y, 0) * moveSpeed * timeStep)
        self.animatedSprite.flipX = moveDir.x < 0
    end

    self.timeSinceLastMoveTargetChange = self.timeSinceLastMoveTargetChange + timeStep

    if self.timeSinceLastMoveTargetChange > self.timeBetweenMoveTargetChanges then
        self.moveTarget = Vector2(Random(-WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x, WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x), Random(-WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y))
        self.timeSinceLastMoveTargetChange = 0.0
    end

    -- shooting/anim
    self.timeSinceLastShot = self.timeSinceLastShot + timeStep

    if self.chargingAtPlayer and distanceToTarget < self.shootRange then
        self.firing = true
    else
        self.firing = false
    end

    if self.firing and self.timeSinceLastShot > self.shotInterval then

        self.timeSinceLastShot = 0.0

        if self.animatedSprite.animation ~= "shoot" then
            self.animatedSprite:SetAnimation("shoot")
        end

        -- offset projectile spawns a little
        -- (offset values determined by looking at the editor)
        local projSpawnOffset = nil

        projSpawnOffset = Vector2(0.281187, 0.0743792)

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
        projectileNode:SetScale2D(Vector2.ONE * 0.5)

        ---@type CringeProjectile
        local projectileScript = projectileNode:CreateScriptObject("CringeProjectile")
        --enemy projs should only collide with the world and player
        projectileScript.collisionShape:SetMaskBits(COLMASK_PLAYER + COLMASK_WORLD)

        -- projectileScript.staticSprite.flipX = self.animatedSprite.flipX
        projectileScript.rigidbody:SetLinearVelocity(projDirection:Normalized() * projectileScript.speed)

        projectileScript.rotatesAccordingToTrajectory = true

        projectileNode:AddTag(TAG_PROJECTILE_ENEMY_BARBECUE)
        projectileScript.staticSprite.sprite = cache:GetResource("Sprite2D", "Urho2D/cringe/projectiles/barbecue_proj.png")

        projectileScript.rigidbody:SetGravityScale(0.25)
        projectileScript.rigidbody:SetLinearDamping(0.5)

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

function CringeEnemyBarbecue:Die()
    self.killed = true
    self.node:Remove()

    SpawnEffect(self.node)
    PlayOneShotSound("Sounds/cringe/sfx_explosao_personagem.ogg", 0.6)
end

function CringeEnemyBarbecue:HandleCollisionStart(eventType, eventData)

    if self.killed then return end

    --die if we touch the player's projectiles
    ---@type Node
    local otherNode = eventData["OtherNode"]:GetPtr("Node")

    if otherNode:HasTag(TAG_PROJECTILE_PLAYERBALL) or otherNode:HasTag(TAG_PROJECTILE_SHOCKWAVE) then
        self:Die()
    end

end