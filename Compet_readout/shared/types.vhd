--! \file
--! \brief Type declarations.

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants


--! \brief Types
package types is

  --! Make sure the size of this record add up to 32 bits in total
  type fe_ch_event_data_type is record
    event_no            : std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 );
    tot_start           : std_logic_vector( fe_CO_TRG_SIZE-1   downto 0 ); --! 2^6/50MHz = 
    tot_width           : std_logic_vector( fe_ch_TOT_SIZE-1   downto 0 );
    ch_no               : std_logic_vector( fe_ch_LOC_SIZE-1   downto 0 );
	 
  end record;
  type fe_ch_event_data_atype is array ( integer range <> ) of fe_ch_event_data_type;
-- fe_NUM_CHANNELS-1 downto 0


 -- type fe_ch_event_rate_atype is array( integer range <> ) of unsigned(fe_EventRate_SIZE-1 downto 0);

  --! In the event builder, we strip the event number off the package
  type fe_ch_event_data_reduced_type is record
    tot_start       : std_logic_vector( fe_CO_TRG_SIZE-1   downto 0 ); --! 2^6/50MHz = 
    tot_width       : std_logic_vector( fe_ch_TOT_SIZE-1   downto 0 );
    ch_no           : std_logic_vector( fe_ch_LOC_SIZE-1   downto 0 );
	 
  end record;
  type fe_ch_event_data_reduced_atype is array (integer range <>) of fe_ch_event_data_reduced_type;
  type fe_ch_event_no_atype is array (integer range <>) of std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 );
--  fe_NUM_CHANNELS-1 downto 0 

type fe_EventRateArray_atype is array( fe_NUM_CHANNELS-1 downto 0 ) of std_logic_vector(fe_EventRate_SIZE-1 downto 0);

  --! The FIFO will be accessed by the event builder with the following signals
  type fe_ch_fifo_otype is record --! Outputs
    dout            : fe_ch_event_data_type   ; --! Data output
    valid           : std_logic    ; --! Dout valid (read-ack)
--     empty           : std_logic    ; --! No data
    almost_full     : std_logic    ; --! Only 1 data space left
    full            : std_logic    ; --! No room for more data
    overflow        : std_logic    ; --! Write on full fifo = overflow
  end record;
  type fe_ch_fifo_out_atype is array ( fe_NUM_CHANNELS-1 downto 0 ) of fe_ch_fifo_otype;

  --! The BRAM shared between uP and my logic
  type up_bram_otype is record --! The uP BRAM interface
    clk     : std_logic                    ; --! BRAM clk
    din     : std_logic_vector(0 to 31)    ; --! BRAM data input
    a       : std_logic_vector(0 to 31)    ; --! BRAM address line
    we      : std_logic_vector(0 to 3)     ; --! BRAM write enable
    en      : std_logic                    ; --! BRAM enable
    com     : std_logic_vector(0 to 1)     ; --! BRAM communication line
  end record;

  --! The FIFO will be accessed by the event builder with the following signals
  type cs_vio_type is record --! Outputs from VIO
    test_en       : std_logic; -- 0
    readout_en    : std_logic; -- 1
    fe_soft_rst_b : std_logic; -- 2
    cotrg_en      : std_logic; -- 3
    data_delay    : std_logic_vector( fe_ch_MAX_DELAY-1 downto 0 );
    --ch_select     : std_logic_vector(                 6 downto 0 );
	 ch_select     : std_logic_vector(                 6 downto 0 );
    negate_inputs : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );
    mask_inputs   : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 ); --! Halts the deserialiser
    other         : std_logic_vector( cs_VIO_SIZE-1 downto 4+fe_ch_MAX_DELAY+7+2*fe_NUM_CHANNELS );
  end record;



end package types;

