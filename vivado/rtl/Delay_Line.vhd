library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Delay_Line is
    generic(
        g_Delay     :   integer     :=  20
    );
    Port (
        i_clk       :   in      std_logic;
        i_Signal_I    :   in      signed(13 downto 0);
        i_Signal_Q    :   in      signed(13 downto 0); 

        i_Signal_I_Delayed    :   out      signed(13 downto 0);
        i_Signal_Q_Delayed    :   out      signed(13 downto 0)
        );
end Delay_Line;

architecture Behavioral of Delay_Line is

    Type 	Signal_IQ_Delay is array (0 to g_Delay - 1) of signed (13 downto 0);	
	signal	Signal_I_Delay				:	Signal_IQ_Delay						:=	(others=>(others=>'0'));
	signal	Signal_Q_Delay				:	Signal_IQ_Delay						:=	(others=>(others=>'0'));

begin
    
    process(i_clk)
    begin
        if rising_edge(i_clk) then

            Signal_I_Delay(0) <= i_Signal_I;
            Signal_Q_Delay(0) <= i_Signal_Q;

            for I in 0 to g_Delay - 2 loop
                Signal_I_Delay(I + 1) <= Signal_I_Delay(I);
                Signal_Q_Delay(I + 1) <= Signal_Q_Delay(I);
            end loop;

        end if;
    end process;

    i_Signal_I_Delayed <= Signal_I_Delay(g_Delay - 1);
    i_Signal_Q_Delayed <= Signal_Q_Delay(g_Delay - 1);


end Behavioral;
