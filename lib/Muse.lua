local Class = require "lib.Class"

local ffi = require("ffi")
local json = require "lib.json"

ffi.cdef(require("data.cdefs"))

local save_path = love.filesystem.getSaveDirectory()

local osver = love.system.getOS()
local libfile

if osver == "Linux" then
    libfile = "libfluidsynth.so"
elseif osver == "Windows" then
    libfile = "libfluidsynth-3.dll"
elseif osver == "OS X" then
    libfile = "libfluidsynth-3.dylib"
end

if osver == "Windows" then
    local dlls = {
        "libgcc_s_sjlj-1.dll", "libintl-8.dll", "libglib-2.0-0.dll", "libgthread-2.0-0.dll", "libgobject-2.0-0.dll",
        "libwinpthread-1.dll", "sndfile.dll",
        "libgomp-1.dll", "libinstpatch-2.dll", "libstdc++-6.dll"
    }

    for _,dll in ipairs(dlls) do
        ffi.load(save_path .. "/" .. dll)
    end
end

local lib = ffi.load(save_path .. "/" .. libfile)
local tick = require "lib.tick"

local M = Class:extend_as("Muse")

-- attempt to use the given driver
-- deprecated.. maybe
local function try_audio_driver(lib, settings, synth, driver_name)
    if driver_name then
        lib.fluid_settings_setstr(settings, "audio.driver", driver_name)
    end

    local adriver = lib.new_fluid_audio_driver(settings, synth)
    if adriver == nil then
        return false, "Failed to create FluidSynth audio driver!"
    end

    return adriver
end

local last_col = 0
local track_colors = {
    "fc2c35", "f97731", "dfc25c", "d8e47e",
    "90c51b", "61b641", "4aad36", "48c188",
    "2cc2c3", "31a3da", "5e7ac9", "6e68bc",
    "885baf", "724890", 
}

-- originally I was using random colors
-- but they looked shit, so it's not really used anymore
-- leaving it here just in case i want it to look shit again
local function get_random_color()
    local hue = love.math.random()
    local saturation = 0.6
    local value = 0.8

    local function hsv_to_rgb(h, s, v)
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)

        i = i % 6
        if i == 0 then return v, t, p
        elseif i == 1 then return q, v, p
        elseif i == 2 then return p, v, t
        elseif i == 3 then return p, q, v
        elseif i == 4 then return t, p, v
        elseif i == 5 then return v, p, q
        end
    end

    return hsv_to_rgb(hue, saturation, value)
end


function M:new(soundfont_path, driver_name)
    local settings = lib.new_fluid_settings()

    local synth = lib.new_fluid_synth(settings)
    if synth == nil then
        error("Failed to create FluidSynth synthesizer!")
    end

    -- load the audio driver
    local adriver = lib.new_fluid_audio_driver(settings, synth)
    if not adriver then
        error("Failed to create Audio Driver!")
    end

    -- load soundfont
    local full_sf_path = save_path .. "/soundfonts/" .. soundfont_path
    local sfont_id = lib.fluid_synth_sfload(synth, full_sf_path, 1)
    if sfont_id < 0 then
        error("Failed to load SoundFont: " .. full_sf_path)
    end

    -- load a default preset, bank 0, preset 0
    local bank_num = 0
    local preset_num = 0
    lib.fluid_synth_program_select(synth, 0, sfont_id, bank_num, preset_num)

    -- store stuff as instance vars
    self.seq = seq
    self.synth = synth
    self.adriver = adriver
    self.settings = settings
    self.sfont_id = sfont_id
    self.sf_path = full_sf_path
    self.synth_id = lib.fluid_sequencer_register_fluidsynth(self.seq, self.synth)

    -- populate last_event with some random shit
    self.last_event = { "Hello", "World!" }

    self.current_track = 1
    self.bar_width   = 96
    self.bpm = 120
    self.song_time_ms = 0
    self.is_playing = false
    self.loaded_song = false

    -- load all the soundfont presets for convenience
    self.presets = self:list_presets()
    self.tracks = {}
    self:add_track()
