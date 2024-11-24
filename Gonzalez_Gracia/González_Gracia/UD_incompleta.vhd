library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--Mux 4 a 1
entity UD is
    Port ( 	
			Reg_Rs_ID: in  STD_LOGIC_VECTOR (4 downto 0); --registros Rs y Rt en la etapa ID
		  	Reg_Rt_ID	: in  STD_LOGIC_VECTOR (4 downto 0);
			MemRead_EX	: in std_logic; -- info sobre la instrucci'on en EX (destino, si lee de memoria y si escribe en registro)
			RegWrite_EX	: in std_logic;
			RW_EX		: in  STD_LOGIC_VECTOR (4 downto 0);
			RegWrite_Mem	: in std_logic; -- info sobre instruccion en Mem (destino y si escribe en registro)
			RW_Mem		: in  STD_LOGIC_VECTOR (4 downto 0);
			IR_op_code	: in  STD_LOGIC_VECTOR (5 downto 0); -- c'odigo de operaci'on de la instrucci'on en IEEE
         	PCSrc		: in std_logic; -- 1 cuando se produce un salto 0 en caso contrario
			FP_add_EX	: in std_logic; -- Indica si la instrucci'on en EX es un ADDFP
			FP_done		: in std_logic; -- Informa cuando la operaci'on de suma en FP ha terminado
			RegWrite_FP_EX : in std_logic; -- Indica que la instrucci�n en EX escribe en el banco de registros de FP
			RW_FP_EX : in  STD_LOGIC_VECTOR (4 downto 0); -- Indica en qu� registro del banco FP escribe
			RegWrite_FP_MEM : in std_logic; -- Indica que la instrucci�n en EX escribe en el banco de registros de FP
			RW_FP_MEM : in  STD_LOGIC_VECTOR (4 downto 0); -- Indica en qu� registro del banco FP escribe
			Kill_IF		: out  STD_LOGIC; -- Indica que la instrucci'on en IF no debe ejecutarse (fallo en la predicci'on de salto tomado)
			Parar_ID	: out  STD_LOGIC; -- Indica que las etapas ID y previas deben parar
			Parar_EX_FP	: out  STD_LOGIC); -- Indica que las etapas EX y previas deben parar
end UD;
Architecture Behavioral of UD is
signal dep_rs_EX, dep_rs_Mem, dep_rt_EX, dep_rt_Mem, ld_uso_rs, ld_uso_rt, BEQ_rs, BEQ_rt : std_logic;
signal FP_inst, parar_ID_FP, parar_EX_FP_internal, riesgo_rs_FP, riesgo_rt_FP, dep_rs_EX_FP, dep_rt_EX_FP, dep_rs_MEM_FP, dep_rt_MEM_FP : std_logic;
CONSTANT NOP : STD_LOGIC_VECTOR (5 downto 0) := "000000";
CONSTANT LW : STD_LOGIC_VECTOR (5 downto 0) := "000010";
CONSTANT BEQ : STD_LOGIC_VECTOR (5 downto 0) := "000100";
CONSTANT ADDFP : STD_LOGIC_VECTOR (5 downto 0) := "100001";
CONSTANT LWFP : STD_LOGIC_VECTOR (5 downto 0) := "100010";
CONSTANT SWFP : STD_LOGIC_VECTOR (5 downto 0) := "100011";
CONSTANT ADD : STD_LOGIC_VECTOR (5 downto 0) := "000001";
CONSTANT SW : STD_LOGIC_VECTOR (5 downto 0) := "000011";

begin
	dep_rs_EX <= '1' WHEN (RegWrite_EX = '1' AND (Reg_Rs_ID = RW_EX) AND (IR_op_code /= ADDFP AND IR_op_code /= NOP )) else
	'0';
	dep_rs_Mem <= '1' WHEN (RegWrite_Mem = '1' AND (RW_Mem = Reg_Rs_ID) AND (IR_op_code /= ADDFP AND IR_op_code /= NOP ))else
	'0';
	dep_rt_EX <= '1' WHEN (RegWrite_EX = '1' AND (Reg_Rt_ID = RW_EX) AND (IR_op_code = ADD OR IR_op_code = SW OR IR_op_code = BEQ ))else 
	'0';
	dep_rt_Mem <= '1' WHEN (RegWrite_Mem = '1' AND (Reg_Rt_ID = RW_Mem) AND (IR_op_code = ADD AND IR_op_code = SW AND IR_op_code = BEQ ))else 
	'0';
	ld_uso_rs <= '1' WHEN (Reg_Rs_ID = RW_EX AND RegWrite_EX = '1' AND (IR_op_code /= ADDFP AND IR_op_code /= NOP) AND MemRead_EX = '1' ) else
	'0';
	ld_uso_rt <= '1' WHEN (Reg_Rt_ID = RW_EX AND RegWrite_EX = '1' AND (IR_op_code /= ADDFP AND IR_op_code /= NOP AND IR_op_code /= LW) AND MemRead_EX = '1' ) else
	'0';
	BEQ_rs <= '1' WHEN ((dep_rs_EX = '1' OR dep_rs_Mem='1') AND IR_op_code = BEQ ) else 
	'0';
	BEQ_rt <= '1' WHEN ((dep_rt_EX = '1' OR dep_rt_Mem='1') AND IR_op_code = BEQ) else 
	'0';
	FP_inst <= '1' WHEN (IR_op_code = ADDFP OR IR_op_code = LWFP OR IR_op_code = SWFP) else 
	'0'; 
	parar_ID_FP <= '1' WHEN(riesgo_rs_FP = '1' OR riesgo_rt_FP = '1') else 
	'0';
	parar_EX_FP_internal <= '1' WHEN (FP_add_EX = '1' AND FP_done = '0') else 
	'0';
	riesgo_rs_FP <= '1' WHEN((dep_rs_EX_FP = '1') OR (dep_rs_MEM_FP = '1')) else 
	'0';
	riesgo_rt_FP <= '1' WHEN((dep_rt_EX_FP = '1') OR (dep_rt_MEM_FP = '1')) else 
	'0';
	dep_rs_EX_FP <= '1' WHEN((RW_FP_EX = Reg_Rs_ID AND RegWrite_FP_EX = '1') AND (IR_op_code=ADDFP)) else 
	'0';
	dep_rt_EX_FP <= '1' WHEN((RW_FP_EX = Reg_Rt_ID AND RegWrite_FP_EX = '1') AND (IR_op_code=ADDFP OR IR_op_code = SWFP)) else 
	'0';
	dep_rs_MEM_FP <= '1' WHEN((RW_FP_MEM = Reg_Rs_ID AND RegWrite_FP_MEM = '1') AND (IR_op_code=ADDFP)) else 
	'0';
	dep_rt_MEM_FP <= '1' WHEN((RW_FP_MEM = Reg_Rt_ID AND RegWrite_FP_MEM = '1') AND (IR_op_code=ADDFP OR IR_op_code = SWFP)) else 
	'0';
	Kill_IF <= '1' WHEN PCSrc='1' AND BEQ_rs = '0' AND BEQ_rt = '0'  else '0'; -- Se Mata IF cuando se produce un salto 
	Parar_ID <= '1' WHEN (parar_ID_FP = '1' OR ld_uso_rs = '1' OR ld_uso_rt = '1' OR BEQ_rs = '1' OR BEQ_rt = '1') else 
	'0';  -- Indica que las etapas ID y previas deben parar
	parar_EX_FP <= '1' WHEN( parar_EX_FP_internal = '1') else 
	'0'; -- Indica que las etapas EX y previas deben parar
end Behavioral;
