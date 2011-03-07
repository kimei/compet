--! \file
--! \brief Constant declarations.

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)


--! \brief Constants
package constants is

--! This may be changed at will, but do not set it greater than the size of the HDR2
--! connector. With number of channels=1, LVDS pair 0 is built, pair {0,1} for channels=2, asf.
--constant fe_NUM_CHANNELS        : positive := 8; --! Number of TOT data channels to be built.
--constant fe_NUM_CHANNELS        : positive := 8; --! MR: Channel 7 is the trigger channel

constant fe_NUM_DIFF_CHANNELS   : positive := 2;
constant fe_NUM_SE_CHANNELS     : positive := 2;
constant fe_NUM_EMPTY_CHANNELS  : positive := 2;
--sum:
constant fe_NUM_CHANNELS        : positive := 6;


--! The word width constant can not be changed without also
--!   * rebuilding the PLL with the correct clock frequencies.
--!   * make sure the other related constants are correctly set aswell.
--! The constant is there mainly to ease this procedure. Parametrisation module for 8- and
--! 10bits width will be supplied. 10 is current due to gain of 20% resolution.
--constant fe_ch_WORD_WIDTH : positive  := 10; --! Deserialiser word width
constant fe_ch_WORD_WIDTH : positive  := 6; --! Deserialiser word width

-------------------
-- EVENT PACKAGE --
-------------------
-- Note. The following parameters MUST sum up to 32. This is to maximise the speed of the ethernet
--       link. Other than that, adjust as you want (extreme values have not been tested)

constant fe_ch_LOC_SIZE       : positive :=  7; --! (1) 2^7=128 channels (# bits) addressable channels.
constant fe_ch_TOT_SIZE       : positive := 11; --! (2) Width of TOT length counter (# bits)
constant fe_EVENT_NO_SIZE     : positive :=  7; --! Event number width (# bits)\
constant fe_CO_TRG_SIZE       : positive :=  7; --! (3) Width of coincidence trigger counter
--                                     SUM  32
constant fe_event_trigger_time_SIZE : positive:= 32;


--! Remarks.
--!   1. Must be big enough to address all channels specified by fe_NUM_CHANNELS.
--!   2. Must be >= 5 (since 4 bits is reserved for finetime information
--!   3. Must be >= 5 (since 4 bits is reserved for finetime information

---------
-- END --
---------

--! Since the Trigger Unit is meant to validate data by asserting the coincidence trigger, we
--! need to delay the data line by some fixed number of cycles corresponding to the time spent
--! by the Trigger Unit to make its trigger-decision, in addition to the routing delays (+2
--! cycles). By making it fixed, we save logic. However, should it ever be neccessary to
--! dynamically adjust this setting, it can easily be done.. 
constant fe_ch_MAX_DELAY : positive := 4; --! Maximum possible delay of deserialiser data
                                          --! 2^n number of clocks (3-4 should be fine I guess)

--! The EventBuilder contains several levels of combinatorial logic and will cause timing
--! violations unless built into a pipe. A pipe depth of 1 should suffice for 80 channels,
--! but in the case of timing problems you may increase it here.
-- constant fe_eb_PIPE_DEPTH : positive := 1; --! EventBuilder pipe depth

--constant fe_eb_FANIN      : positive := 2; --! SubMux fan-in (>= 2)
constant fe_eb_FANIN      : positive := 4; --! SubMux fan-in (>= 2)

--constant fe_TriggerRate_SIZE: positive:= 25;
--constant fe_EventRate_SIZE : positive := 11;
--constant fe_EventRate_LowerBound: positive := 8;
-- now I can measure rates between 2^8*(100MHz/2^25) = 762 Hz - 2^(8+11)*(100MHz/2^25)
--constant fe_TriggerRate_SIZE: positive:= 25;
constant fe_TriggerRate_SIZE: positive:= 25;
constant fe_EventRate_SIZE : positive := 11; --keep it at 11 (the same size as the TOT size)
--constant fe_EventRate_LowerBound: positive := 3;
constant fe_EventRate_LowerBound: positive := 3;




--! The EventBuilder 

--constant cs_VIO_SIZE      : positive := 256;
--constant cs_ILA_SIZE      : positive := 128;

constant cs_VIO_SIZE      : positive := 512;
constant cs_ILA_SIZE      : positive := 256;

end package constants;
