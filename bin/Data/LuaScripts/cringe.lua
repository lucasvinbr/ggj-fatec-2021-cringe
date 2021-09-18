CringeDebug = require "LuaScripts/cringe_Debug"
local uiManager = require "LuaScripts/ui/UI_Manager"
local cringeUiDefs = require "LuaScripts/ui/UI_Definitions"
local mouseConfig = require "LuaScripts/cringe_Mouse"
require "LuaScripts/Sample2D"
require "LuaScripts/cringe_Audio"
require "LuaScripts/cringe_Player"
require "LuaScripts/cringe_Projectile"
require "LuaScripts/cringe_Enemy"
require "LuaScripts/cringe_Enemy_Generator"
require "LuaScripts/cringe_Enemy_Barbecue"


---@type Scene
Scene_ = nil -- Scene

---@type Node
CameraNode = nil -- Camera scene node


function Start()

  SetRandomSeed(os.time())
  -- Set custom window Title & Icon
  SetWindowTitleAndIcon()

  -- Execute debug stuff startup
  CringeDebug.DebugSetup()

-- Create the scene content
  CreateScene()

-- Hook up to relevant events
  SubscribeToEvents()

  SetupSound()

  SetupUI()

  mouseConfig.SetupMouseEvents()
  mouseConfig.SetMouseMode(MM_FREE)

end


function SetupUI()
  -- Set up global UI style into the root UI element
  local style = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
  ui.root.defaultStyle = style
  
  uiManager.AddUiDefinitions(cringeUiDefs)
  uiManager.LoadUI("MainMenu")
  uiManager.LoadUI("Endgame")
  uiManager.LoadUI("Loading")
  uiManager.ShowUI("MainMenu")
end

function SetWindowTitleAndIcon()
    local icon = cache:GetResource("Image", "Textures/UrhoIcon.png")
    graphics:SetWindowIcon(icon)
    graphics.windowTitle = "GenYus 2000"
end

function CreateScene()
    Scene_ = Scene()

    -- Create the Octree, DebugRenderer and PhysicsWorld2D components to the scene
    Scene_:CreateComponent("Octree")
    Scene_:CreateComponent("DebugRenderer")
    local physicsWorld = Scene_:CreateComponent("PhysicsWorld2D")
    -- physicsWorld.gravity = Vector2.ZERO -- Neutralize gravity as the character will always be grounded

    -- Create camera
    CameraNode = Node()
    ---@type Camera
    local camera = CameraNode:CreateComponent("Camera")
    camera.orthographic = true
    camera.orthoSize = graphics.height * PIXEL_SIZE
    CurCameraZoom = 2 * Min(graphics.width / 1280, graphics.height / 800) -- Set zoom according to user's resolution to ensure full visibility (initial zoom (2) is set for full visibility at 1280x800 resolution)
    camera:SetZoom(CurCameraZoom)

    -- Setup the viewport for displaying the scene
    renderer:SetViewport(0, Viewport:new(Scene_, camera))
    renderer.defaultZone.fogColor = Color(0.2, 0.2, 0.2) -- Set background color for the scene

    -- Create tile map from tmx file
    local tileMapNode = Scene_:CreateChild("Ground")
    ---@type StaticSprite2D
    local tileMap = tileMapNode:CreateComponent("StaticSprite2D")
    tileMap.sprite = cache:GetResource("Sprite2D", "Urho2D/cringe/Floor2.png")
    tileMapNode:SetScale2D(SCALE_WORLD)

    -- create level boundaries based on world bounds constants and scale
    local boundaryThickness = 10
    local rightBoundary = Scene_:CreateChild("levelBounds")
    ---@type RigidBody2D
    local boundaryRigid = rightBoundary:CreateComponent("RigidBody2D")
    boundaryRigid.bodyType = BT_STATIC

    ---@type CollisionBox2D
    local boundaryShape = rightBoundary:CreateComponent("CollisionBox2D")
    boundaryShape:SetCategoryBits(COLMASK_WORLD)
    boundaryShape:SetSize(2.0, 2.0)

    rightBoundary.position2D = Vector2(WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x + boundaryThickness, 0)
    rightBoundary:SetScale2D(Vector2(boundaryThickness, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y))

    local leftBoundary = rightBoundary:Clone()
    leftBoundary.position2D = Vector2(-WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x - boundaryThickness, 0)
    leftBoundary:SetScale2D(Vector2(boundaryThickness, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y))

    local topBoundary = rightBoundary:Clone()
    topBoundary.position2D = Vector2(0, WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y + boundaryThickness)
    topBoundary:SetScale2D(Vector2(WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x, boundaryThickness))

    local bottomBoundary = rightBoundary:Clone()
    bottomBoundary.position2D = Vector2(0, -WORLD_BOUNDS_UNSCALED.y * SCALE_WORLD.y - boundaryThickness)
    bottomBoundary:SetScale2D(Vector2(WORLD_BOUNDS_UNSCALED.x * SCALE_WORLD.x, boundaryThickness))


