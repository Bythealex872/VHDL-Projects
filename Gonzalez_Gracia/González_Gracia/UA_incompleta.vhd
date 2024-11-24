library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Unidad de anticipación incompleta. Ahora mismo selecciona siempre la entrada 0
-- Entradas: 
-- Reg_Rs_EX
-- Reg_Rt_EX
-- RegWrite_MEM
-- RW_MEM
-- RegWrite_WB
-- RW_WB
-- Salidas:
-- MUX_ctrl_A
-- MUX_ctrl_B
entity UA is
	Port(
			Reg_Rs_EX: IN  std_logic_vector(4 downto 0); 
			Reg_Rt_EX: IN  std_logic_vector(4 downto 0);
			RegWrite_MEM: IN std_logic;
			RW_MEM: IN  std_logic_vector(4 downto 0);
			RegWrite_WB: IN std_logic;
			RW_WB: IN  std_logic_vector(4 downto 0);
			MUX_ctrl_A: out std_logic_vector(1 downto 0);
			MUX_ctrl_B: out std_logic_vector(1 downto 0)
		);
	end UA;

Architecture Behavioral of UA is
signal Corto_A_Mem, Corto_B_Mem, Corto_A_WB, Corto_B_WB: std_logic;
begin
-- Debeis dise~narla vosotros, ahora mismo elige siempre la entrada 0. Es decir sin ning'un tipo de anticipaci'on
-- entrada 00: se corresponde al dato del banco de registros
-- entrada 01: dato de la etapa Mem
-- entrada 10: dato de la etapa WB
Corto_A_MEM <= '1' WHEN RegWrite_MEM='1' AND Reg_Rs_EX = RW_MEM else '0';
Corto_B_MEM <= '1' WHEN RegWrite_MEM='1' AND Reg_Rt_EX = RW_MEM else '0';
Corto_A_WB <= '1' WHEN Reg_Rs_EX = RW_WB AND RegWrite_WB = '1' else '0';
Corto_B_WB <= '1' WHEN Reg_Rt_EX = RW_WB AND RegWrite_WB = '1' else '0';

MUX_ctrl_A <= "01" WHEN Corto_A_MEM = '1' else
	      "10" WHEN Corto_A_WB = '1' else
	      "00";

MUX_ctrl_B <= "01" WHEN Corto_B_MEM = '1' else
	      "10" WHEN Corto_B_WB = '1' else
	       "00";
end Behavioral;
