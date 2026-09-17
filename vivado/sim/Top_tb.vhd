library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_Top is
end tb_Top;

architecture Behavioral of tb_Top is

    -- ============================================
    -- Component Declaration
    -- ============================================
    COMPONENT Top
        Port (
            i_clk           :   in      std_logic;
            i_IF            :   in      signed(13 downto 0);
            o_Frequency     :   out     signed(23 downto 0);
            o_FFT_Amp       :   out     signed(21 downto 0);
            o_start_fft     :   out     std_logic;
            -- o_sqrt_dem      :   out     signed(13 downto 0);
            Baseband_Signal :   out     signed(13 downto 0);
            o_Signal_I_dem  :   out     signed(13 downto 0);
            o_Signal_Q_dem  :   out     signed(13 downto 0);
            -- o_i_Signal_I_Delayed : out signed(13 downto 0);
            -- o_i_Signal_Q_Delayed : out signed(13 downto 0);
            o_s_FFT_valid   :   out     std_logic;
            o_s_FFT_tlast   :   out     std_logic;
            o_sample_fft    :   out     integer;
            o_FFT_Re        :   out     signed(21 downto 0);
            o_FFT_Im        :   out     signed(21 downto 0);
            o_m_Amp_FFT_valid   : out   std_logic;
            o_m_FFT_valid   :   out std_logic;
            -- o_divisor       : out   signed(31 downto 0);
            -- o_dividend      : out   signed(23 downto 0);
            o_Max_Index     : out   unsigned(6 downto 0);
            o_p             : out   signed(15 downto 0)
        );
    END COMPONENT;

    -- ============================================
    -- Clock (128 MHz)
    -- ============================================
    signal Clock        : std_logic := '0';
    constant CLK_PERIOD : time := 7.8125 ns;

    -- ============================================
    -- DUT Input
    -- ============================================
    signal IF_Input     : signed(13 downto 0) := (others => '0');

    -- ============================================
    -- DUT Outputs
    -- ============================================
    signal Frequency        : signed(23 downto 0);
    signal FFT_Amp          : signed(21 downto 0);
    signal start_fft        : std_logic;
    -- signal sqrt_dem         : signed(13 downto 0);
    signal baseband_signal  : signed(13 downto 0);
    signal Signal_I_dem     : signed(13 downto 0);
    signal Signal_Q_dem     : signed(13 downto 0);
    -- signal Signal_I_Delayed : signed(13 downto 0);
    -- signal Signal_Q_Delayed : signed(13 downto 0);
    signal s_FFT_valid      : std_logic;
    signal s_FFT_tlast      : std_logic;
    signal sample_fft       : integer;
    signal FFT_Re           : signed(21 downto 0);
    signal FFT_Im           : signed(21 downto 0);
    signal m_Amp_FFT_valid  : std_logic;
    signal m_FFT_data_tvalid : std_logic;   
    signal Max_Index        : unsigned(6 downto 0);
    signal p_out            : signed(15 downto 0);

    -- signal o_divisor        : signed(31 downto 0) := (others => '0');
    -- signal o_dividend       : signed(23 downto 0) := (others => '0');

    -- ============================================
    -- Testbench Control
    -- ============================================
    signal sim_done     : boolean := false;
    signal cycle_count  : integer := 0;
    constant MAX_CYCLES : integer := 500000;