end

-- really we're just duplicating a bunch of shit from the constructor (new)
-- maybe I can move all of this into another method that new and load share
function M:load(filename)
    local filename = filename:gsub(" ", "_")
    local content, err = love.filesystem.read("saves/" .. filename .. ".muse")
    if not content then return end
    self.loaded_song = filename
    local data = json.decode(content)
    
    -- cleanup old fluidsynth objects in memory
    self:cleanup()

    local settings = lib.new_fluid_settings()

    local synth = lib.new_fluid_synth(settings)
    if synth == nil then
        error("Failed to create FluidSynth synthesizer!")
    end

    -- create audio driver (real-time output)
     local adriver = lib.new_fluid_audio_driver(settings, synth)
    if not adriver then
        error("Failed to create Audio Driver!")
    end

    local sfont_id = lib.fluid_synth_sfload(synth, data.soundfont_path, 1)
    if sfont_id < 0 then
        error("Failed to load SoundFont: " .. data.soundfont_path)
    end

    -- load a default preset, bank 0, preset 0
    local bank_num = 0
    local preset_num = 0
    lib.fluid_synth_program_select(synth, 0, sfont_id, bank_num, preset_num)

    -- store stuff as instance vars
    self.seq = seq
    self.synth = synth
    self.adriver = adriver
    self.settings = settings
    self.sfont_id = sfont_id
    self.sf_path = data.soundfont_path
    self.synth_id = lib.fluid_sequencer_register_fluidsynth(self.seq, self.synth)

    self.bpm = data.bpm
    self.song_time_ms = 0
    self.is_playing = false
    self.presets = self:list_presets()
    self.tracks = {}
    for _,track in ipairs(data.tracks) do
        local newtrack = self:add_track()
        newtrack.color = track.color
        newtrack.preset = track.preset
        newtrack.name = self:get_preset_name(newtrack.preset)
        newtrack.channel = track.channel
        newtrack.volume = track.volume

        newtrack.cc = {}
        for cc, val in pairs(track.cc) do
            newtrack.cc[tonumber(cc)] = tonumber(val)
        end

        if track.notes then newtrack.notes = track.notes end
        self:change_program(newtrack.channel, self.presets[track.preset].bank_num, self.presets[track.preset].preset_num)
    end
end

local function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[deep_copy(k)] = deep_copy(v)
        end
    else
        copy = orig
    end
    return copy
end

function M:save(filename)
    local tracks = deep_copy(self.tracks) -- deep copy tracks so we're not changing the original

    for _,track in ipairs(tracks) do
        for cc,val in pairs(track.cc) do
            -- convert to string key and store value
            track.cc[tostring(cc)] = val
        end

        -- clear numeric indices
        for cc,_ in pairs(track.cc) do
            if type(cc) == "number" then
                track.cc[cc] = nil
            end
        end
    end

    local save_tbl = {
        bpm = self.bpm,
        -- comes from piano roll and will need to be stored back into piano roll
        num_measures = self.piano_roll.num_measures,
        -- full soundfont path
        soundfont_path = self.sf_path,
        tracks = tracks
    }

    -- replace spaces with underscores
    -- because spaces in filenames are gross
    local filename = filename:gsub(" ", "_")

    love.filesystem.write("saves/" .. filename .. ".muse", json.encode(save_tbl))
end

function M:get_piano_roll(p)
    self.piano_roll = p
end

