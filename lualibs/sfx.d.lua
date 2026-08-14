--- @meta

--- @class sfxlib
sfx = {}

--- @class sfx.Sound*
--- @field path string The path from which the sound was loaded.
--- @field loop boolean If true, the sound will restart when it has reached the end.
--- @field volume_linear number Scales the sound volume, for example: 1.0 = original volume, 0.5 = half the volume, 2.0 = twice as loud
--- @field volume_db number The volume for the audio, in decibels. (relative to the original volume)
--- @field pitch number The pitch for the sound (1.0 = normal)
--- @field pan number The panning for the sound, for example: -1.0 = completely on the left, 0.0 = center, 1.0 = completely on the right
--- @field position number The position of the sound, in seconds (0 if not playing). Can be set to seek the audio.
--- @field length number The length of the sound, in seconds.
--- @field paused boolean If true, the sound is paused.
--- @field playing boolean If true, the sound is playing. Setting this field has the same effect as calling `sfx.play`/`sfx.stop`.

--- Plays a sound.
--- @param sound sfx.Sound*
function sfx.play(sound) end

--- Stops playing a sound.
--- @param sound sfx.Sound*
function sfx.stop(sound) end
