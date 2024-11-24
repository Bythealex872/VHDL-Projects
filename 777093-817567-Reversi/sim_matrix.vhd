----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.02.2016 14:33:12
-- Design Name: 
-- Module Name: sim_matrix - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_matrix is
    Port ( salida : out STD_LOGIC_VECTOR (63 downto 0));
end sim_matrix;

architecture Behavioral of sim_matrix is
    component matriz_celdas is
        Port (  tablero : in STD_LOGIC_VECTOR (127 downto 0);
                Mov_posibles: out STD_LOGIC_VECTOR (63 downto 0));
    end component;

    signal tablero : STD_LOGIC_VECTOR (127 downto 0);
    signal Mov_posibles : STD_LOGIC_VECTOR (63 downto 0);
begin

    matriz: matriz_celdas port map (tablero => tablero , Mov_posibles => salida);

    process
    begin
        -- tablero vacio
        tablero <= (others => '0');
        wait for 1 ns;
        -- siguiendo este esquema podeis poner las casillas que querais:
        -- primero se pone el tablero vacio 
        tablero <= (others => '0');
        -- despues colocas las casillas una a una
        -- en este ejemplo pongo una casilla negra en la posicion (4,4)
        tablero(16*3 + 3*2 +1  downto 16*3 + 3*2) <= "01"; --Blanco
        -- en este una casilla blanca en la posici�n (4,5)
        tablero(16*3 + 4*2+1  downto 16*3 + 4*2) <= "10"; --Negro
        -- pongo una casilla negra en la posici�n (5,4)
        tablero(16*4 + 3*2 +1  downto 16*4 + 3*2) <= "10"; --Negro
        -- en este una casilla blanca en la posici�n (5,5)
        tablero(16*4 + 4*2 +1  downto 16*4 + 4*2) <= "01"; --Blanco
        
        -- finalmente pones un wait para que el resultado se vea
        wait for 1 ns;
        -- Poned unas cuantas casillas con sentido y comprobad que la salida es correcta
        wait;
    end process;

end Behavioral;


