----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:14:28 04/07/2014 
-- Design Name: 
-- Module Name:    UC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
    Port ( IR_op_code : in  STD_LOGIC_VECTOR (5 downto 0);
           Branch : out  STD_LOGIC;
           RegDst : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
		   MemWrite : out  STD_LOGIC;
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
            -- Nuevas se�ales
	   FP_add	: out  STD_LOGIC; -- indica que es una suma en FP
	   FP_mem	: out  STD_LOGIC; -- indica que es el acceso a memoria debe usar el banco de registros FP
	   RegWrite_FP : out  STD_LOGIC -- indica que la instrucci�n escribe en el banco de registros 
			  -- Fin Nuevas se�ales
           );
end UC;

architecture Behavioral of UC is

begin
-- Si IR_op = 0 es nop, IR_op=1 es aritm�tica, IR_op=2 es LW, IR_op=3 es SW, IR_op= 4 es BEQ
-- este CASE es en realidad un mux con las entradas fijas.
UC_mux : process (IR_op_code)
begin 
	CASE IR_op_code IS
		 WHEN  "000000"  =>  Branch <= '0'; RegDst <= '0'; ALUSrc <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
		 WHEN  "000001"  =>  Branch <= '0'; RegDst <= '1'; ALUSrc <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
		 WHEN  "000010"  =>  Branch <= '0'; RegDst <= '0'; ALUSrc <= '1'; MemWrite <= '0'; MemRead <= '1'; MemtoReg <= '1'; RegWrite <= '1'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
		 WHEN  "000011"  =>  Branch <= '0'; RegDst <= '0'; ALUSrc <= '1'; MemWrite <= '1'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
		 WHEN  "000100"  =>  Branch <= '1'; RegDst <= '0'; ALUSrc <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
		 WHEN "100001"    =>  Branch <= '0'; RegDst <= '1'; ALUSrc <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '1'; FP_mem <= '0'; RegWrite_FP <= '1';
         	 WHEN "100010"    =>  Branch <= '0'; RegDst <= '0'; ALUSrc <= '1'; MemWrite <= '0'; MemRead <= '1'; MemtoReg <= '1'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '1'; RegWrite_FP <= '1';
         	 WHEN "100011"    =>  Branch <= '0'; RegDst <= '0'; ALUSrc <= '1'; MemWrite <= '1'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '1'; RegWrite_FP <= '0';
		 WHEN  OTHERS 	  => Branch <= '0'; RegDst <= '0'; ALUSrc <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0'; FP_add <= '0'; FP_mem <= '0'; RegWrite_FP <= '0';
	  END CASE;
end process;
end Behavioral;

