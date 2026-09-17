LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity IQ_Demodulator is
    Port ( 
	 
            i_clk	                : in  std_logic; -- 128 MHz
			i_Signal_IF				: in	signed	(13 downto 0);	
			i_Signal_I					: out	signed	(13 downto 0);			
			i_Signal_Q					: out	signed	(13 downto 0)				
           );
          
end IQ_Demodulator;

Architecture Behav of IQ_Demodulator is
								
signal	Signal_IF_Int                 :	signed	(13 downto 0)	:=	(others=>'0');
signal	Signal_IF_Neg		            :	signed	(13 downto 0)	:=	(others=>'0');
signal	Signal_IF_Pos		            :	signed	(13 downto 0)	:=	(others=>'0');
signal	Signal_I_Mult		            :	signed	(13 downto 0)	:=	(others=>'0');
signal	Signal_Q_Mult		            :	signed	(13 downto 0)	:=	(others=>'0');
signal	LPF_Signal_I                  :	signed	(13 downto 0)	:=	(others=>'0');
signal	LPF_Signal_Q                  :	signed	(13 downto 0)	:=	(others=>'0');
signal	IQ_Counter							:	unsigned	(1 downto 0)	:=	(others=>'0');

signal	Output_Int_Out1					: signed(37 downto 0);
signal	Output_Int_Out2					: signed(37 downto 0);

begin 

	i_Signal_I					<= LPF_Signal_Q;			
	i_Signal_Q					<= 0-LPF_Signal_I;		

	process(i_clk)
		begin 
		
			if rising_edge(i_clk) then
			
				Signal_IF_Int	<= i_Signal_IF;
				Signal_IF_Pos	<=	Signal_IF_Int;
				Signal_IF_Neg	<=	0 - Signal_IF_Int;
				IQ_Counter		<= IQ_Counter + 1;
				
				case IQ_Counter is
				
					when "10" =>
						Signal_I_Mult	<=	(others=>'0');
						Signal_Q_Mult	<=	Signal_IF_Neg;
						
					when "11" =>
						Signal_I_Mult	<=	Signal_IF_Neg;
						Signal_Q_Mult	<=	(others=>'0');

					when "00" =>
						Signal_I_Mult	<=	(others=>'0');
						Signal_Q_Mult	<=	Signal_IF_Pos;

					when others =>
						Signal_I_Mult	<=	Signal_IF_Pos;
						Signal_Q_Mult	<=	(others=>'0');
					
				end case;
				 				
			end if;

	end process ;

Low_Pass_Filter_Inst1: entity work.Low_Pass_Filter 
	generic map (
						A_WIDTH						=> 14,
						B_WIDTH						=> 14
	)	
	port map (	
						Input_Signal				=> Signal_I_Mult,
						Output_Signal				=> LPF_Signal_I,
						Output_Int_Out				=> Output_Int_Out1,
						i_clk							=> i_clk
	);
	
	
Low_Pass_Filter_Inst2: entity work.Low_Pass_Filter 
	generic map (
						A_WIDTH						=> 14,
						B_WIDTH						=> 14
	)	
	port map (	
						Input_Signal				=> Signal_Q_Mult,
						Output_Signal				=> LPF_Signal_Q,
						Output_Int_Out				=> Output_Int_Out2,
						i_clk							=> i_clk
	);

end Behav;
