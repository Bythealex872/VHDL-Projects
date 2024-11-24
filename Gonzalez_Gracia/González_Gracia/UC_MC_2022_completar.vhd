---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:18 05/15/2014 
-- Design Name: 
-- Module Name:    UC_slave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: la UC incluye un contador de 2 bits para llevar la cuenta de las transferencias de bloque y una m�quina de estados
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

entity UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit0 : in  STD_LOGIC; --se activa si hay acierto en la via 0
			hit1 : in  STD_LOGIC; --se activa si hay acierto en la via 1
			addr_non_cacheable: in STD_LOGIC; --indica que la direcci�n no debe almacenarse en MC. En este caso porque pertenece a la scratch
			bus_TRDY : in  STD_LOGIC; --indica que el esclavo no puede realizar la operaci�n solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que el esclavo ha reconocido que la direcci�n est� dentro de su rango
			via_2_rpl :  in  STD_LOGIC; --indica que via se va a reemplazar
			Bus_grant :  in  STD_LOGIC; --indica la concesi�n del uso del bus
			Bus_req :  out  STD_LOGIC; --indica la petici�n al �rbitro del uso del bus
         MC_WE0 : out  STD_LOGIC; -- write enable de la VIA0 y 1
         MC_WE1 : out  STD_LOGIC;
         MC_bus_Rd_Wr : out  STD_LOGIC; --1 para escritura en Memoria y 0 para lectura
         MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
         palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1�, 2�...)
         mux_origen: out STD_LOGIC; -- Se utiliza para elegir si el origen de la direcci�n y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
         ready : out  STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habr� que detener el MIPs
         block_addr : out  STD_LOGIC; -- indica si la direcci�n a enviar es la de bloque (rm) o la de palabra (w)
			MC_send_addr_ctrl : out  STD_LOGIC; --ordena que se env�en la direcci�n y las se�ales de control al bus
         MC_send_data : out  STD_LOGIC; --ordena que se env�en los datos
         Frame : out  STD_LOGIC; --indica que la operaci�n no ha terminado
         last_word : out  STD_LOGIC; --indica que es el �ltimo dato de la transferencia
         mux_output: out  STD_LOGIC; -- para elegir si le mandamos al procesador la salida de MC (valor 0)o los datos que hay en el bus (valor 1)
			inc_m : out STD_LOGIC; -- indica que ha habido un fallo
			inc_w : out STD_LOGIC -- indica que ha habido una escritura			
           );
end UC_MC;

architecture Behavioral of UC_MC is


component counter_2bits is
		    Port ( clk : in  STD_LOGIC;
		           reset : in  STD_LOGIC;
		           count_enable : in  STD_LOGIC;
		           count : out  STD_LOGIC_VECTOR (1 downto 0)
					  );
end component;		           
-- Ejemplos de nombres de estado. Poned los vuestros. Nombrad a vuestros estados con nombres descriptivos. As� se facilita la depuraci�n
type state_type is (Inicio, Lectura, Lectura_Ultimo, Arbitro, Escritura, Escritura_No_Cache, single_word_transfer_addr, single_word_transfer_data); 
signal state, next_state : state_type; 
signal last_word_block: STD_LOGIC; --se activa cuando se est� pidiendo la �ltima palabra de un bloque
signal one_word: STD_LOGIC; --se activa cuando s�lo se quiere transferir una palabra
signal count_enable: STD_LOGIC; -- se activa si se ha recibido una palabra de un bloque para que se incremente el contador de palabras
signal hit: std_logic;
signal palabra_UC : STD_LOGIC_VECTOR (1 downto 0);
begin
 
hit <= hit0 or hit1;
 
--el contador nos dice cuantas palabras hemos recibido. Se usa para saber cuando se termina la transferencia del bloque y para direccionar la palabra en la que se escribe el dato leido del bus en la MC
word_counter: counter_2bits port map (clk, reset, count_enable, palabra_UC); --indica la palabra actual dentro de una transferencia de bloque (1�, 2�...)

last_word_block <= '1' when palabra_UC="11" else '0';--se activa cuando estamos pidiendo la �ltima palabra

palabra <= palabra_UC;

-- Registro de estado
   SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            state <= Inicio;
         else
            state <= next_state;
         end if;        
      end if;
   end process;
 
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, hit, last_word_block, bus_TRDY, RE, WE, Bus_DevSel, Bus_grant, via_2_rpl, hit0, hit1, addr_non_cacheable)
   begin
