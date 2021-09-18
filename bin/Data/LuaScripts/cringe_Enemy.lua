---@class CringeEnemy : LuaScriptObject

---@type CringeEnemy
CringeEnemy = ScriptObject()

function CringeEnemy:Start()
    self.moveSpeed = MOVE_SPEED_X / 2
    self.alwaysChargesAtPlayer = false
    self.chargingAtPlayer = false
    self.moveTarget = self.node.position2D
    self.dead = false
    self.chargeDistance = 5.0
    self.timeBetweenMoveTargetChanges = 8.0
    self.timeSinceLastMoveTargetChange = 0.0

    self.node:AddTag(TAG_ENEMY)

    self.moveDir = Vector3.ZERO
    ---@type AnimatedSprite2D
    self.animatedSprite = self.node:CreateComponent("AnimatedSprite2D")
    self.animatedSprite:SetLayer(3)

    ---@type RigidBody2D
    self.rigidbody = self.node:CreateComponent("RigidBody2D")
    self.rigidbody.bodyType = BT_DYNAMIC
    self.rigidbody.allowSleep = false

    ---@type CollisionCircle2D
    self.collisionShape = self.node:CreateComponent("CollisionCircle2D")
    self.collisionShape:SetRadius(0.35)
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

    if self.dead then
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

    if DistanceBetween(node.position2D, self.moveTarget) > 0.1 then
        local dir = self.moveTarget - node.position2D
        local dirNormal = dir:Normalized()
        node:Translate(Vector3(dirNormal.x, dirNormal.y, 0) * moveSpeed * timeStep)
        self.animatedSprite.flipX = dirNormal.x < 0
    end

    self.timeSinceLastMoveTargetChange = self.timeSinceLastMoveTargetChange + timeStep

    if self.timeSinceLastMoveTargetChange > self.timeBetweenMoveTargetChanges then
        self.moveTarget = Vector2(Random(-WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x, WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x), Random(-WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y))
    end
end