end

function SetupGameMatch()

  DynamicContentParent = Scene_:CreateChild("DynamicContent")
  -- Create Spriter character
  CreateCharacter(nil, true, 0, Vector3(0, 0, 0), 0.15)

  SetupGenerators()

  -- Check when scene is rendered; we pause until the player presses "play"
  SubscribeToEvent("EndRendering", HandleSceneReady)
end


function SetupViewport()
  -- Set up a viewport to the Renderer subsystem so that the 3D scene can be seen
  local viewport = Viewport:new(Scene_, CameraNode:GetComponent("Camera"))
  renderer:SetViewport(0, viewport)
end

function SubscribeToEvents()

  -- Subscribe HandlePostUpdate() function for processing post update events
  SubscribeToEvent("PostUpdate", HandlePostUpdate)


  -- Unsubscribe the SceneUpdate event from base class to prevent camera pitch and yaw in 2D sample
  UnsubscribeFromEvent("SceneUpdate")

  -- Subscribe HandlePostRenderUpdate() function for processing the post-render update event, during which we request
  -- debug geometry
  SubscribeToEvent("PostRenderUpdate", HandlePostRenderUpdate)


  -- Subscribe to Box2D contact listeners
  -- SubscribeToEvent("PhysicsBeginContact2D", HandleCollisionBegin)

end


function HandlePostRenderUpdate(eventType, eventData)
  -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
  if CringeDebug.drawDebug  then
    Scene_:GetComponent("PhysicsWorld2D"):DrawDebugGeometry(true)
    -- Visualize navigation mesh, obstacles and off-mesh connections
    -- scene_:GetComponent("DynamicNavigationMesh"):DrawDebugGeometry(true)
    -- Visualize agents' path and position to reach
    -- scene_:GetComponent("CrowdManager"):DrawDebugGeometry(true)
  end
end

function HandleSceneReady()
  UnsubscribeFromEvent("EndRendering")
  Scene_.updateEnabled = false -- Pause the scene as long as the UI is hiding it
end

function HandlePostUpdate(eventType, eventData)
  if CringePlayerNode == nil or CameraNode == nil then
      return
  end
  CameraNode.position = Vector3(CringePlayerNode.position.x, CringePlayerNode.position.y, -10) -- Camera tracks character
end

-- function HandleCollisionBegin(eventType, eventData)
--   -- Get colliding node
--   local hitNode = eventData["NodeA"]:GetPtr("Node")
--   if hitNode.name == "Player" then
--       hitNode = eventData["NodeB"]:GetPtr("Node")
--   end
--   local nodeName = hitNode.name

--   ---@type CringePlayer
--   local player = CringePlayerNode:GetScriptObject()

--   -- Handle coins picking
--   if nodeName == "Coin" then
--       hitNode:Remove()
--       player.remainingCoins = player.remainingCoins - 1
--       -- if character.remainingCoins == 0 then
--       --     ui.root:GetChild("Instructions", true).text = "!!! Go to the Exit !!!"
--       -- end
--       -- ui.root:GetChild("CoinsText", true).text = character.remainingCoins -- Update coins UI counter
--       PlaySound("Powerup.wav")
--   end

--   -- Handle interactions with enemies
--   if nodeName == "Enemy" or nodeName == "Orc" then
--       ---@type AnimatedSprite2D
--       local animatedSprite = CringePlayerNode:GetComponent("AnimatedSprite2D")
--       local deltaX = CringePlayerNode.position.x - hitNode.position.x

--       -- Orc killed if character is fighting in its direction when the contact occurs (flowers are not destroyable)
--       if nodeName == "Orc" and animatedSprite.animation == "attack" and (deltaX < 0 == animatedSprite.flipX) then
--           hitNode:GetScriptObject().emitTime = 1
--           if not hitNode:GetChild("Emitter", true) then
--               hitNode:GetComponent("RigidBody2D"):Remove() -- Remove Orc's body
--               SpawnEffect(hitNode)
--               PlaySound("BigExplosion.wav")
--           end

--       -- Player killed if not fighting in the direction of the Orc when the contact occurs, or when colliding with a flower
--       else
--           if not CringePlayerNode:GetChild("Emitter", true) then
--               player:Die()
--               if nodeName == "Orc" then
--                   hitNode:GetScriptObject().fightTimer = 1
--               end
--               SpawnEffect(CringePlayerNode)
--               PlaySound("BigExplosion.wav")
--           end
--       end
--   end

--   -- Handle exiting the level when all coins have been gathered
--   if nodeName == "Exit" and player.remainingCoins == 0 then
--       -- Update UI
--       local instructions = ui.root:GetChild("Instructions", true)
--       instructions.text = "!!! WELL DONE !!!"
--       instructions.position = IntVector2.ZERO

--       -- Put the character outside of the scene and magnify him
--       CringePlayerNode.position = Vector3(-20, 0, 0)
--       CringePlayerNode:SetScale(1.2)
--   end

-- end
