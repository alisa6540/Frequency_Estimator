library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top is
    Port (
        i_clk           :   in      std_logic;
        i_IF            :   in      signed(13 downto 0);
        
        o_Frequency     :   out     signed(23 downto 0);
        o_FFT_Amp       :   out     signed(21 downto 0);
        o_start_fft     :   out     std_logic;
        -- o_sqrt_dem      :   out     signed(13 downto 0);
        Baseband_Signal :   out     signed(13 downto 0);

        o_Signal_I_dem            : out  signed(13 downto 0);
        o_Signal_Q_dem            : out  signed(13 downto 0);

        -- o_i_Signal_I_Delayed            : out  signed(13 downto 0);
        -- o_i_Signal_Q_Delayed            : out  signed(13 downto 0);

        --FFT

        o_s_FFT_valid     :   out     std_logic;
        o_s_FFT_tlast     :   out     std_logic;

        o_sample_fft    :   out integer;

        o_FFT_Re       :   out     signed(21 downto 0);
        o_FFT_Im       :   out     signed(21 downto 0);

        --AMP_SQRT_FFT

        o_m_Amp_FFT_valid   :   out std_logic;
        o_m_FFT_valid   :   out std_logic;

        -- o_divisor               : out   signed(31 downto 0);
        -- o_dividend              : out   signed(23 downto 0);

        o_Max_Index          :   out  unsigned(6 downto 0);

        o_p         :   out   signed(15 downto 0)
     );
end Top;

architecture Behavioral of Top is

    COMPONENT IQ_Demodulator
        PORT (
            i_clk        : in  std_logic;
            i_Signal_IF  : in  signed(13 downto 0);    
            i_Signal_I   : out signed(13 downto 0);            
            i_Signal_Q   : out signed(13 downto 0)
        );
    END COMPONENT;

    COMPONENT Delay_Line 
        generic(
            g_Delay     :   integer     :=  30
        );
        Port (
            i_clk                 : in  std_logic;
            i_Signal_I            : in  signed(13 downto 0);
            i_Signal_Q            : in  signed(13 downto 0); 
            i_Signal_I_Delayed    : out signed(13 downto 0);
            i_Signal_Q_Delayed    : out signed(13 downto 0)
        );
    END COMPONENT;

    COMPONENT Amp_SQRT
        PORT (
            aclk                    : IN STD_LOGIC;
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tdata  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_dout_tvalid      : OUT STD_LOGIC;
            m_axis_dout_tdata       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
        );
    END COMPONENT;


    COMPONENT FFT_SQRT
        PORT (
            aclk                    : IN STD_LOGIC;
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tdata  : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
            m_axis_dout_tvalid      : OUT STD_LOGIC;
            m_axis_dout_tdata       : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
        );
    END COMPONENT;


    COMPONENT interpolation
        PORT (
        aclk : IN STD_LOGIC;
        s_axis_divisor_tvalid : IN STD_LOGIC;
        s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_dividend_tvalid : IN STD_LOGIC;
        s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
        m_axis_dout_tvalid : OUT STD_LOGIC;
        m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0) 
        );
    END COMPONENT;

  
    signal i_Signal_IF_int   : signed(13 downto 0);
    signal i_Signal_I        : signed(13 downto 0);            
    signal i_Signal_Q        : signed(13 downto 0);
    signal i_Signal_I_Delayed: signed(13 downto 0);
    signal i_Signal_Q_Delayed: signed(13 downto 0);

  
    signal s_axis_cartesian_tvalid_dem  : std_logic := '0';
    signal s_axis_cartesian_tdata_dem   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');   
    signal m_axis_dout_tvalid_dem       : std_logic := '0';
    signal m_axis_dout_tdata_dem        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

    signal s_axis_config_tdata      : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"01";
    signal s_axis_config_tvalid     : std_logic := '1';
    signal s_axis_config_tready     : std_logic;
    signal s_axis_data_tdata        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal s_axis_data_tvalid       : std_logic := '0';
    signal s_axis_data_tready       : std_logic;
    signal s_axis_data_tlast        : std_logic := '0';
    signal m_axis_data_tdata        : STD_LOGIC_VECTOR(47 DOWNTO 0);
    signal m_axis_data_tvalid       : std_logic;
    signal m_axis_data_tlast        : std_logic;
    signal event_frame_started      : std_logic;
    signal event_tlast_unexpected   : std_logic;
    signal event_tlast_missing      : std_logic;
    signal event_data_in_channel_halt : std_logic;


    signal s_axis_cartesian_tvalid_fft  : std_logic := '0';
    signal s_axis_cartesian_tdata_fft   : STD_LOGIC_VECTOR(47 DOWNTO 0) := (others => '0');   
    signal m_axis_dout_tvalid_fft       : std_logic := '0';
    signal m_axis_dout_tdata_fft        : STD_LOGIC_VECTOR(47 DOWNTO 0) := (others => '0');

    signal div_dividend     : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0');
    signal div_divisor      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

    signal div_nd           : std_logic := '0';
    signal div_rdy          : std_logic;
    signal m_axis_dout_tvalid_div : std_logic;
    signal m_axis_dout_tdata_div  : STD_LOGIC_VECTOR(39 DOWNTO 0);

    signal Threshold                : unsigned(16 downto 0) := to_unsigned(782, 17);
    signal FFT_Start                : std_logic := '0';
    signal Pulse_Detection_Counter  : unsigned(5 downto 0) := (others => '0');
    signal Pulse_Termination_Counter: unsigned(5 downto 0) := (others => '0');
    signal Pulse_Detection_Flag     : std_logic := '0';

    signal Baseband_Signal_Resize   : unsigned(16 downto 0) := (others => '0');
    signal Baseband_Amp             : std_logic_vector(13 downto 0);
    signal Baseband_Amp_Unsigned    : unsigned(16 downto 0);

    signal FFT_Amp        : signed(21 downto 0) := (others => '0');
    signal FFT_Amp_D1     : signed(21 downto 0) := (others => '0');
    signal FFT_Amp_D2     : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_A  : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_B  : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_C  : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_A_Buff : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_B_Buff : signed(21 downto 0) := (others => '0');
    signal FFT_Max_Amp_C_Buff : signed(21 downto 0) := (others => '0');
    signal FFT_Index_Counter        : unsigned(7 downto 0) := (others => '0');
    signal FFT_Max_Index            : unsigned(6 downto 0) := (others => '0');
    signal FFT_Max_Index_Buff       : unsigned(6 downto 0) := (others => '0');
    signal FFT_Amp_Ready_Prev_1     : std_logic := '0';
    signal FFT_Amp_Ready_Prev_2     : std_logic := '0';

    signal Bin_Offset               : signed(15 downto 0) := (others => '0');
    signal Bin_Offset_New_Data      : std_logic := '0';
    signal Bin_Offset_New_Ready     : std_logic := '0';
    signal Estimated_Frequency      : signed(23 downto 0) := (others => '0');

    signal fft_sample_counter : unsigned(7 downto 0) := (others => '0');

    signal sample_counter       :   integer range 0 to 127  :=  0;
    signal r_start_fft       :   std_logic   :=  '0';   
    
    signal P_Fraction : signed(15 downto 0) := (others => '0');
    signal FFT_Max_Index_Qu : signed(23 downto 0) := (others => '0');

    signal padding_counter : unsigned(6 downto 0) := (others => '0');
    signal windowed_I : signed(13 downto 0) := (others => '0');
    signal windowed_Q : signed(13 downto 0) := (others => '0');