begin

    -- ============================================
    -- Instantiate DUT
    -- ============================================
    DUT : Top
        PORT MAP (
            i_clk                   => Clock,
            i_IF                    => IF_Input,
            o_Frequency             => Frequency,
            o_FFT_Amp               => FFT_Amp,
            o_start_fft             => start_fft,
            -- o_sqrt_dem              => sqrt_dem,
            Baseband_Signal         => baseband_signal,
            o_Signal_I_dem          => Signal_I_dem,
            o_Signal_Q_dem          => Signal_Q_dem,
            -- o_i_Signal_I_Delayed    => Signal_I_Delayed,
            -- o_i_Signal_Q_Delayed    => Signal_Q_Delayed,
            o_s_FFT_valid           => s_FFT_valid,
            o_s_FFT_tlast           => s_FFT_tlast,
            o_sample_fft            => sample_fft,
            o_FFT_Re                => FFT_Re,
            o_FFT_Im                => FFT_Im,
            o_m_Amp_FFT_valid       => m_Amp_FFT_valid,
            o_m_FFT_valid     => m_FFT_data_tvalid,   
            -- o_divisor               => o_divisor,
            -- o_dividend              => o_dividend,
            o_Max_Index             => Max_Index,
            o_p                     => p_out
        );

    -- ============================================
    -- Clock Generation
    -- ============================================
    Clock_Gen : process
    begin
        while not sim_done loop
            Clock <= '0';
            wait for CLK_PERIOD/2;
            Clock <= '1';
            wait for CLK_PERIOD/2;
            cycle_count <= cycle_count + 1;
        end loop;
        wait;
    end process;

    -- ============================================
    -- Read IF_Input.txt and send to DUT
    -- ============================================
    Read_IF_Signal : process(Clock)
        file file_in : text open read_mode is "D:\myProjects\Vhdl\test_clone\data\IF_Input.txt";
        variable line_in : line;
        variable var_in  : integer;
        variable read_ok : boolean;
    begin
        if rising_edge(Clock) then
            if not endfile(file_in) then
                readline(file_in, line_in);
                read(line_in, var_in, read_ok);
                
                if read_ok then
                    IF_Input <= to_signed(var_in, 14);
                end if;
            else
                IF_Input <= (others => '0');
            end if;
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_FFT_Amp to file
    -- ============================================
    Write_FFT_Amp : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\FFT_Amp_HDL.txt";
        variable line_out : line;
        variable prev_valid : std_logic := '0';
    begin
        if rising_edge(Clock) then
            if (prev_valid = '0' and m_Amp_FFT_valid = '1') then
                write(line_out, to_integer(FFT_Amp));
                writeline(file_out, line_out);
            end if;
            prev_valid := m_Amp_FFT_valid;
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_Frequency to file
    -- ============================================
    Write_Frequency : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\Frequency_HDL.txt";
        variable line_out : line;
        variable prev_valid : std_logic := '0';
    begin
        if rising_edge(Clock) then
            if (prev_valid = '0' and m_Amp_FFT_valid = '1') then
                write(line_out, to_integer(Frequency));
                writeline(file_out, line_out);
            end if;
            prev_valid := m_Amp_FFT_valid;
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_sqrt_dem to file
    -- ============================================
    Write_Sqrt_Dem : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\Sqrt_Dem_HDL.txt";
        variable line_out : line;
    begin
        if rising_edge(Clock) then
            write(line_out, to_integer(baseband_signal));
            writeline(file_out, line_out);
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_Signal_I_dem to file
    -- ============================================
    Write_Signal_I_dem : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\Signal_I_dem_HDL.txt";
        variable line_out : line;
    begin
        if rising_edge(Clock) then
            write(line_out, to_integer(Signal_I_dem));
            writeline(file_out, line_out);
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_Signal_Q_dem to file
    -- ============================================
    Write_Signal_Q_dem : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\Signal_Q_dem_HDL.txt";
        variable line_out : line;
    begin
        if rising_edge(Clock) then
            write(line_out, to_integer(Signal_Q_dem));
            writeline(file_out, line_out);
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_FFT_Re to file
    -- ============================================
    Write_FFT_Re : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\FFT_Re_HDL.txt";
        variable line_out : line;
        variable prev_valid : std_logic := '0';
    begin
        if rising_edge(Clock) then
            if (prev_valid = '0' and m_FFT_data_tvalid = '1') then
                write(line_out, to_integer(FFT_Re));
                writeline(file_out, line_out);
            end if;
            prev_valid := m_FFT_data_tvalid;
        end if;
    end process;

    -- ============================================
    -- ✅ Write o_FFT_Im to file
    -- ============================================
    Write_FFT_Im : process(Clock)
        file file_out : text open write_mode is "D:\myProjects\Vhdl\test_clone\data\FFT_Im_HDL.txt";
        variable line_out : line;
        variable prev_valid : std_logic := '0';
    begin
        if rising_edge(Clock) then
            if (prev_valid = '0' and m_FFT_data_tvalid = '1') then
                write(line_out, to_integer(FFT_Im));
                writeline(file_out, line_out);
            end if;
            prev_valid := m_FFT_data_tvalid;
        end if;
    end process;

    -- ============================================
    -- Monitor (اختیاری)
    -- ============================================
    Monitor_Output : process(Clock)
    begin
        if rising_edge(Clock) then
            if (cycle_count mod 5000 = 0) and cycle_count > 0 then
                report "Cycle " & integer'image(cycle_count) &
                       " | IF=" & integer'image(to_integer(IF_Input)) &
                       " | Freq=" & integer'image(to_integer(Frequency)) &
                       " | p=" & integer'image(to_integer(p_out));
            end if;
        end if;
    end process;

    -- ============================================
    -- Stop Logic
    -- ============================================
    Stop_Logic : process(Clock)
    begin
        if rising_edge(Clock) then
            if (cycle_count >= MAX_CYCLES) then
                sim_done <= true;
                report "Simulation Finished!" severity note;
            end if;
        end if;
    end process;

end Behavioral;