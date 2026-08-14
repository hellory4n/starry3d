# Audio module

TODO: spatial sounds, sound buses, effects, microphone (all supported by miniaudio)

## Sounds

### `sfx.load_sound(path: string [, args: table]): Sound`

Loads an audio file from the app directory. This should be `.wav`, `.mp3`, `.ogg`, or `.flac`. Optional parameters:

```lua
local s = sfx.load_sound("sfx.mp3", {
	stream = true,
})
```

### `Sound.path: string`

The path from which the sound was loaded.

### `Sound.loop: boolean`

If true, the sound will restart when it has reached the end.

### `Sound.volume_linear: number`

Scales the sound volume, for example:
- 1.0: original volume
- 0.5: half the volume
- 2.0: twice as loud

### `Sound.volume_db: number`

The volume for the audio, in decibels. (relative to the original volume)

### `Sound.pitch: number`

The pitch for the sound (1.0 = normal)

### `Sound.pan: number`

The panning for the sound, for example:
- -1.0: completely on the left
- 0.0: center
- 1.0: completely on the right

### `Sound.position: number`

The position of the sound, in seconds (0 if not playing). Can be set to seek the audio.

### `Sound.length: number`

The length of the sound, in seconds.

### `Sound.paused: boolean`

If true, the sound is paused.

### `Sound.playing: boolean`

If true, the sound is playing. Setting this field has the same effect as calling `sfx.play`/`sfx.stop`.

### `sfx.play(sound: Sound)`

Plays a sound.

### `sfx.stop(sound: Sound)`

Stops playing a sound.