function M:update(dt)
    tick.update(dt)
    if self.is_playing then
        self.song_time_ms = self.song_time_ms + dt * 1000
        
        -- check if we're past the end
        if self.song_time_ms >= self.total_song_ms then
            -- loop back
            self.song_time_ms = 0

            -- reset note flags so they'll play again
            for _,track in ipairs(self.tracks) do
                if track and track.notes then
                    for _, note in ipairs(track.notes) do
                        note.played_on  = false
                        note.played_off = false
                    end
                end
            end
        end

        -- compute beats to update the playhead
        local beats = self.song_time_ms / (60000 / self.bpm)
        self.piano_roll.playhead_x = beats * self.piano_roll.bar_width

        -- scroll so the playhead remains visible
        self.piano_roll:ensure_playhead_visible()

        -- trigger note_on/note_off
        if self.solo_track then
            local track = self.tracks[self.solo_track]
            if track and track.notes then
                for _, note in ipairs(track.notes) do
                    if not note.played_on and self.song_time_ms >= note.start_time then
                        self:note_on(track.channel, note.pitch, track.volume)
                        note.played_on = true
                    end
                    if not note.played_off and self.song_time_ms >= note.end_time then
                        self:note_off(track.channel, note.pitch)
                        note.played_off = true
                    end
                end
            end
        else
            for _,track in ipairs(self.tracks) do
                if track and track.notes then
                    for _, note in ipairs(track.notes) do
                        if not note.played_on and self.song_time_ms >= note.start_time then
                            self:note_on(track.channel, note.pitch, track.volume)
                            note.played_on = true
                        end
                        if not note.played_off and self.song_time_ms >= note.end_time then
                            self:note_off(track.channel, note.pitch)
                            note.played_off = true
                        end
                    end
                end
            end
        end
    end
end

