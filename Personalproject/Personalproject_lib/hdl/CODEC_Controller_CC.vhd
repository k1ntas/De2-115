--
-- VHDL Architecture Personalproject_lib.CODEC_Controller.CC
--
-- Created:
--          by - simha158.student-liu.se (muxen2-101.ad.liu.se)
--          at - 14:33:01 11/06/25
--
-- using Siemens HDL Designer(TM) 2024.1 Built on 24 Jan 2024 at 18:06:06
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CODEC_Controller IS
   PORT( 
      reset   : IN     std_logic;
      sys_clk : IN     std_logic;
      sdin    : INOUT  std_logic;
      sclk    : INOUT  std_logic
   );

-- Declarations

END CODEC_Controller ;

--
ARCHITECTURE CC OF CODEC_Controller IS
  TYPE state_machine IS(IDLE, START, SENDING, ACK ,STOP);
  CONSTANT CODEC_ADRESS   : std_logic_vector(7 DOWNTO 0) := "00110100";
  SIGNAL state            : state_machine;
  SIGNAL iSDIN        : std_logic;
  SIGNAL i2c_adress       : std_logic_vector(7 DOWNTO 0);
  SIGNAL i2c_data_clk     : std_logic;
BEGIN
  
  CLOCK_GENERATOR : PROCESS(sys_clk, reset)
  BEGIN
    IF(reset = '1') THEN
      
    ELSIF(rising_edge(sys_clk)) THEN
      
      
      
    END IF;
    
    
  END PROCESS;
  
  CLOCK_DIVIDER : PROCESS(sys_clk, reset)
  VARIABLE counter : integer RANGE 0 TO 65000;
  BEGIN
    IF(reset = '1') THEN
      i2c_data_clk <= '1';
      counter := 0;
      iSDIN <= '1';
    ELSIF(rising_edge(sys_clk)) THEN
      IF(counter = 65000/4) THEN
        i2c_data_clk <= '0';
        iSDIN <= '0'; 
      ELSIF(counter = 65000/2) THEN
        i2c_data_clk <= '1';
        iSDIN <= '0';
      ELSIF(counter = 65000/4*3) THEN
        i2c_data_clk <= '1';
        iSDIN <= '1';
      ELSIF(counter = 65000) THEN
        i2c_data_clk <=  '0';
        iSDIN <= '1';
      END IF;
      
      
    END IF;
  END PROCESS;
  
  I2C_STATE_MACHINE : PROCESS(sys_clk, reset)
  VARIABLE current_bit  : integer RANGE -1 TO 7 := 7;
  VARIABLE data         : std_logic_vector(7 DOWNTO 0);          --The current 8 bit instruction 
  VARIABLE settings     : std_logic_vector(15 DOWNTO 0);         --Register in the codec + the settings
  VARIABLE ack_counter  : unsigned := 0;
  VARIABLE prev_data_clk : std_logic;
  BEGIN
    IF(reset = '1') THEN                                         --Async reset 
      Prev_data_clk := '0';
      iSDIN <= '0';
    ELSIF(rising_edge(sys_clk)) THEN
      IF(prev_data_clk = '1' AND i2c_data_clk = '0') THEN
        CASE state IS
        WHEN START =>
            iSDIN <= '0';
            data := CODEC_ADRESS;
            state <= SENDING;
        WHEN SENDING =>
            IF(current_bit = -1) THEN 
              iSDIN <= '1';                                      --Stop driing data signal so CODEC can send ACK
              state <= ACK;
              current_bit := 7;
            ELSE 
              iSDIN <= data(current_bit);
              current_bit := current_bit - 1;
            END IF;
        WHEN ACK =>
            IF(sdin = '0') THEN
              ack_counter := ack_counter + 1; 
              data := settings(15 DOWNTO 8);
              settings(15 DOWNTO 8) := settings(7 DOWNTO 0);
              IF(ack_counter = 3) THEN
                state <= STOP; 
              END IF;
            ELSE 
              --CODEC did not send ack (we just ignore this now)
            END IF;
        WHEN STOP =>
          state <= IDLE 
        WHEN IDLE =>
        --IF start condition 
            state <= START;
          
        END CASE;
      END IF;
      prev_data_clk <= i2c_data_clk;
    END IF;
    
    
  END PROCESS;
  
  
  
--ToDO convert the internal 1 signal to Z
  
  
END ARCHITECTURE CC;

