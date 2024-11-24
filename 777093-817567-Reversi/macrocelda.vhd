library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity macro_celda is 
        Port(    
	up_in : in STD_LOGIC_VECTOR (1 downto 0);
        down_in : in STD_LOGIC_VECTOR (1 downto 0);
        left_in : in STD_LOGIC_VECTOR (1 downto 0);
        right_in : in STD_LOGIC_VECTOR (1 downto 0);
        up_left_in : in STD_LOGIC_VECTOR (1 downto 0);
        up_right_in : in STD_LOGIC_VECTOR (1 downto 0);
        down_left_in : in STD_LOGIC_VECTOR (1 downto 0);
        down_right_in : in STD_LOGIC_VECTOR (1 downto 0);
        up_out : out STD_LOGIC_VECTOR (1 downto 0);
        down_out : out STD_LOGIC_VECTOR (1 downto 0);
        left_out : out STD_LOGIC_VECTOR (1 downto 0);
        right_out : out STD_LOGIC_VECTOR (1 downto 0);
        up_left_out : out STD_LOGIC_VECTOR (1 downto 0);
        up_right_out : out STD_LOGIC_VECTOR (1 downto 0);
        down_left_out : out STD_LOGIC_VECTOR (1 downto 0);
        down_right_out : out STD_LOGIC_VECTOR (1 downto 0);
        input : in STD_LOGIC_VECTOR (1 downto 0);
        output : out std_logic
	);
end  macro_celda;

architecture Behavioral of macro_celda is
component celda_base 
Port(
        info_in : in STD_LOGIC_VECTOR (1 downto 0);
        celda : in STD_LOGIC_VECTOR (1 downto 0);
        info_out : out STD_LOGIC_VECTOR (1 downto 0);
        salida : out STD_LOGIC
        );
end component;

        signal up_left_salida : STD_LOGIC;
        signal left_salida : STD_LOGIC;
        signal down_left_salida : STD_LOGIC;
        signal up_right_salida : STD_LOGIC;
        signal right_salida : STD_LOGIC;
        signal down_right_salida : STD_LOGIC;
        signal up_salida : STD_LOGIC;
        signal down_salida : STD_LOGIC;

begin
        microcelda_up_left : celda_base
        port map(
            info_in => up_left_in,
            celda => input,
            info_out => down_right_out,
            salida => up_left_salida
        );

        microcelda_left : celda_base
        port map(
            info_in => left_in,
            celda => input,
            info_out => right_out,
            salida => left_salida
        );

        microcelda_down_left : celda_base
        port map(
            info_in => down_left_in,
            celda => input,
            info_out => up_right_out,
            salida => down_left_salida
        );


        microcelda_up_right : celda_base
        port map(
            info_in => up_right_in,
            celda => input,
            info_out => down_left_out,
            salida => up_right_salida
        );

        microcelda_right : celda_base
        port map(
            info_in => right_in,
            celda => input,
            info_out => left_out,
            salida => right_salida
        );

        microcelda_down_right : celda_base
        port map(
            info_in => down_right_in,
            celda => input,
            info_out => up_left_out,
            salida => down_right_salida
        );

        microcelda_up : celda_base
        port map(
            info_in => up_in,
            celda => input,
            info_out => down_out,
            salida => up_salida
        );

        microcelda_down : celda_base
        port map(
            info_in => down_in,
            celda => input,
            info_out => up_out,
            salida => down_salida
        );

        output <= up_left_salida or left_salida or down_left_salida or up_right_salida or right_salida or down_right_salida or up_salida or down_salida;
        
end Behavioral;


        