-- valores por defecto, si no se asigna otro valor en un estado valdr�n lo que se asigna aqu�
		MC_WE0 <= '0';
		MC_WE1 <= '0';
		MC_bus_Rd_Wr <= '0';
		MC_tags_WE <= '0';
        ready <= '0';
        mux_origen <= '0';
        MC_send_addr_ctrl <= '0';
        MC_send_data <= '0';
        next_state <= state;  
		count_enable <= '0';
		Frame <= '0';
		block_addr <= '0';
		inc_m <= '0';
		inc_w <= '0';
		Bus_req <= '0';
		one_word <= '0';
		mux_output <= '0';
		last_word <= '0';

        -- Estado Inicio          
      	if (state = Inicio) then
			
			if (RE= '0' and WE= '0') then -- Si no piden nada no hacemos nada
				next_state <= Inicio;
				ready <= '1';

			elsif ( RE= '1' and  hit='1') then -- Si piden y es acierto de lectura mandamos el dato
				next_state <= Inicio;
				ready <= '1';

			elsif ( RE= '1' and  hit='0') then -- Si piden y es fallo de lectura vamos a arbitraje
				next_state <= Arbitro;
				Bus_req <= '1';

			elsif ( WE= '1') then -- Si piden y es escritura vamos a arbitraje
				next_state <= Arbitro;
				Bus_req <= '1';

			end if;
		elsif (state = Arbitro) then -- Estado de Arbitraje
			Bus_req <= '1';-- Solicitamos el bus

			if (Bus_grant = '0') then -- Esperamos al bus
				next_state <= Arbitro;

			elsif (RE= '1') then --Lectura le dan el bus
				next_state <= Lectura;
				inc_m <= not(addr_non_cacheable); -- Aumenta contador de fallos si la dirección es cacheable
				MC_send_addr_ctrl <= '1';
				MC_bus_Rd_Wr <= '0'; --Es lectura
				block_addr <= '1'; -- Vamos a enviar un bloque

			elsif (WE= '1' and  hit='0') then -- Fallo en Escritura le dan el bus
                next_state <= Escritura;
                inc_m <= not(addr_non_cacheable); -- Aumenta contador de fallos si la dirección es cacheable
				inc_w <= '1'; -- Sumamos en el contador de palabras escritas
				MC_send_addr_ctrl <= '1'; -- Enviamos la direccion
				MC_bus_Rd_Wr <= '1'; --Es escritura

			elsif (WE= '1' and  hit='1') then -- Acierto en Escritura le dan el bus
                next_state <= Escritura;
				MC_WE0 <= hit0;-- Escribimos en cache en via 0 si el hit ha sido en la via 0
                MC_WE1 <= hit1;-- Escribimos en cache en via 1 si el hit ha sido en la via 1
				inc_w <= '1'; -- Sumamos en el contador de palabras escritas
				MC_send_addr_ctrl <= '1'; -- Enviamos la direccion
				MC_bus_Rd_Wr <= '1'; --Es escritura
			
			end if;
		elsif (state = Lectura) then -- Estado de Lectura
			Frame <= '1';-- Mantenemos Frame arriba para evitar que nos quiten el bus
			
			if (addr_non_cacheable='1' and bus_TRDY = '1') then -- La direccion no es cacheable y nos dice la scrach que podemos leer.
				next_state <= Inicio;
				mux_output <= '1';								-- Enviamos el dato leido del bus a la MIPS
				ready <= '1';									-- Decimos que hemos terminado
				one_word <= '1';								-- Solo es una palabra
				last_word <= '1';
				
			elsif(addr_non_cacheable='1') then -- La direccion no es cacheable y esperamos a poder leer la dirección se envia la direccion a la scrach.
				next_state <= Lectura;			-- Se envia independientemente de si es DevSel = 1 o a 0.
				MC_send_addr_ctrl <= '1';
				MC_bus_Rd_Wr <= '0'; --Es lectura

			elsif (Bus_DevSel= '0') then --espera a señal DevSel de la MP
				next_state <= Lectura;
				block_addr <= '1'; -- Vamos a enviar un bloque
				MC_send_addr_ctrl <= '1'; -- Enviamos la dirección 
				MC_bus_Rd_Wr <= '0'; --Es lectura

            elsif (bus_TRDY= '0') then --- espera a TRDY
                next_state <= Lectura;

            elsif (bus_TRDY= '1' and last_word_block= '0') then --Comienza transferencia no es última palabra escribimos en MC
                next_state <= Lectura;
                mux_origen <= '1';-- si vale uno el origen es el bus 
                MC_WE0 <= not(via_2_rpl);-- Se activa si la via seleccionada es la 0
                MC_WE1 <= via_2_rpl;-- se activa si la via seleccionada es la 1
                count_enable <= '1';-- se cuanta una nueva palabra transferida

            elsif (bus_TRDY= '1' and last_word_block = '1') then --comienza transferencia es ultima palabraescribimos en MC
                next_state <= Inicio;
                mux_origen <= '1'; -- si vale uno el origen es el bus
                MC_WE0 <= not(via_2_rpl);-- Negado de la via a seleccionar para el 0
                MC_WE1 <= via_2_rpl;-- se activa si la via seleccionada es la 1
				last_word <= '1'; -- Ultima palbara
                count_enable <= '1';-- se cuanta una nueva palabra transferida
                MC_tags_WE <= '1'; -- Apuntamos el Tag del bloque

            end if;
		elsif (state = Escritura) then-- Escribimos
			Frame <= '1'; -- Se mantiene durante todo el proceso

			if (addr_non_cacheable= '1' and Bus_TRDY= '1') then -- La direccion es no cacheable y podemos escribir en memoria scrach.
				next_state <= Inicio;
				MC_send_data <= '1';
				one_word <= '1';-- Solo es una palabra
				ready <= '1';-- Decimos que hemos terminado
				last_word <= '1'; -- Solo es una palabra

			elsif (addr_non_cacheable = '1') then	-- La direccion no es cacheable y esperamos a poder leer la dirección se envia la direccion a la scrach.
				next_state <= Escritura;			-- Se envia independientemente de si es DevSel = 1 o a 0.
				MC_send_addr_ctrl <= '1';
				MC_bus_Rd_Wr <= '1'; --Es Escritura

			elsif (Bus_DevSel= '0') then -- Esperamos a que DevSel sea 1 sin importa si la direccion es cacheable o no.
				next_state <= Escritura;
				MC_send_addr_ctrl <= '1';-- Enviamos la direccion
				MC_bus_Rd_Wr <= '1'; -- 1 escritura

			elsif (Bus_TRDY= '0') then -- Esperamos a que TRDY sea 1 cuando la direccion es cacheable
				next_state <= Escritura;
				
			else -- escribimos en MP 
				next_state <= Inicio;
				MC_send_data <= '1'; -- Escribimos en la memoria
				one_word <= '1'; -- Solo es una palabra
				last_word <= '1';
				ready <= '1';

			end if;
		end if;
   end process;
 
   
end Behavioral;

