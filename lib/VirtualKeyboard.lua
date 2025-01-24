-- WARNING: this is a really old library I wrote before I knew what I was doing
-- so it's a bit shitty, but it works for now
local Class = require "lib.Class"

local VK = Class:extend_as("VirtualKeyboard")
local notes = require "data.Notes"

local scales = {
    -- Major
    [1] = { name = "Major", pattern = { 2, 2, 1, 2, 2, 2, 1 } },
    -- Melodic Minor
    [2] = { name = "Melodic Minor", pattern = { 2, 1, 2, 2, 2, 2, 1 } },
    -- Harmonic Minor
    [3] = { name = "Harmonic Minor", pattern = { 2, 1, 2, 2, 1, 3, 1 } },
    -- Dorian
    [4] = { name = "Dorian", pattern = { 2, 1, 2, 2, 2, 1, 2 } },
    -- Mixolydian
    [5] = { name = "Mixolydian", pattern = { 2, 2, 1, 2, 2, 1, 2 } },
    -- Lydian
    [6] = { name = "Lydian", pattern = { 2, 2, 2, 1, 2, 2, 1 } },
    -- Lydian Dominant
    [7] = { name = "Lydian Dominant", pattern = { 2, 2, 2, 1, 2, 1, 2 } },
    -- Phrygian
    [8] = { name = "Phrygian", pattern = { 1, 2, 2, 2, 1, 2, 2 } },
    -- Locrian
    [9] = { name = "Locrian", pattern = { 1, 2, 2, 1, 2, 2, 2 } },
    -- Aeolian
    [10] = { name = "Aeolian", pattern = { 2, 1, 2, 2, 1, 2, 2 } },
    -- Freygish
    [11] = { name = "Freygish", pattern = { 1, 3, 1, 2, 1, 2, 2 } },
    -- Blues
    [12] = { name = "Blues", pattern = { 3, 2, 1, 1, 2, 1, 2 } },
    -- Diminished
    [13] = { name = "Diminished", pattern = { 2, 1, 2, 1, 2, 1, 2 } },
    -- Double Harmonic
    [14] = { name = "Double Harmonic", pattern = { 1, 3, 1, 2, 1, 3, 1 } },
    -- Minor Pentatonic
    [15] = { name = "Pentatonic", pattern = { 3, 2, 2, 3, 2 } },
    -- Iwato
    [16] = { name = "Iwato", pattern = { 1, 4, 1, 4, 2 } }
}

local keys = {
    'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',
    --'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '\\',
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '#',
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='
}

local root_key = {
    ["C"] = { 24, 36, 48, 60, 72 },
    ["C#"] = { 25, 37, 49, 61, 73 },
    ["D"] = { 26, 38, 50, 62, 74 },
    ["D#"] = { 27, 39, 51, 63, 75 },
    ["E"] = { 28, 40, 52, 64, 76 },
    ["F"] = { 29, 41, 53, 65, 77 },
    ["F#"] = { 30, 42, 54, 66, 78 },
    ["G"] = { 31, 43, 55, 67, 79 },
    ["G#"] = { 32, 44, 56, 68, 80 },
    ["A"] = { 33, 45, 57, 69, 81 },
    ["A#"] = { 34, 46, 58, 70, 82 },
    ["B"] = { 35, 47, 59, 71, 83 }
}

function VK:new()
    self.key = "D"
    self.scale = 7
    self.octave = 2
    self.key_map = {}
    self:build_keys()
end

function VK:set_octave(n)
    if root_key[self.key][n] then
        self.octave = n

        self:build_keys()
    end
end

function VK:build_keys()
    local r = root_key[self.key][self.octave]
    self.key_map['z'] = r

    local scale_ct = 1
    local last_note = r

    for k=1, #keys do
        local key = keys[k]
        if key == 'a' then
            last_note = r + 12
            self.key_map[key] = last_note
            scale_ct = 1

        elseif key == 'q' then
            last_note = r + 24
            self.key_map[key] = last_note
            scale_ct = 1

        elseif key == '1' then
            last_note = r + 36
            self.key_map[key] = last_note
            scale_ct = 1
        else
            self.key_map[key] = last_note + scales[self.scale].pattern[scale_ct]
            last_note = self.key_map[key]
            scale_ct = scale_ct + 1
            if scale_ct > #scales[self.scale].pattern then
                scale_ct = 1
            end
        end
    end
end

local chords = {
    [1] = { name = "Maj", pattern = { 4, 3 }},
    [2] = { name = "Min", pattern = { 3, 4 }},
    [3] = { name = "Maj 7", pattern = { 4, 3, 4 }},
    [4] = { name = "Min 7", pattern = { 3, 4, 3 }},
    [5] = { name = "Sus 2", pattern = { 2, 5 }},
    [6] = { name = "Sus 4", pattern = { 5, 2 }},
    [7] = { name = "Dom 7", pattern = { 4, 3, 3 }}
}

function VK:stamp(root, chord)
    -- n = notes
    local n = { root }
    local c = chords[chord]
    local last_note = root

    for i=1, #c.pattern do
        local new_note = last_note + c.pattern[i]
        table.insert(n, new_note)
        last_note = new_note
    end

    --print(n[1] .. ", " .. n[2] .. ", " .. n[3] .. ", " .. n[4])
    return #n > 0 and n or false
end

function VK:get_scale() return scales[self.scale] end
function VK:get_scales() return scales end

function VK:keypressed(key)
    if self.key_map[key] then
        if notes[self.key_map[key]] then
            muse:note_on(muse.current_track, self.key_map[key], muse.tracks[muse.current_track].volume)
            muse.last_event = { "note_on", notes[self.key_map[key]] }
        else
            muse.last_event = { "error", "Key out of range" }
        end 
    end
end

function VK:keyreleased(key)
    if self.key_map[key] then
        muse:note_off(muse.current_track, self.key_map[key])
        muse.last_event = { "note_off", notes[self.key_map[key]] }
    end
end


function VK:change_root(dir)
    -- left 
    if dir == -1 then
    --right
    elseif dir == 1 then
    end
end

function VK:mousepressed(x, y, btn)
end

function VK:mousereleased(x, y, btn)
end

function VK:get_scale_name() return scales[self.scale].name:sub(1, 4) end

function VK:update(dt)
end

return VK