function M:export_wav(filename)
    local render_settings = lib.new_fluid_settings()
    
    local save_dir = love.filesystem.getSaveDirectory() .. "/exports"
    lib.fluid_settings_setstr(render_settings, "audio.driver", "file")
    lib.fluid_settings_setstr(render_settings, "audio.file.name", save_dir .. "/" .. filename)
    lib.fluid_settings_setstr(render_settings, "audio.file.type", "wav")

    local render_synth = lib.new_fluid_synth(render_settings)
    
    local sfont_id = lib.fluid_synth_sfload(render_synth, self.sf_path, 1)
    if sfont_id < 0 then
        error("Failed to load SoundFont for rendering!")
    end
    
    local render_seq = lib.new_fluid_sequencer2(0)
    local synth_id = lib.fluid_sequencer_register_fluidsynth(render_seq, render_synth)
    
    -- schedule song at absolute times
    for i, track in ipairs(self.tracks) do
        for cc,val in pairs(track.cc) do
            lib.fluid_synth_cc(render_synth, track.channel, cc, val)
        end

        -- select the correct preset
        local bank = self.presets[track.preset].bank_num or 0
        local preset = self.presets[track.preset].preset_num or 0
        lib.fluid_synth_program_select(render_synth, track.channel, sfont_id, bank, preset)

        for _, note in ipairs(track.notes) do

            -- if track has .glide set, schedule portamento CCs just before note-on
            if track.glide then
                -- we offset them 1ms before note.start_time, so the synth 
                -- is already in portamento mode when the noteon arrives
                -- i think this is a good idea? maybe not idk
                local glide_on_time = math.max(0, note.start_time - 1)

                -- enable mono (CC 126)
                local mono_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(mono_evt, -1)
                lib.fluid_event_set_dest(mono_evt, synth_id)
                lib.fluid_event_control_change(mono_evt, track.channel, 126, 1)
                lib.fluid_sequencer_send_at(render_seq, mono_evt, glide_on_time, 1)
                lib.delete_fluid_event(mono_evt)

                -- enable legato (CC 68)
                local legato_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(legato_evt, -1)
                lib.fluid_event_set_dest(legato_evt, synth_id)
                lib.fluid_event_control_change(legato_evt, track.channel, 68, 127)
                lib.fluid_sequencer_send_at(render_seq, legato_evt, glide_on_time, 1)
                lib.delete_fluid_event(legato_evt)

                -- enable portamento (CC 65)
                local porta_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(porta_evt, -1)
                lib.fluid_event_set_dest(porta_evt, synth_id)
                lib.fluid_event_control_change(porta_evt, track.channel, 65, 127)
                lib.fluid_sequencer_send_at(render_seq, porta_evt, glide_on_time, 1)
                lib.delete_fluid_event(porta_evt)

                -- set the portamento time (CC 5)
                -- currently it's set as 2. perhaps I should add this as a track setting
                local time_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(time_evt, -1)
                lib.fluid_event_set_dest(time_evt, synth_id)
                lib.fluid_event_control_change(time_evt, track.channel, 5, 2)
                lib.fluid_sequencer_send_at(render_seq, time_evt, glide_on_time, 1)
                lib.delete_fluid_event(time_evt)
            end

            -- note on
            local on_evt = lib.new_fluid_event()
            lib.fluid_event_set_source(on_evt, -1)
            lib.fluid_event_set_dest(on_evt, synth_id)
            lib.fluid_event_noteon(on_evt, track.channel, note.pitch, track.volume)
            lib.fluid_sequencer_send_at(render_seq, on_evt, note.start_time, 1)
            lib.delete_fluid_event(on_evt)

            -- note off
            local off_evt = lib.new_fluid_event()
            lib.fluid_event_set_source(off_evt, -1)
            lib.fluid_event_set_dest(off_evt, synth_id)
            lib.fluid_event_noteoff(off_evt, track.channel, note.pitch)
            lib.fluid_sequencer_send_at(render_seq, off_evt, note.end_time, 1)
            lib.delete_fluid_event(off_evt)

            -- if track.glide, schedule CCs to turn off portamento right after note-off
            -- we also disable legato and mono
            if track.glide then
                local glide_off_time = note.end_time + 1

                --  mono
                local monooff_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(monooff_evt, -1)
                lib.fluid_event_set_dest(monooff_evt, synth_id)
                lib.fluid_event_control_change(monooff_evt, track.channel, 126, 0)
                lib.fluid_sequencer_send_at(render_seq, monooff_evt, glide_off_time, 1)
                lib.delete_fluid_event(monooff_evt)

                -- portamento
                local portoff_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(portoff_evt, -1)
                lib.fluid_event_set_dest(portoff_evt, synth_id)
                lib.fluid_event_control_change(portoff_evt, track.channel, 65, 0)
                lib.fluid_sequencer_send_at(render_seq, portoff_evt, glide_off_time, 1)
                lib.delete_fluid_event(portoff_evt)

                -- legato
                local legatooff_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(legatooff_evt, -1)
                lib.fluid_event_set_dest(legatooff_evt, synth_id)
                lib.fluid_event_control_change(legatooff_evt, track.channel, 68, 0)
                lib.fluid_sequencer_send_at(render_seq, legatooff_evt, glide_off_time, 1)
                lib.delete_fluid_event(legatooff_evt)

                -- midi cc 121 resets controllers
                -- I'm not 100% sure if we need to do this, but I think it works so
                -- will leave it in for now
                local reset_evt = lib.new_fluid_event()
                lib.fluid_event_set_source(reset_evt, -1)
                lib.fluid_event_set_dest(reset_evt, synth_id)
                lib.fluid_event_control_change(reset_evt, track.channel, 121, 0)
                lib.fluid_sequencer_send_at(render_seq, reset_evt, glide_off_time, 1)
                lib.delete_fluid_event(reset_evt)
            end

        end
    end
    
    -- create file renderer for offline rendering
    local file_renderer = lib.new_fluid_file_renderer(render_synth)
    if file_renderer == nil then
        error("Failed to create file renderer")
    end
    
    -- process audio blocks offline
    local block_size = 64  -- or 1024, etc.
    local sample_rate = 44100  -- match your real-time or pick a standard

    -- total_length_ms = last note's end_time + some tail
    local total_length_ms = 0
    for _, track in ipairs(self.tracks) do
        for _, note in ipairs(track.notes) do
            if note.end_time > total_length_ms then
                total_length_ms = note.end_time
            end
        end
    end

    total_length_ms = total_length_ms + 2000  -- give it some tail
    
    local current_ms = 0
    while current_ms < total_length_ms do
        local ms_per_block = (block_size / sample_rate) * 1000
        
        -- advance the sequencer by ms_per_block
        lib.fluid_sequencer_process(render_seq, math.floor(ms_per_block + 0.5))
        local keep_going = lib.fluid_file_renderer_process_block(file_renderer)
        
        current_ms = current_ms + ms_per_block
    end
    
    -- finally, clean up our mess
    lib.delete_fluid_file_renderer(file_renderer)
    lib.delete_fluid_sequencer(render_seq)
    lib.delete_fluid_synth(render_synth)
    lib.delete_fluid_settings(render_settings)
    
    print("WAV export done => " .. filename)
