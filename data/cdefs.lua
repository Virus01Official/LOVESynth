return [[
typedef struct _fluid_hashtable_t fluid_settings_t;             /**< Configuration settings instance */
typedef struct _fluid_synth_t fluid_synth_t;                    /**< Synthesizer instance */
typedef struct _fluid_voice_t fluid_voice_t;                    /**< Synthesis voice instance */
typedef struct _fluid_sfloader_t fluid_sfloader_t;              /**< SoundFont loader plugin */
typedef struct _fluid_sfont_t fluid_sfont_t;                    /**< SoundFont */
typedef struct _fluid_preset_t fluid_preset_t;                  /**< SoundFont preset */
typedef struct _fluid_sample_t fluid_sample_t;                  /**< SoundFont sample */
typedef struct _fluid_mod_t fluid_mod_t;                        /**< SoundFont modulator */
typedef struct _fluid_audio_driver_t fluid_audio_driver_t;      /**< Audio driver instance */
typedef struct _fluid_file_renderer_t fluid_file_renderer_t;    /**< Audio file renderer instance */
typedef struct _fluid_player_t fluid_player_t;                  /**< MIDI player instance */
typedef struct _fluid_midi_event_t fluid_midi_event_t;          /**< MIDI event */
typedef struct _fluid_midi_driver_t fluid_midi_driver_t;        /**< MIDI driver instance */
typedef struct _fluid_midi_router_t fluid_midi_router_t;        /**< MIDI router instance */
typedef struct _fluid_midi_router_rule_t fluid_midi_router_rule_t;      /**< MIDI router rule */
typedef struct _fluid_hashtable_t fluid_cmd_hash_t;             /**< Command handler hash table */
typedef struct _fluid_shell_t fluid_shell_t;                    /**< Command shell */
typedef struct _fluid_server_t fluid_server_t;                  /**< TCP/IP shell server instance */
typedef struct _fluid_event_t fluid_event_t;                    /**< Sequencer event */
typedef struct _fluid_sequencer_t fluid_sequencer_t;            /**< Sequencer instance */
typedef struct _fluid_ramsfont_t fluid_ramsfont_t;              /**< RAM SoundFont */
typedef struct _fluid_rampreset_t fluid_rampreset_t;            /**< RAM SoundFont preset */
typedef struct _fluid_cmd_handler_t fluid_cmd_handler_t;        /**< Shell Command Handler */
typedef struct _fluid_ladspa_fx_t fluid_ladspa_fx_t;            /**< LADSPA effects instance */
typedef struct _fluid_file_callbacks_t fluid_file_callbacks_t;  /**< Callback struct to perform custom file loading of soundfonts */
typedef int fluid_istream_t;    /**< Input stream descriptor */
typedef int fluid_ostream_t;    /**< Output stream descriptor */

typedef short fluid_seq_id_t; /**< Unique client IDs used by the sequencer and #fluid_event_t, obtained by fluid_sequencer_register_client() and fluid_sequencer_register_fluidsynth() */

/**
#if defined(_MSC_VER) && (_MSC_VER < 1800)
typedef __int64 fluid_long_long_t; // even on 32bit windows
#else
typedef long long fluid_long_long_t;
#endif
*/

fluid_synth_t *new_fluid_synth(fluid_settings_t *settings);
void delete_fluid_synth(fluid_synth_t *synth);
double fluid_synth_get_cpu_load(fluid_synth_t *synth);
int fluid_synth_noteon(fluid_synth_t *synth, int chan, int key, int vel);
int fluid_synth_noteoff(fluid_synth_t *synth, int chan, int key);
int fluid_synth_cc(fluid_synth_t *synth, int chan, int ctrl, int val);
int fluid_synth_get_cc(fluid_synth_t *synth, int chan, int ctrl, int *pval);
int fluid_synth_sysex(fluid_synth_t *synth, const char *data, int len, char *response, int *response_len, int *handled, int dryrun);
int fluid_synth_pitch_bend(fluid_synth_t *synth, int chan, int val);
int fluid_synth_get_pitch_bend(fluid_synth_t *synth, int chan, int *ppitch_bend);
int fluid_synth_pitch_wheel_sens(fluid_synth_t *synth, int chan, int val);
int fluid_synth_get_pitch_wheel_sens(fluid_synth_t *synth, int chan, int *pval);
int fluid_synth_program_change(fluid_synth_t *synth, int chan, int program);
int fluid_synth_channel_pressure(fluid_synth_t *synth, int chan, int val);
int fluid_synth_key_pressure(fluid_synth_t *synth, int chan, int key, int val);
int fluid_synth_bank_select(fluid_synth_t *synth, int chan, int bank);
int fluid_synth_sfont_select(fluid_synth_t *synth, int chan, int sfont_id);
int fluid_synth_program_select(fluid_synth_t *synth, int chan, int sfont_id,
                               int bank_num, int preset_num);
int fluid_synth_program_select_by_sfont_name(fluid_synth_t *synth, int chan,
        const char *sfont_name, int bank_num,
        int preset_num);
int fluid_synth_get_program(fluid_synth_t *synth, int chan, int *sfont_id,
                            int *bank_num, int *preset_num);
int fluid_synth_unset_program(fluid_synth_t *synth, int chan);
int fluid_synth_program_reset(fluid_synth_t *synth);
int fluid_synth_system_reset(fluid_synth_t *synth);
int fluid_synth_all_notes_off(fluid_synth_t *synth, int chan);
int fluid_synth_all_sounds_off(fluid_synth_t *synth, int chan);
int fluid_synth_set_gen(fluid_synth_t *synth, int chan, int param, float value);
float fluid_synth_get_gen(fluid_synth_t *synth, int chan, int param);
int fluid_synth_start(fluid_synth_t *synth, unsigned int id,
                                     fluid_preset_t *preset, int audio_chan,
                                     int midi_chan, int key, int vel);
int fluid_synth_stop(fluid_synth_t *synth, unsigned int id);
fluid_voice_t *fluid_synth_alloc_voice(fluid_synth_t *synth,
        fluid_sample_t *sample,
        int channum, int key, int vel);
void fluid_synth_start_voice(fluid_synth_t *synth, fluid_voice_t *voice);
void fluid_synth_get_voicelist(fluid_synth_t *synth, fluid_voice_t *buf[], int bufsize, int ID);
int fluid_synth_sfload(fluid_synth_t *synth, const char *filename, int reset_presets);
int fluid_synth_sfreload(fluid_synth_t *synth, int id);
int fluid_synth_sfunload(fluid_synth_t *synth, int id, int reset_presets);
int fluid_synth_add_sfont(fluid_synth_t *synth, fluid_sfont_t *sfont);
int fluid_synth_remove_sfont(fluid_synth_t *synth, fluid_sfont_t *sfont);
int fluid_synth_sfcount(fluid_synth_t *synth);
fluid_sfont_t *fluid_synth_get_sfont(fluid_synth_t *synth, unsigned int num);
fluid_sfont_t *fluid_synth_get_sfont_by_id(fluid_synth_t *synth, int id);
fluid_sfont_t *fluid_synth_get_sfont_by_name(fluid_synth_t *synth,
        const char *name);
int fluid_synth_set_bank_offset(fluid_synth_t *synth, int sfont_id, int offset);
int fluid_synth_get_bank_offset(fluid_synth_t *synth, int sfont_id);
void fluid_synth_set_reverb_on(fluid_synth_t *synth, int on);
int fluid_synth_set_reverb(fluid_synth_t *synth, double roomsize,
        double damping, double width, double level);
int fluid_synth_reverb_on(fluid_synth_t *synth, int fx_group, int on);
int fluid_synth_set_reverb_group_roomsize(fluid_synth_t *synth, int fx_group, double roomsize);
int fluid_synth_set_reverb_group_damp(fluid_synth_t *synth, int fx_group, double damping);
int fluid_synth_set_reverb_group_width(fluid_synth_t *synth, int fx_group, double width);
int fluid_synth_set_reverb_group_level(fluid_synth_t *synth, int fx_group, double level);

int fluid_synth_get_reverb_group_roomsize(fluid_synth_t *synth, int fx_group, double *roomsize);
int fluid_synth_get_reverb_group_damp(fluid_synth_t *synth, int fx_group, double *damping);
int fluid_synth_get_reverb_group_width(fluid_synth_t *synth, int fx_group, double *width);
int fluid_synth_get_reverb_group_level(fluid_synth_t *synth, int fx_group, double *level);

int fluid_synth_chorus_on(fluid_synth_t *synth, int fx_group, int on);

int fluid_synth_set_chorus_group_nr(fluid_synth_t *synth, int fx_group, int nr);
int fluid_synth_set_chorus_group_level(fluid_synth_t *synth, int fx_group, double level);
int fluid_synth_set_chorus_group_speed(fluid_synth_t *synth, int fx_group, double speed);
int fluid_synth_set_chorus_group_depth(fluid_synth_t *synth, int fx_group, double depth_ms);
int fluid_synth_set_chorus_group_type(fluid_synth_t *synth, int fx_group, int type);

int fluid_synth_get_chorus_group_nr(fluid_synth_t *synth, int fx_group, int *nr);
int fluid_synth_get_chorus_group_level(fluid_synth_t *synth, int fx_group, double *level);
int fluid_synth_get_chorus_group_speed(fluid_synth_t *synth, int fx_group, double *speed);
int fluid_synth_get_chorus_group_depth(fluid_synth_t *synth, int fx_group, double *depth_ms);
int fluid_synth_get_chorus_group_type(fluid_synth_t *synth, int fx_group, int *type);

int fluid_synth_count_midi_channels(fluid_synth_t *synth);
int fluid_synth_count_audio_channels(fluid_synth_t *synth);
int fluid_synth_count_audio_groups(fluid_synth_t *synth);
int fluid_synth_count_effects_channels(fluid_synth_t *synth);
int fluid_synth_count_effects_groups(fluid_synth_t *synth);

void fluid_synth_set_gain(fluid_synth_t *synth, float gain);
float fluid_synth_get_gain(fluid_synth_t *synth);
int fluid_synth_set_polyphony(fluid_synth_t *synth, int polyphony);
int fluid_synth_get_polyphony(fluid_synth_t *synth);
int fluid_synth_get_active_voice_count(fluid_synth_t *synth);
int fluid_synth_get_internal_bufsize(fluid_synth_t *synth);

int fluid_synth_set_interp_method(fluid_synth_t *synth, int chan, int interp_method);

int fluid_synth_add_default_mod(fluid_synth_t *synth, const fluid_mod_t *mod, int mode);
int fluid_synth_remove_default_mod(fluid_synth_t *synth, const fluid_mod_t *mod);

int fluid_synth_activate_key_tuning(fluid_synth_t *synth, int bank, int prog,
                                    const char *name, const double *pitch, int apply);
int fluid_synth_activate_octave_tuning(fluid_synth_t *synth, int bank, int prog,
                                       const char *name, const double *pitch, int apply);
int fluid_synth_tune_notes(fluid_synth_t *synth, int bank, int prog,
                           int len, const int *keys, const double *pitch, int apply);
int fluid_synth_activate_tuning(fluid_synth_t *synth, int chan, int bank, int prog,
                                int apply);
int fluid_synth_deactivate_tuning(fluid_synth_t *synth, int chan, int apply);
void fluid_synth_tuning_iteration_start(fluid_synth_t *synth);
int fluid_synth_tuning_iteration_next(fluid_synth_t *synth, int *bank, int *prog);
int fluid_synth_tuning_dump(fluid_synth_t *synth, int bank, int prog,
        char *name, int len, double *pitch);

int fluid_synth_write_s16(fluid_synth_t *synth, int len,
        void *lout, int loff, int lincr,
        void *rout, int roff, int rincr);
int fluid_synth_write_float(fluid_synth_t *synth, int len,
        void *lout, int loff, int lincr,
        void *rout, int roff, int rincr);
int fluid_synth_process(fluid_synth_t *synth, int len,
                                       int nfx, float *fx[],
                                       int nout, float *out[]);

int fluid_synth_set_custom_filter(fluid_synth_t *, int type, int flags);

int fluid_synth_reset_basic_channel(fluid_synth_t *synth, int chan);
int  fluid_synth_get_basic_channel(fluid_synth_t *synth, int chan,
        int *basic_chan_out,
        int *mode_chan_out,
        int *basic_val_out);
int fluid_synth_set_basic_channel(fluid_synth_t *synth, int chan, int mode, int val);
int fluid_synth_set_legato_mode(fluid_synth_t *synth, int chan, int legatomode);
int fluid_synth_get_legato_mode(fluid_synth_t *synth, int chan, int  *legatomode);

int fluid_synth_set_portamento_mode(fluid_synth_t *synth,
        int chan, int portamentomode);
int fluid_synth_get_portamento_mode(fluid_synth_t *synth,
        int chan, int   *portamentomode);

int fluid_synth_set_breath_mode(fluid_synth_t *synth,
        int chan, int breathmode);
int fluid_synth_get_breath_mode(fluid_synth_t *synth,
        int chan, int  *breathmode);

fluid_settings_t *fluid_synth_get_settings(fluid_synth_t *synth);
void fluid_synth_add_sfloader(fluid_synth_t *synth, fluid_sfloader_t *loader);
fluid_preset_t *fluid_synth_get_channel_preset(fluid_synth_t *synth, int chan);
int fluid_synth_handle_midi_event(void *data, fluid_midi_event_t *event);
int fluid_synth_pin_preset(fluid_synth_t *synth, int sfont_id, int bank_num, int preset_num);
int fluid_synth_unpin_preset(fluid_synth_t *synth, int sfont_id, int bank_num, int preset_num);
fluid_ladspa_fx_t *fluid_synth_get_ladspa_fx(fluid_synth_t *synth);

typedef fluid_sfont_t *(*fluid_sfloader_load_t)(fluid_sfloader_t *loader, const char *filename);
typedef void (*fluid_sfloader_free_t)(fluid_sfloader_t *loader);

typedef __int64 fluid_long_long_t;
fluid_sfloader_t *new_fluid_sfloader(fluid_sfloader_load_t load, fluid_sfloader_free_t free);
void delete_fluid_sfloader(fluid_sfloader_t *loader);
fluid_sfloader_t *new_fluid_defsfloader(fluid_settings_t *settings);
typedef void *(* fluid_sfloader_callback_open_t)(const char *filename);
typedef int (* fluid_sfloader_callback_read_t)(void *buf, fluid_long_long_t count, void *handle);
typedef int (* fluid_sfloader_callback_seek_t)(void *handle, fluid_long_long_t offset, int origin);
typedef int (* fluid_sfloader_callback_close_t)(void *handle);
typedef fluid_long_long_t (* fluid_sfloader_callback_tell_t)(void *handle);
int fluid_sfloader_set_callbacks(fluid_sfloader_t *loader,
        fluid_sfloader_callback_open_t open,
        fluid_sfloader_callback_read_t read,
        fluid_sfloader_callback_seek_t seek,
        fluid_sfloader_callback_tell_t tell,
        fluid_sfloader_callback_close_t close);

int fluid_sfloader_set_data(fluid_sfloader_t *loader, void *data);
void *fluid_sfloader_get_data(fluid_sfloader_t *loader);
typedef const char *(*fluid_sfont_get_name_t)(fluid_sfont_t *sfont);
typedef fluid_preset_t *(*fluid_sfont_get_preset_t)(fluid_sfont_t *sfont, int bank, int prenum);
typedef void (*fluid_sfont_iteration_start_t)(fluid_sfont_t *sfont);
typedef fluid_preset_t *(*fluid_sfont_iteration_next_t)(fluid_sfont_t *sfont);
typedef int (*fluid_sfont_free_t)(fluid_sfont_t *sfont);

fluid_sfont_t *new_fluid_sfont(fluid_sfont_get_name_t get_name,
        fluid_sfont_get_preset_t get_preset,
        fluid_sfont_iteration_start_t iter_start,
        fluid_sfont_iteration_next_t iter_next,
        fluid_sfont_free_t free);

int delete_fluid_sfont(fluid_sfont_t *sfont);

int fluid_sfont_set_data(fluid_sfont_t *sfont, void *data);
void *fluid_sfont_get_data(fluid_sfont_t *sfont);

int fluid_sfont_get_id(fluid_sfont_t *sfont);
const char *fluid_sfont_get_name(fluid_sfont_t *sfont);
fluid_preset_t *fluid_sfont_get_preset(fluid_sfont_t *sfont, int bank, int prenum);
void fluid_sfont_iteration_start(fluid_sfont_t *sfont);
fluid_preset_t *fluid_sfont_iteration_next(fluid_sfont_t *sfont);

typedef const char *(*fluid_preset_get_name_t)(fluid_preset_t *preset);
typedef int (*fluid_preset_get_banknum_t)(fluid_preset_t *preset);
typedef int (*fluid_preset_get_num_t)(fluid_preset_t *preset);
typedef int (*fluid_preset_noteon_t)(fluid_preset_t *preset, fluid_synth_t *synth, int chan, int key, int vel);
typedef void (*fluid_preset_free_t)(fluid_preset_t *preset);

fluid_preset_t *new_fluid_preset(fluid_sfont_t *parent_sfont,
        fluid_preset_get_name_t get_name,
        fluid_preset_get_banknum_t get_bank,
        fluid_preset_get_num_t get_num,
        fluid_preset_noteon_t noteon,
        fluid_preset_free_t free);
void delete_fluid_preset(fluid_preset_t *preset);

int fluid_preset_set_data(fluid_preset_t *preset, void *data);
void *fluid_preset_get_data(fluid_preset_t *preset);

const char *fluid_preset_get_name(fluid_preset_t *preset);
int fluid_preset_get_banknum(fluid_preset_t *preset);
int fluid_preset_get_num(fluid_preset_t *preset);
fluid_sfont_t *fluid_preset_get_sfont(fluid_preset_t *preset);

fluid_sample_t *new_fluid_sample(void);
void delete_fluid_sample(fluid_sample_t *sample);

size_t fluid_sample_sizeof(void);

int fluid_sample_set_name(fluid_sample_t *sample, const char *name);
int fluid_sample_set_sound_data(fluid_sample_t *sample,
        short *data,
        char *data24,
        unsigned int nbframes,
        unsigned int sample_rate,
        short copy_data);

int fluid_sample_set_loop(fluid_sample_t *sample, unsigned int loop_start, unsigned int loop_end);
int fluid_sample_set_pitch(fluid_sample_t *sample, int root_key, int fine_tune);

fluid_settings_t *new_fluid_settings(void);
void delete_fluid_settings(fluid_settings_t *settings);
int fluid_settings_get_type(fluid_settings_t *settings, const char *name);
int fluid_settings_get_hints(fluid_settings_t *settings, const char *name, int *val);
int fluid_settings_is_realtime(fluid_settings_t *settings, const char *name);
int fluid_settings_setstr(fluid_settings_t *settings, const char *name, const char *str);
int fluid_settings_copystr(fluid_settings_t *settings, const char *name, char *str, int len);
int fluid_settings_dupstr(fluid_settings_t *settings, const char *name, char **str);
int fluid_settings_getstr_default(fluid_settings_t *settings, const char *name, char **def);
int fluid_settings_str_equal(fluid_settings_t *settings, const char *name, const char *value);
int fluid_settings_setnum(fluid_settings_t *settings, const char *name, double val);
int fluid_settings_getnum(fluid_settings_t *settings, const char *name, double *val);
int fluid_settings_getnum_default(fluid_settings_t *settings, const char *name, double *val);
int fluid_settings_getnum_range(fluid_settings_t *settings, const char *name,
                                double *min, double *max);
int fluid_settings_setint(fluid_settings_t *settings, const char *name, int val);
int fluid_settings_getint(fluid_settings_t *settings, const char *name, int *val);
int fluid_settings_getint_default(fluid_settings_t *settings, const char *name, int *val);
int fluid_settings_getint_range(fluid_settings_t *settings, const char *name,
                                int *min, int *max);

typedef void (*fluid_settings_foreach_option_t)(void *data, const char *name, const char *option);

void fluid_settings_foreach_option(fluid_settings_t *settings,
                                   const char *name, void *data,
                                   fluid_settings_foreach_option_t func);
int fluid_settings_option_count(fluid_settings_t *settings, const char *name);
char *fluid_settings_option_concat(fluid_settings_t *settings,
        const char *name,
        const char *separator);
typedef void (*fluid_settings_foreach_t)(void *data, const char *name, int type);

void fluid_settings_foreach(fluid_settings_t *settings, void *data,
                            fluid_settings_foreach_t func);

typedef int (*fluid_audio_func_t)(void *data, int len,
                                  int nfx, float *fx[],
                                  int nout, float *out[]);


fluid_audio_driver_t *new_fluid_audio_driver(fluid_settings_t *settings,
        fluid_synth_t *synth);

fluid_audio_driver_t *new_fluid_audio_driver2(fluid_settings_t *settings,
        fluid_audio_func_t func,
        void *data);

void delete_fluid_audio_driver(fluid_audio_driver_t *driver);
int fluid_audio_driver_register(const char **adrivers);
fluid_file_renderer_t *new_fluid_file_renderer(fluid_synth_t *synth);
void delete_fluid_file_renderer(fluid_file_renderer_t *dev);

int fluid_file_renderer_process_block(fluid_file_renderer_t *dev);
int fluid_file_set_encoding_quality(fluid_file_renderer_t *dev, double q);

typedef int (*handle_midi_event_func_t)(void *data, fluid_midi_event_t *event);
typedef int (*handle_midi_tick_func_t)(void *data, int tick);

fluid_midi_event_t *new_fluid_midi_event(void);
void delete_fluid_midi_event(fluid_midi_event_t *event);

int fluid_midi_event_set_type(fluid_midi_event_t *evt, int type);
int fluid_midi_event_get_type(const fluid_midi_event_t *evt);
int fluid_midi_event_set_channel(fluid_midi_event_t *evt, int chan);
int fluid_midi_event_get_channel(const fluid_midi_event_t *evt);
int fluid_midi_event_get_key(const fluid_midi_event_t *evt);
int fluid_midi_event_set_key(fluid_midi_event_t *evt, int key);
int fluid_midi_event_get_velocity(const fluid_midi_event_t *evt);
int fluid_midi_event_set_velocity(fluid_midi_event_t *evt, int vel);
int fluid_midi_event_get_control(const fluid_midi_event_t *evt);
int fluid_midi_event_set_control(fluid_midi_event_t *evt, int ctrl);
int fluid_midi_event_get_value(const fluid_midi_event_t *evt);
int fluid_midi_event_set_value(fluid_midi_event_t *evt, int val);
int fluid_midi_event_get_program(const fluid_midi_event_t *evt);
int fluid_midi_event_set_program(fluid_midi_event_t *evt, int val);
int fluid_midi_event_get_pitch(const fluid_midi_event_t *evt);
int fluid_midi_event_set_pitch(fluid_midi_event_t *evt, int val);
int fluid_midi_event_set_sysex(fluid_midi_event_t *evt, void *data,
        int size, int dynamic);
int fluid_midi_event_set_text(fluid_midi_event_t *evt,
        void *data, int size, int dynamic);
int fluid_midi_event_get_text(fluid_midi_event_t *evt,
        void **data, int *size);
int fluid_midi_event_set_lyrics(fluid_midi_event_t *evt,
        void *data, int size, int dynamic);
int fluid_midi_event_get_lyrics(fluid_midi_event_t *evt,
        void **data, int *size);

typedef enum
{
    FLUID_MIDI_ROUTER_RULE_NOTE,                  /**< MIDI note rule */
    FLUID_MIDI_ROUTER_RULE_CC,                    /**< MIDI controller rule */
    FLUID_MIDI_ROUTER_RULE_PROG_CHANGE,           /**< MIDI program change rule */
    FLUID_MIDI_ROUTER_RULE_PITCH_BEND,            /**< MIDI pitch bend rule */
    FLUID_MIDI_ROUTER_RULE_CHANNEL_PRESSURE,      /**< MIDI channel pressure rule */
    FLUID_MIDI_ROUTER_RULE_KEY_PRESSURE,          /**< MIDI key pressure rule */
    FLUID_MIDI_ROUTER_RULE_COUNT                  /**< @internal Total count of rule types. This symbol
                                                    is not part of the public API and ABI stability
                                                    guarantee and may change at any time!*/
} fluid_midi_router_rule_type;


/** @startlifecycle{MIDI Router} */
fluid_midi_router_t *new_fluid_midi_router(fluid_settings_t *settings,
        handle_midi_event_func_t handler,
        void *event_handler_data);
void delete_fluid_midi_router(fluid_midi_router_t *handler);
/** @endlifecycle */

int fluid_midi_router_set_default_rules(fluid_midi_router_t *router);
int fluid_midi_router_clear_rules(fluid_midi_router_t *router);
int fluid_midi_router_add_rule(fluid_midi_router_t *router,
        fluid_midi_router_rule_t *rule, int type);


/** @startlifecycle{MIDI Router Rule} */
fluid_midi_router_rule_t *new_fluid_midi_router_rule(void);
void delete_fluid_midi_router_rule(fluid_midi_router_rule_t *rule);
/** @endlifecycle */

void fluid_midi_router_rule_set_chan(fluid_midi_router_rule_t *rule,
        int min, int max, float mul, int add);
void fluid_midi_router_rule_set_param1(fluid_midi_router_rule_t *rule,
        int min, int max, float mul, int add);
void fluid_midi_router_rule_set_param2(fluid_midi_router_rule_t *rule,
        int min, int max, float mul, int add);
int fluid_midi_router_handle_midi_event(void *data, fluid_midi_event_t *event);
int fluid_midi_dump_prerouter(void *data, fluid_midi_event_t *event);
int fluid_midi_dump_postrouter(void *data, fluid_midi_event_t *event);

fluid_midi_driver_t *new_fluid_midi_driver(fluid_settings_t *settings,
        handle_midi_event_func_t handler,
        void *event_handler_data);
void delete_fluid_midi_driver(fluid_midi_driver_t *driver);

enum fluid_player_status
{
    FLUID_PLAYER_READY,           /**< Player is ready */
    FLUID_PLAYER_PLAYING,         /**< Player is currently playing */
    FLUID_PLAYER_STOPPING,        /**< Player is stopping, but hasn't finished yet (currently unused) */
    FLUID_PLAYER_DONE             /**< Player is finished playing */
};

/**
 * MIDI File Player tempo enum.
 * @since 2.2.0
 */
enum fluid_player_set_tempo_type
{
    FLUID_PLAYER_TEMPO_INTERNAL,      /**< Use midi file tempo set in midi file (120 bpm by default). Multiplied by a factor */
    FLUID_PLAYER_TEMPO_EXTERNAL_BPM,  /**< Set player tempo in bpm, supersede midi file tempo */
    FLUID_PLAYER_TEMPO_EXTERNAL_MIDI, /**< Set player tempo in us per quarter note, supersede midi file tempo */
    FLUID_PLAYER_TEMPO_NBR        /**< @internal Value defines the count of player tempo type (#fluid_player_set_tempo_type) @warning This symbol is not part of the public API and ABI stability guarantee and may change at any time! */
};

/** @startlifecycle{MIDI File Player} */
fluid_player_t *new_fluid_player(fluid_synth_t *synth);
void delete_fluid_player(fluid_player_t *player);
/** @endlifecycle */

int fluid_player_add(fluid_player_t *player, const char *midifile);
int fluid_player_add_mem(fluid_player_t *player, const void *buffer, size_t len);
int fluid_player_play(fluid_player_t *player);
int fluid_player_stop(fluid_player_t *player);
int fluid_player_join(fluid_player_t *player);
int fluid_player_set_loop(fluid_player_t *player, int loop);
int fluid_player_set_tempo(fluid_player_t *player, int tempo_type, double tempo);
int fluid_player_set_midi_tempo(fluid_player_t *player, int tempo);
int fluid_player_set_bpm(fluid_player_t *player, int bpm);
int fluid_player_set_playback_callback(fluid_player_t *player, handle_midi_event_func_t handler, void *handler_data);
int fluid_player_set_tick_callback(fluid_player_t *player, handle_midi_tick_func_t handler, void *handler_data);

int fluid_player_get_status(fluid_player_t *player);
int fluid_player_get_current_tick(fluid_player_t *player);
int fluid_player_get_total_ticks(fluid_player_t *player);
int fluid_player_get_bpm(fluid_player_t *player);
int fluid_player_get_midi_tempo(fluid_player_t *player);
int fluid_player_seek(fluid_player_t *player, int ticks);

/** sequencer */
typedef void (*fluid_event_callback_t)(unsigned int time, fluid_event_t *event,
                                       fluid_sequencer_t *seq, void *data);
                                       
fluid_sequencer_t *new_fluid_sequencer2(int use_system_timer);
void delete_fluid_sequencer(fluid_sequencer_t *seq);
/** @endlifecycle */

int fluid_sequencer_get_use_system_timer(fluid_sequencer_t *seq);
fluid_seq_id_t fluid_sequencer_register_client(fluid_sequencer_t *seq, const char *name,
        fluid_event_callback_t callback, void *data);
void fluid_sequencer_unregister_client(fluid_sequencer_t *seq, fluid_seq_id_t id);
int fluid_sequencer_count_clients(fluid_sequencer_t *seq);
fluid_seq_id_t fluid_sequencer_get_client_id(fluid_sequencer_t *seq, int index);
char *fluid_sequencer_get_client_name(fluid_sequencer_t *seq, fluid_seq_id_t id);
int fluid_sequencer_client_is_dest(fluid_sequencer_t *seq, fluid_seq_id_t id);
void fluid_sequencer_process(fluid_sequencer_t *seq, unsigned int msec);
void fluid_sequencer_send_now(fluid_sequencer_t *seq, fluid_event_t *evt);
int fluid_sequencer_send_at(fluid_sequencer_t *seq, fluid_event_t *evt,
                            unsigned int time, int absolute);
void fluid_sequencer_remove_events(fluid_sequencer_t *seq, fluid_seq_id_t source, fluid_seq_id_t dest, int type);
unsigned int fluid_sequencer_get_tick(fluid_sequencer_t *seq);
void fluid_sequencer_set_time_scale(fluid_sequencer_t *seq, double scale);
double fluid_sequencer_get_time_scale(fluid_sequencer_t *seq);

/** Seq bind */
fluid_seq_id_t fluid_sequencer_register_fluidsynth(fluid_sequencer_t *seq, fluid_synth_t *synth);
int fluid_sequencer_add_midi_event_to_buffer(void *data, fluid_midi_event_t *event);

/** events */
enum fluid_seq_event_type
{
    FLUID_SEQ_NOTE = 0,     /**< Note event with duration */
    FLUID_SEQ_NOTEON,       /**< Note on event */
    FLUID_SEQ_NOTEOFF,      /**< Note off event */
    FLUID_SEQ_ALLSOUNDSOFF, /**< All sounds off event */
    FLUID_SEQ_ALLNOTESOFF,  /**< All notes off event */
    FLUID_SEQ_BANKSELECT,       /**< Bank select message */
    FLUID_SEQ_PROGRAMCHANGE,    /**< Program change message */
    FLUID_SEQ_PROGRAMSELECT,    /**< Program select message */
    FLUID_SEQ_PITCHBEND,        /**< Pitch bend message */
    FLUID_SEQ_PITCHWHEELSENS,   /**< Pitch wheel sensitivity set message @since 1.1.0 was misspelled previously */
    FLUID_SEQ_MODULATION,       /**< Modulation controller event */
    FLUID_SEQ_SUSTAIN,      /**< Sustain controller event */
    FLUID_SEQ_CONTROLCHANGE,    /**< MIDI control change event */
    FLUID_SEQ_PAN,      /**< Stereo pan set event */
    FLUID_SEQ_VOLUME,       /**< Volume set event */
    FLUID_SEQ_REVERBSEND,       /**< Reverb send set event */
    FLUID_SEQ_CHORUSSEND,       /**< Chorus send set event */
    FLUID_SEQ_TIMER,        /**< Timer event (useful for giving a callback at a certain time) */
    FLUID_SEQ_CHANNELPRESSURE,    /**< Channel aftertouch event @since 1.1.0 */
    FLUID_SEQ_KEYPRESSURE,        /**< Polyphonic aftertouch event @since 2.0.0 */
    FLUID_SEQ_SYSTEMRESET,        /**< System reset event @since 1.1.0 */
    FLUID_SEQ_UNREGISTERING,      /**< Called when a sequencer client is being unregistered. @since 1.1.0 */
    FLUID_SEQ_SCALE,              /**< Sets a new time scale for the sequencer @since 2.2.0 */
    FLUID_SEQ_LASTEVENT     /**< @internal Defines the count of events enums @warning This symbol 
                              is not part of the public API and ABI stability guarantee and 
                              may change at any time! */
};

/* Event alloc/free */
/** @startlifecycle{Sequencer Event} */
fluid_event_t *new_fluid_event(void);
void delete_fluid_event(fluid_event_t *evt);
/** @endlifecycle */

/* Initializing events */
void fluid_event_set_source(fluid_event_t *evt, fluid_seq_id_t src);
void fluid_event_set_dest(fluid_event_t *evt, fluid_seq_id_t dest);

/* Timer events */
void fluid_event_timer(fluid_event_t *evt, void *data);

/* Note events */
void fluid_event_note(fluid_event_t *evt, int channel,
                                     short key, short vel,
                                     unsigned int duration);

void fluid_event_noteon(fluid_event_t *evt, int channel, short key, short vel);
void fluid_event_noteoff(fluid_event_t *evt, int channel, short key);
void fluid_event_all_sounds_off(fluid_event_t *evt, int channel);
void fluid_event_all_notes_off(fluid_event_t *evt, int channel);

/* Instrument selection */
void fluid_event_bank_select(fluid_event_t *evt, int channel, short bank_num);
void fluid_event_program_change(fluid_event_t *evt, int channel, int preset_num);
void fluid_event_program_select(fluid_event_t *evt, int channel, unsigned int sfont_id, short bank_num, short preset_num);

/* Real-time generic instrument controllers */
void fluid_event_control_change(fluid_event_t *evt, int channel, short control, int val);

/* Real-time instrument controllers shortcuts */
void fluid_event_pitch_bend(fluid_event_t *evt, int channel, int val);
void fluid_event_pitch_wheelsens(fluid_event_t *evt, int channel, int val);
void fluid_event_modulation(fluid_event_t *evt, int channel, int val);
void fluid_event_sustain(fluid_event_t *evt, int channel, int val);
void fluid_event_pan(fluid_event_t *evt, int channel, int val);
void fluid_event_volume(fluid_event_t *evt, int channel, int val);
void fluid_event_reverb_send(fluid_event_t *evt, int channel, int val);
void fluid_event_chorus_send(fluid_event_t *evt, int channel, int val);

void fluid_event_key_pressure(fluid_event_t *evt, int channel, short key, int val);
void fluid_event_channel_pressure(fluid_event_t *evt, int channel, int val);
void fluid_event_system_reset(fluid_event_t *evt);

/* Only when unregistering clients */
void fluid_event_unregistering(fluid_event_t *evt);

void fluid_event_scale(fluid_event_t *evt, double new_scale);
int fluid_event_from_midi_event(fluid_event_t *, const fluid_midi_event_t *);

/* Accessing event data */
int fluid_event_get_type(fluid_event_t *evt);
fluid_seq_id_t fluid_event_get_source(fluid_event_t *evt);
fluid_seq_id_t fluid_event_get_dest(fluid_event_t *evt);
int fluid_event_get_channel(fluid_event_t *evt);
short fluid_event_get_key(fluid_event_t *evt);
short fluid_event_get_velocity(fluid_event_t *evt);
short fluid_event_get_control(fluid_event_t *evt);
int fluid_event_get_value(fluid_event_t *evt);
int fluid_event_get_program(fluid_event_t *evt);
void *fluid_event_get_data(fluid_event_t *evt);
unsigned int fluid_event_get_duration(fluid_event_t *evt);
short fluid_event_get_bank(fluid_event_t *evt);
int fluid_event_get_pitch(fluid_event_t *evt);
double fluid_event_get_scale(fluid_event_t *evt);
unsigned int fluid_event_get_sfont_id(fluid_event_t *evt);
]]
