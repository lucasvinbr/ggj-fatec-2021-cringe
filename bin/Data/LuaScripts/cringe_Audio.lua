---@type SoundSource
MusicSource = nil

function SetupSound()

  -- Create music sound source
  MusicSource = Scene_:CreateComponent("SoundSource")
  -- Set the sound type to music so that master volume control works correctly
  MusicSource.soundType = SOUND_MUSIC

  -- add listener to camera
  local listener = CameraNode:CreateComponent("SoundListener")
  audio:SetListener(listener)
end


function StartMusic()
  ---@type Sound
  local musicFile = cache:GetResource("Sound","Music/cringe/fatecMix.ogg")

  musicFile.looped = true

  if not MusicSource:IsPlaying() then
    MusicSource:Play(musicFile)
  end
  
  MusicSource:SetGain(0.63)
end

function StopMusic()
  -- MusicSource:Stop()
  MusicSource:SetGain(0.0)
end

function PlayOneShotSound(soundFilePath, gain)
  -- Get the sound resource
  local sound = cache:GetResource("Sound", soundFilePath)

  if sound ~= nil then
    -- Create a SoundSource component for playing the sound. The SoundSource component plays
    -- non-positional audio, so its 3D position in the scene does not matter. For positional sounds the
    -- SoundSource3D component would be used instead
    ---@type SoundSource
    local soundSource = Scene_:CreateComponent("SoundSource")
    soundSource:SetSoundType(SOUND_EFFECT)
    soundSource:SetAutoRemoveMode(REMOVE_COMPONENT)
    soundSource:Play(sound)

    if gain == nil then
      gain = 1.0
    end

    soundSource.gain = gain
  end
end


function HandleSoundVolume(eventType, eventData)
  local newVolume = eventData["Value"]:GetFloat()
  audio:SetMasterGain(SOUND_EFFECT, newVolume)
end

function HandleMusicVolume(eventType, eventData)
  local newVolume = eventData["Value"]:GetFloat()
  audio:SetMasterGain(SOUND_MUSIC, newVolume)
end