begin

    -- ============================================
    -- 1. IQ Demodulator
    -- ============================================
    Demodulator : IQ_Demodulator
    PORT MAP (
        i_clk           => i_clk,
        i_Signal_IF     => i_IF,    
        i_Signal_I      => i_Signal_I,    
        i_Signal_Q      => i_Signal_Q
    );

    o_Signal_I_dem  <=  i_Signal_I; 
    o_Signal_Q_dem  <=  i_Signal_Q;
    s_axis_cartesian_tdata_dem(13 downto 0)  <= std_logic_vector(i_Signal_I);
    s_axis_cartesian_tdata_dem(29 downto 16) <= std_logic_vector(i_Signal_Q);
    s_axis_cartesian_tdata_dem(15 downto 14) <= (others => i_Signal_I(13)); -- sign extend
    s_axis_cartesian_tdata_dem(31 downto 30) <= (others => i_Signal_Q(13)); -- sign extend

    s_axis_cartesian_tvalid_dem <= '1';

    Amp_SQRT_inst : Amp_SQRT
    PORT MAP (
        aclk                    => i_clk,
        s_axis_cartesian_tvalid => s_axis_cartesian_tvalid_dem,
        s_axis_cartesian_tdata  => s_axis_cartesian_tdata_dem,
        m_axis_dout_tvalid      => m_axis_dout_tvalid_dem,
        m_axis_dout_tdata       => m_axis_dout_tdata_dem
    );

 
    Baseband_Amp <= m_axis_dout_tdata_dem(13 downto 0);
    -- o_sqrt_dem  <=  signed(Baseband_Amp);
    Baseband_Signal_Resize <= unsigned(resize(signed(Baseband_Amp), 17));

    Baseband_Signal  <=  signed(Baseband_Amp);


    Delay_Line_inst : Delay_Line 
    generic map (
        g_Delay => 29  
    )
    PORT MAP (
        i_clk               => i_clk,
        i_Signal_I          => i_Signal_I,
        i_Signal_Q          => i_Signal_Q, 
        i_Signal_I_Delayed  => i_Signal_I_Delayed,
        i_Signal_Q_Delayed  => i_Signal_Q_Delayed
    );

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (s_axis_data_tvalid = '1') then
                if (padding_counter < 64) then
               
                    windowed_I <= i_Signal_I_Delayed;
                    windowed_Q <= i_Signal_Q_Delayed;
                else
                  
                    windowed_I <= (others => '0');
                    windowed_Q <= (others => '0');
                end if;
                
                if (padding_counter = 127) then
                    padding_counter <= (others => '0');
                else
                    padding_counter <= padding_counter + 1;
                end if;
            else
                padding_counter <= (others => '0');
            end if;
        end if;
    end process;



    s_axis_data_tdata(13 downto 0)  <= std_logic_vector(windowed_I);
    s_axis_data_tdata(15 downto 14) <= (others => windowed_I(13));
    s_axis_data_tdata(29 downto 16) <= std_logic_vector(windowed_Q);
    s_axis_data_tdata(31 downto 30) <= (others => windowed_Q(13));


    -- o_i_Signal_I_Delayed    <=  i_Signal_I_Delayed;
    -- o_i_Signal_Q_Delayed    <=  i_Signal_Q_Delayed;




    o_start_fft <=  FFT_Start;

    o_s_FFT_valid   <=  s_axis_data_tvalid;
    o_s_FFT_tlast   <=  s_axis_data_tlast;

    o_sample_fft    <=  sample_counter;

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            s_axis_data_tlast <= '0';
            if FFT_Start  =   '1' then
                s_axis_data_tvalid <= '1';
            end if;
            if  s_axis_data_tvalid = '1' then
                sample_counter <= sample_counter + 1;
                if sample_counter >= 126 then
                    s_axis_data_tlast <= '1';
                    if sample_counter = 127 then
                        s_axis_data_tlast <= '0';
                        sample_counter  <= 0;
                    end if;
                else 
                    s_axis_data_tlast   <= '0';
                end if;
            else 
                s_axis_data_tlast <= '0';
                sample_counter <= 0;
            end if;
        end if;
    end process;

    FFT_128_inst : entity work.FFT_128
    port map (
        aclk                        => i_clk,
        s_axis_config_tdata         => x"01",
        s_axis_config_tvalid        => '1',
        s_axis_config_tready        => open,
        s_axis_data_tdata           => s_axis_data_tdata,
        s_axis_data_tvalid          => s_axis_data_tvalid,
        s_axis_data_tready          => s_axis_data_tready,
        s_axis_data_tlast           => s_axis_data_tlast,
        m_axis_data_tdata           => m_axis_data_tdata,
        m_axis_data_tready         =>  '1',
        m_axis_data_tvalid          => m_axis_data_tvalid,
        m_axis_data_tlast           => m_axis_data_tlast,
        event_frame_started         => open,
        event_tlast_unexpected      => open,
        event_tlast_missing         => open,
        event_status_channel_halt   => open,
        event_data_in_channel_halt  => open,
        event_data_out_channel_halt => open 
    );


    s_axis_cartesian_tdata_fft(23 downto 0)  <= std_logic_vector(resize(signed(m_axis_data_tdata(21 downto 0)), 24));
    s_axis_cartesian_tdata_fft(47 downto 24) <= std_logic_vector(resize(signed(m_axis_data_tdata(45 downto 24)), 24));

    
    s_axis_cartesian_tvalid_fft <= m_axis_data_tvalid;
    o_m_FFT_valid   <=  m_axis_data_tvalid;

    FFT_Amp_inst : FFT_SQRT
    PORT MAP (
        aclk                    => i_clk,
        s_axis_cartesian_tvalid => s_axis_cartesian_tvalid_fft,
        s_axis_cartesian_tdata  => s_axis_cartesian_tdata_fft,
        m_axis_dout_tvalid      => m_axis_dout_tvalid_fft,
        m_axis_dout_tdata       => m_axis_dout_tdata_fft
    );


    comp : process(i_clk)
    begin
        if rising_edge(i_clk) then
   
            FFT_Start <= '0';
            if (Baseband_Signal_Resize > Threshold and Pulse_Detection_Flag = '0') then
                Pulse_Detection_Counter <= Pulse_Detection_Counter + 1;
                if (Pulse_Detection_Counter > to_unsigned(4, 6)) then
                    FFT_Start <= '1';            
                    Pulse_Detection_Flag <= '1';    
                    Pulse_Detection_Counter <= (others => '0');        
                end if;
            end if;

            if (Baseband_Signal_Resize < Threshold and Pulse_Detection_Flag = '1') then
                Pulse_Termination_Counter <= Pulse_Termination_Counter + 1;
                if (Pulse_Termination_Counter > to_unsigned(3, 6)) then
                    Pulse_Termination_Counter <= (others => '0');
                    Pulse_Detection_Flag <= '0';            
                end if;
            end if;


            FFT_Amp_D1 <= FFT_Amp;
            FFT_Amp_D2 <= FFT_Amp_D1;

        
            if (m_axis_dout_tvalid_fft = '1') then
                if (FFT_Index_Counter = to_unsigned(127, 8)) then
                    FFT_Max_Amp_A_Buff <= FFT_Max_Amp_A;
                    FFT_Max_Amp_B_Buff <= FFT_Max_Amp_B;
                    FFT_Max_Amp_C_Buff <= FFT_Max_Amp_C;
                    FFT_Max_Index_Buff <= FFT_Max_Index;

                    FFT_Max_Index <= to_unsigned(0, 7);
                    FFT_Max_Amp_A <= (others => '0');
                    FFT_Max_Amp_B <= FFT_Amp_D1;
                    FFT_Max_Amp_C <= FFT_Amp;
                    FFT_Index_Counter <= to_unsigned(0, 8);
                else
                    
                    FFT_Index_Counter <= FFT_Index_Counter + 1;

                    if (FFT_Amp_D1 > FFT_Max_Amp_B) then
                        FFT_Max_Amp_A <= FFT_Amp_D2;
                        FFT_Max_Amp_B <= FFT_Amp_D1;
                        FFT_Max_Amp_C <= FFT_Amp;
                        FFT_Max_Index <= FFT_Index_Counter(6 downto 0);
                    end if;
                end if;
            end if;
        end if;
    end process;



    FFT_Amp <= signed(m_axis_dout_tdata_fft(21 downto 0));



    div_dividend <= std_logic_vector(
        resize(signed('0' & FFT_Max_Amp_A_Buff), 24) - 
        resize(signed('0' & FFT_Max_Amp_C_Buff), 24)
    );
    
    -- Divisor = 2*(a - 2b + c) = 2a - 4b + 2c
    div_divisor <=std_logic_vector(
    resize(signed('0' & FFT_Max_Amp_A_Buff), 32) +   -- a
    resize(signed('0' & FFT_Max_Amp_A_Buff), 32) +   -- a (2a)
    resize(signed('0' & FFT_Max_Amp_C_Buff), 32) +   -- c
    resize(signed('0' & FFT_Max_Amp_C_Buff), 32) -   -- c (2c)
    resize(signed('0' & FFT_Max_Amp_B_Buff), 32) -   -- -b
    resize(signed('0' & FFT_Max_Amp_B_Buff), 32) -   -- -b
    resize(signed('0' & FFT_Max_Amp_B_Buff), 32) -   -- -b
    resize(signed('0' & FFT_Max_Amp_B_Buff), 32)     -- -b (-4b)
    );

    interpolation_inst : interpolation
    PORT MAP (
        aclk                    => i_clk,
        s_axis_divisor_tvalid   => m_axis_dout_tvalid_fft,
        s_axis_divisor_tdata    => div_divisor,
        s_axis_dividend_tvalid  => m_axis_dout_tvalid_fft,
        s_axis_dividend_tdata   => div_dividend,
        m_axis_dout_tvalid      => Bin_Offset_New_Ready,
        m_axis_dout_tdata       => m_axis_dout_tdata_div
    );
    -- o_divisor       <=  signed(div_divisor);
    -- o_dividend  <=  signed(div_dividend);


    P_Fraction <= signed(m_axis_dout_tdata_div(15 downto 0));

    FFT_Max_Index_Qu    <=  resize(signed('0' & FFT_Max_Index_Buff), 24);

    --  FFT_Max_Index(0 to 127)         ->  0.7 
    --  P_Fraction                      ->  1.0.15
    --  Estimated_Frequency             ->  1.8.15    

    process(i_clk)
    begin
        if rising_edge(i_clk) then

            
            if (Bin_Offset_New_Ready = '1') then
                Estimated_Frequency <= shift_left(FFT_Max_Index_Qu,15) + 
                                        resize(P_Fraction, 24) + 
                                        to_signed(159 * 32768, 24);  -- 32768   ->  2^15
            end if;
        end if;
    end process;

    

    o_Frequency <= Estimated_Frequency;
    o_Max_Index   <=  FFT_Max_Index ;
    o_p <=  P_Fraction;
    o_m_Amp_FFT_valid   <=m_axis_dout_tvalid_fft;
    o_FFT_Amp   <=  signed(m_axis_dout_tdata_fft(21 downto 0));

    o_FFT_Re       <=  signed(m_axis_data_tdata(21 downto 0));
    o_FFT_Im       <=  signed(m_axis_data_tdata(45 downto 24));

    

end Behavioral;