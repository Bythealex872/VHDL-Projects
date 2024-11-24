library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity celda_base is
    Port(
        info_in : in STD_LOGIC_VECTOR (1 downto 0);
        celda : in STD_LOGIC_VECTOR (1 downto 0);
        info_out : out STD_LOGIC_VECTOR (1 downto 0);
        salida : out STD_LOGIC
        );
end celda_base;

architecture Behavioral of celda_base is
    begin 

-- Estado celda
--00-> Vacia
--01-> BLANCO
--10-> NEGRO

-- Estado Patron
--00-> NADA 
--01-> INICIO (Encontramos negra) 
--10 -> CONTINUACION (habiendo encontrado negra, encontramos blaca)
-- Modificar para los valores nuevos
--Pasar Patron (Depende de el estado del patron y estado celda)
--si 00 (Vacia) y CA 00 (NADA) -- 00 (NADA) 
--Si 00 (Vacia) y CA 01 (INICIO) -- 00 (NADA)
--si 00 (Vacia) y CA 10 (CONTINUACION) -- 00 (NADA) //Colocar
--Si 10 (Blanco) y CA 00 (NADA) -- 00 (NADA) 
--si 10 (Blanco) y CA 01 (INICIO) -- 10 (CONTINUACION) 
--Si 10 (Blanco) y CA 10 (CONTINUACION) -- 10 (CONTINUACION)
--si 11 (Negro) y CA 00 (NADA) -- 01 (INICIO) 
--Si 11 (Negro) y CA 01 (INICIO) -- 01 (INICIO)
--si 11 (Negro) y CA 10 (CONTINUACION) -- 01 (INICIO) 


--Salida
--1->colocar
--0->No colocar
-- Si 00 y 11 Salida = 1
-- Esalida Salida = 0



-- If estado = 00 & tengo ficha -> estado = inicio
-- If estado = 01 & ficha distinto color = patron
-- If estado = patron && ficha disntio color = patron 
-- If estado = 

	info_out <= "01" when celda = "10" else -- Si encuentro una ficha negra de inicio del patron
            "10" when celda = "01" and info_in = "01" else -- Si la celda es blanca e inicio patron entonces continuacion 
            "10" when celda = "01" and info_in = "10" else -- Si la celda es blanca y continuacion entonces continuación
            "00";  -- En cualquier otro caso celda vacia. (Celda vacia o celda blanca y recibimos nada)

	salida <= '1' when celda = "00" and info_in = "10" else -- Si info in es continuación e 
        '0';

end Behavioral;

    