end


function M:preview_note(note)
    self:note_on(self.current_track, note, self.tracks[self.current_track].volume)
    tick.delay(function()
        self:note_off(self.current_track, note)
    end, 0.1)
end

function M:generate_note_times(track_num)
    local track = self.tracks[track_num]
    if not track.notes then return end

    local ms_per_beat = 60000 / self.bpm

    for _, note in ipairs(track.notes) do
        local start_beat = note.x / self.bar_width
        local duration_beat = note.width / self.bar_width

        note.start_time = start_beat * ms_per_beat
        note.end_time   = note.start_time + (duration_beat * ms_per_beat)
        
        -- this seems hinky but works
        note.pitch = 95 - note.row
    end
end

function M:next_preset(track_id)
    local track = self.tracks[track_id]
    track.preset = track.preset + 1
    if track.preset > #self.presets then
        track.preset = 1
    end

    if self.presets[track.preset] then
        self:change_program(track_id, self.presets[track.preset].bank_num, self.presets[track.preset].preset_num)
        track.name = self:get_preset_name(track.preset)
    end
end

function M:prev_preset(track_id)
    local track = self.tracks[track_id]
    track.preset = track.preset - 1
    if track.preset < 1 then
        track.preset = #self.presets
    end

    if self.presets[track.preset] then
        self:change_program(track_id, self.presets[track.preset].bank_num, self.presets[track.preset].preset_num)
        track.name = self:get_preset_name(track.preset)
    end
end

function M:start_playback_from_playhead()
    -- assuming 4/4 time
    local total_beats = self.piano_roll.num_measures * 4
    local ms_per_beat = 60000 / self.bpm
    self.total_song_ms = total_beats * ms_per_beat
    -- convert playhead_x from pixels to beats, then from beats to ms
    -- fun.
    local beats = self.piano_roll.playhead_x / self.piano_roll.bar_width
    local ms = beats * (60000 / self.bpm)

    self.song_time_ms = ms

    for i,track in ipairs(self.tracks) do
        self:generate_note_times(i)

        if track and track.notes then
            for _, n in ipairs(track.notes) do
                if n.start_time < self.song_time_ms then
                    n.played_on = true

                    if n.end_time and n.end_time < self.song_time_ms then
                        n.played_off = true
                    else
                        n.played_off = false
                    end
                else
                    n.played_on  = false
                    n.played_off = false
                end
            end
        end
    end

    self.is_playing = true
end

function M:start_playback(track_num)
    self:generate_note_times(track_num)

    self.song_time_ms = 0

    local track = self.tracks[track_num]
    if track and track.notes then
        for _, n in ipairs(track.notes) do
            n.played_on  = false
            n.played_off = false
        end
    end

    self.current_track = track_num
    self.is_playing = true
end

function M:stop_playback()
    self.is_playing = false
    self:all_notes_off()
end
function M:get_track_color()
    return self.tracks[self.current_track].color
end

function M:get_preset_name(n)
    local name = self.presets[n].name
    if #name > 12 then
        name = name:sub(1, 12) .. "..."
    end

    return name
end

function M:add_track()
    last_col = last_col + 1
    if last_col > #track_colors then
        last_col = 1
    end

    local channel = #self.tracks + 1
    self.tracks[channel] = {
        channel = channel,
        volume = 127,
        preset = 1,
        glide = false,
        name = self:get_preset_name(1),
        color = hex_to_color(track_colors[last_col]),
        cc = {
            [91] = 0, -- reverb
            [7]  = 127, -- volume
            [10] = 64, -- pan
        }
    }

    self.current_track = channel

    for cc,val in pairs(self.tracks[channel].cc) do
        self:cc(channel, cc, val)
    end

    return self.tracks[channel]
