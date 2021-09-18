---@class CringeEnemyGenerator : LuaScriptObject

---@type CringeEnemyGenerator
CringeEnemyGenerator = ScriptObject()

function CringeEnemyGenerator:Start()

    self.killed = false

    self.timeBetweenGens = 3.0
    self.timeSinceLastGen = 0.0

    ---@type AnimatedSprite2D
    self.animatedSprite = self.node:CreateComponent("AnimatedSprite2D")
    self.animatedSprite:SetLayer(3)

    ---@type RigidBody2D
    self.rigidbody = self.node:CreateComponent("RigidBody2D")
    self.rigidbody.bodyType = BT_KINEMATIC
    self.rigidbody.allowSleep = false

    ---@type CollisionCircle2D
    self.collisionShape = self.node:CreateComponent("CollisionCircle2D")
    self.collisionShape:SetRadius(0.65)
    self.collisionShape:SetFriction(1.0)
    self.collisionShape:SetCategoryBits(COLMASK_ENEMY)
    self.collisionShape:SetCenter(0.0, -0.4)

    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "CringeEnemyGenerator:HandleCollisionStart")
end

function CringeEnemyGenerator:Update(timeStep)

    if self.killed then
        return
    end

    self.timeSinceLastGen = self.timeSinceLastGen + timeStep

    if self.timeSinceLastGen > self.timeBetweenGens then
        CreateEnemy(self.node.position2D, 0.15)
        self.timeSinceLastGen = 0.0
    end
end

function CringeEnemyGenerator:Die()
    self.killed = true

    GeneratorsDestroyed = GeneratorsDestroyed + 1

    GameEndCheck()

    SpawnEffect(self.node)
    PlayOneShotSound("Sounds/cringe/sfx_explosao_personagem.ogg", 0.9)

    self.node:Remove()
end

function CringeEnemyGenerator:HandleCollisionStart(eventType, eventData)

    if self.killed then return end

    --die if we touch the player's projectiles
    ---@type Node
    local otherNode = eventData["OtherNode"]:GetPtr("Node")

    if otherNode:HasTag(TAG_PROJECTILE_PLAYERBALL) or otherNode:HasTag(TAG_PROJECTILE_SHOCKWAVE) then
        self:Die()
    end

end