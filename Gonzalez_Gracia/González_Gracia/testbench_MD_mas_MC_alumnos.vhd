-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  use IEEE.std_logic_arith.all;
  use IEEE.std_logic_unsigned.all;


  ENTITY testbench_MD_mas_MC IS
  END testbench_MD_mas_MC;

  ARCHITECTURE behavior OF testbench_MD_mas_MC IS 

  -- Component Declaration
  COMPONENT MD_mas_MC is port (
		  CLK : in std_logic;
		  reset: in std_logic; -- s�lo resetea el controlador de DMA
		  ADDR : in std_logic_vector (31 downto 0); --Dir 
          Din : in std_logic_vector (31 downto 0);--entrada de datos desde el Mips
          WE : in std_logic;		-- write enable	del MIPS
		  RE : in std_logic;		-- read enable del MIPS	
		   IO_input: in std_logic_vector (31 downto 0); --dato que viene de una entrada del sistema
		  Mem_ready: out std_logic; -- indica si podemos hacer la operaci�n solicitada en el ciclo actual
		  Dout : out std_logic_vector (31 downto 0)); --salida que puede leer el MIPS
end COMPONENT;

          SIGNAL clk, reset, RE, WE, Mem_ready :  std_logic;
          signal ADDR, Din, Dout, IO_input : std_logic_vector (31 downto 0);
         
			           
  -- Clock period definitions
   constant CLK_period : time := 10 ns;
  BEGIN

  -- Component Instantiation
   uut: MD_mas_MC PORT MAP(clk=> clk, reset => reset, ADDR => ADDR, Din => Din, RE => RE, WE => WE, IO_input => IO_input, Mem_ready => Mem_ready, Dout => Dout);

-- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;

 stim_proc: process
   begin		
      		
    	reset <= '1';
  	   	ADDR <= conv_std_logic_vector(0, 32);--conv_std_logic_vector convierte el primer n�mero (un 0) a un vector de tantos bits como se indiquen (en este caso 32 bits)
  	   	Din <= conv_std_logic_vector(64, 32);
		-- IO_input. Lo voy a ir cambiando para que se vea como cambia en el scratch
  	   	IO_input <= conv_std_logic_vector(1024, 32);
  	   	RE <= '0';
		WE <= '0';
	  	wait for 20 ns;	
	  	reset <= '0';
	  	RE <= '1';
	  	ADDR <= conv_std_logic_vector(16, 32); -- Fallo en lectura escribe en el conjunto 1 en la via 0 los valores 1,2,3,4
	  	wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; --Este wait espera hasta que se ponga Mem_ready a uno
	  	end if;
		wait for clk_period;
      	ADDR <= conv_std_logic_vector(80, 32); --Fallo en lectura escribe en el conjunto 1 en la via 1 los valores 5,6,7,8
	  	wait for 1ns;
      	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		-- IO_input. Segundo valor
		IO_input <= conv_std_logic_vector(2048, 32);
		ADDR <= conv_std_logic_vector(144, 32); --Fallo en lectura remplaza en el conjunto 1 en la via 0 los valores 10,9,8,2
		RE <= '1';
		WE <= '0';
		-- La idea de estos wait es esperar a que la se�al Mem_ready se active (y si ya est� activa no hacer nada)
		wait for 1ns;
        if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		IO_input <= conv_std_logic_vector(4096, 32);
		ADDR <= conv_std_logic_vector(272, 32); --Debe ser un fallo en lectura remplaza en el conjunto 1 en la via 1 los valores f,e,d,c
		RE <= '1';
		WE <= '0';
		wait for 1ns;
        if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		-- IO_input. Tercer valor
		IO_input <= conv_std_logic_vector(4096, 32);
		ADDR <= conv_std_logic_vector(32, 32); --Debe ser un fallo de lectura y almacenarse 4, 5, 6 y 7 en el cjto 2 en la via 0
		RE <= '1';
		WE <= '0';
		wait for 1ns;
      	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
       	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(20, 32); --Fallo en escritura, escribe en MP 64 en la direccion @5
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(148, 32); -- Acierto en escritura se escribe en el conjunto 1 via 0 en la segunda palabra y en MP en @37
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(274, 32); --Acierto en lectura devuelve la tercera palabra del conjunto 1 de la via 1
		RE <= '1';
		WE <= '0';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(380, 32); -- Fallo en escritura se escribe en MP en @95
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		
		wait for clk_period;
		ADDR <= x"10000010"; --Lectura de la memoria scratch (no cacheable). Se debe leer FF de la posici�n 4
		RE <= '0';
		WE <= '1';
		wait for 1ns;
		ADDR <= x"100000fc"; --Escritura en la memoria scratch (no cacheable). Se debe escribir 64 en la posici�n @63
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(496, 32); --Fallo en lectura almacena en el conjunto 3 de la via 0 los datos 1, 5, 10, 15
		RE <= '1';
		WE <= '0';
		wait for 1ns;
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real	  
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(152, 32); -- Acierto en escritura se escribe en el conjunto 1 via 0 en la tercera palabra y en MP en @38
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		
		wait for clk_period;
		ADDR <= x"100000fc"; --Leemos el valor que ha escrito Master_IO. El �ltimo es X"00001000"
		RE <= '1';
		WE <= '0';
		wait for 1ns;
		-- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real	
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		ADDR <= conv_std_logic_vector(480, 32); -- Fallo en escritura se escribe en  MP en @120
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecer� el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		
		wait for clk_period;
		ADDR <= x"10000010"; --Leemos el valor que ha escrito Master_IO. El �ltimo es X"00001000"
		RE <= '1';
		WE <= '0';
		wait for 1ns;
--Si no cambiamos los valores nos quedamos pidiendo todo el rato el mismo valor a la memoria scratch. Se puede ver como una y otra vez habr� que esperar a que la memoria lo envie. Ya que al no ser cacheable no se almacena en MC
	  	wait;
   end process;


  END;