end

function M:set_portamento(track_id)
    self.tracks[track_id].glide = true
    self:cc(track_id, 1, 127)
    self.last_event = { "set_portamento", self.tracks[track_id].name }
end

function M:cc(track_id, cc, val)
    -- clamp value to 127 as that's as high as it goes (that I'm aware of)
    lib.fluid_synth_cc(self.synth, track_id, cc, math.min(val, 127))
    self.tracks[track_id].cc[cc] = val
end

-- change the current preset on a given channel/track
function M:change_program(channel, bank_num, preset_num)
    local ret = lib.fluid_synth_program_select(self.synth, channel, self.sfont_id, bank_num, preset_num)
    if ret == -1 then
        error("Could not change program to bank=" .. bank_num .. " preset=" .. preset_num)
    end

    self.last_event = { "prgm_change", "Bank: " .. bank_num .. ", Preset: " .. preset_num}
end

-- retrieves a table of all the presets in the soundfont
function M:list_presets()
    local sfont = lib.fluid_synth_get_sfont_by_id(self.synth, self.sfont_id)
    if sfont == nil then
        error("No SoundFont found with ID " .. tostring(self.sfont_id))
    end

    lib.fluid_sfont_iteration_start(sfont)

    local instruments = {}
    while true do
        local preset = lib.fluid_sfont_iteration_next(sfont)
        if preset == nil or preset == ffi.NULL then
            break
        end
        local bank = lib.fluid_preset_get_banknum(preset)
        local prog = lib.fluid_preset_get_num(preset)
        local name = ffi.string(lib.fluid_preset_get_name(preset))

        table.insert(instruments, {
            name = name,
            bank_num = bank,
            preset_num = prog
        })

        -- since fluid_sfont_iteration_next() returns a "fluid_preset_t*"
        -- that belongs to the sfont, don't delete it here, as much as it "makes sense" to.
        -- so I can call delete_fluid_preset(fluid_preset_t*) but it may seg fault later on
        -- fuck working with memory
    end

    return instruments
end

function M:toggle_solo(track_id)
    -- if solo track is already the specified track_id
    -- then remove the solo flag
    if self.solo_track and self.solo_track == track_id then
        self.solo_track = false
        return
    end

    self.solo_track = track_id
end

-- triggers a MIDI note-on
function M:note_on(channel, key, vel)
    if not self.synth then return end

    if self.tracks[channel].glide then
        self:cc(channel, 126, 1) -- Mono Mode On
        self:cc(channel, 68, 127)
        self:cc(channel, 65, 127)
        self:cc(channel, 5, 2)
    end

    local channel = channel or 0
    local key     = key or 60   -- Middle C
    local vel     = vel or 100
    lib.fluid_synth_noteon(self.synth, channel, key, vel)
end

-- triggers a MIDI note-off
function M:note_off(channel, key)
    if not self.synth then return end

    if self.tracks[channel].glide then
        self:cc(channel, 126, 0)
        self:cc(channel, 65, 0)
        self:cc(channel, 68, 0)
        self:cc(channel, 121, 0)
    end
    local channel = channel or 0
    local key     = key or 60
    lib.fluid_synth_noteoff(self.synth, channel, key)
end

-- turns off all notes on the track
function M:all_notes_off()
    for _,track in ipairs(self.tracks) do
        lib.fluid_synth_all_notes_off(self.synth, track.channel)
    end
end

-- should be called with love.quit
-- frees all the gunk left behind
function M:cleanup()
    if self.adriver then
        lib.delete_fluid_audio_driver(self.adriver)
        self.adriver = nil
        print("Cleaned up Audio Driver")
    end
    if self.synth then
        lib.delete_fluid_synth(self.synth)
        self.synth = nil
        print("Cleaned up Synth")
    end
    if self.settings then
        lib.delete_fluid_settings(self.settings)
        self.settings = nil
        print("Cleaned up Settings")
    end
end

return M
