---@class CringeProjectile : LuaScriptObject

---@type CringeProjectile
CringeProjectile = ScriptObject()

function CringeProjectile:Start()
    self.speed = PROJECTILES_BASE_SPEED
    self.exploding = false
    self.moveDir = Vector3.ZERO
    self.rotatesAccordingToTrajectory = false
    self.lastPos = self.node.position2D

    self.lifespan = 1.25
    self.liveTime = 0.0

    ---@type StaticSprite2D
    self.staticSprite = self.node:CreateComponent("StaticSprite2D")
    self.staticSprite:SetLayer(3)

    ---@type RigidBody2D
    self.rigidbody = self.node:CreateComponent("RigidBody2D")
    self.rigidbody.bodyType = BT_DYNAMIC
    self.rigidbody.allowSleep = false
    self.rigidbody:SetGravityScale(0.0)

    ---@type CollisionCircle2D
    self.collisionShape = self.node:CreateComponent("CollisionCircle2D")
    self.collisionShape:SetRadius(0.15)
    self.collisionShape:SetFriction(0.0)
    self.collisionShape:SetCategoryBits(COLMASK_PROJECTILE)
    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "CringeProjectile:HandleCollisionStart")
end

function CringeProjectile:Update(timeStep)

    if self.rotatesAccordingToTrajectory then
        local posDelta = self.node.position2D - self.lastPos
        self.node:SetRotation2D(Atan2(posDelta.y, posDelta.x))
    end

    self.liveTime = self.liveTime + timeStep

    if self.liveTime > self.lifespan then
        self.node:Remove()
        return
    end

    self.lastPos = self.node.position2D
end

function CringeProjectile:HandleCollisionStart(eventType, eventData)

    --TODO destroy stuff!

    self.node:Remove()
end