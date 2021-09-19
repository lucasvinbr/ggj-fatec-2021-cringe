---@class CringeEnemy : LuaScriptObject

---@type CringeEnemy
CringeEnemy = ScriptObject()

CringeEnemy.__index = CringeEnemy

function CringeEnemy:Start()
    log:Write(LOG_DEBUG, "Enemy start!")

    self.moveSpeed = MOVE_SPEED_X / 4
    self.alwaysChargesAtPlayer = false
    self.chargingAtPlayer = false
    self.moveTarget = self.node.position2D
    self.killed = false
    self.chargeDistance = 2.5
    self.timeBetweenMoveTargetChanges = 8.0
    self.timeSinceLastMoveTargetChange = self.timeBetweenMoveTargetChanges

    self.node:AddTag(TAG_ENEMY)

    self.moveDir = Vector3.ZERO

    ---@type AnimatedSprite2D
    self.animatedSprite = self.node:CreateComponent("AnimatedSprite2D")
    self.animatedSprite:SetLayer(3)

    ---@type RigidBody2D
    self.rigidbody = self.node:CreateComponent("RigidBody2D")
    self.rigidbody.bodyType = BT_DYNAMIC
    self.rigidbody.allowSleep = false
    self.rigidbody:SetGravityScale(0.0)

    ---@type CollisionCircle2D
    self.collisionShape = self.node:CreateComponent("CollisionCircle2D")
    self.collisionShape:SetRadius(1.0)
    self.collisionShape:SetFriction(0.8)
    self.collisionShape:SetCategoryBits(COLMASK_ENEMY)

    coroutine.start(function ()
        while self.node ~= nil do
            coroutine.sleep(1.0)
            if DistanceBetween(self.node.position2D, CringePlayerNode.position2D) < self.chargeDistance then
                self.chargingAtPlayer = true
            else
                if not self.alwaysChargesAtPlayer then
                    self.chargingAtPlayer = false
                end
            end
        end
    end)
end

function CringeEnemy:Update(timeStep)

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
end