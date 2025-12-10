library ieee;                  
use ieee.std_logic_1164.all;

entity data_storage_unit is
    port (
        clk_in       : in  std_logic;
        rst_in       : in  std_logic;
        write_enable : in  std_logic;
        addr_row     : in  std_logic;
        addr_col     : in  std_logic;
        data_in      : in  std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0)
    );
end entity data_storage_unit;

architecture Structure of data_storage_unit is

    -- Declaração dos Componentes
    component address_decoder is
        port (
            sel_in : in  std_logic;
            sel_out : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component memory_cell_8bit is
        port (
            clk_in       : in  std_logic;
            rst_in       : in  std_logic;
            write_enable : in  std_logic;
            select_col   : in  std_logic;
            select_row   : in  std_logic;
            data_in      : in  std_logic_vector(7 downto 0);
            q_out        : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component output_multiplexer is
        port(
            mux_sel   : in std_logic;
            data_in_A : in std_logic_vector(7 downto 0);
            data_in_B : in std_logic_vector(7 downto 0);
            mux_out   : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Sinais Internos
    signal w_row_selects : std_logic_vector(1 downto 0);
    signal w_col_selects : std_logic_vector(1 downto 0);
    signal w_cell0_data, w_cell1_data, w_cell2_data, w_cell3_data : std_logic_vector(7 downto 0);
    signal w_col0_bus      : std_logic_vector(7 downto 0);
    signal w_col1_bus      : std_logic_vector(7 downto 0);
    signal w_selected_col_data : std_logic_vector(7 downto 0);
    signal w_zero_bus      : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- Decodificadores de Endereço
    ROW_DECODER: address_decoder port map (sel_in => addr_row, sel_out => w_row_selects);
    COL_DECODER: address_decoder port map (sel_in => addr_col, sel_out => w_col_selects);

    -- Instâncias das 4 Células de Memória
    CELL_0_0: memory_cell_8bit port map (
            clk_in => clk_in, rst_in => rst_in, write_enable => write_enable, data_in => data_in, 
            select_col => w_col_selects(0), select_row => w_row_selects(0), q_out => w_cell0_data );
            
    CELL_0_1: memory_cell_8bit port map (
            clk_in => clk_in, rst_in => rst_in, write_enable => write_enable, data_in => data_in, 
            select_col => w_col_selects(1), select_row => w_row_selects(0), q_out  => w_cell1_data );
            
    CELL_1_0: memory_cell_8bit port map (
            clk_in => clk_in, rst_in => rst_in, write_enable => write_enable, data_in => data_in, 
            select_col => w_col_selects(0), select_row => w_row_selects(1), q_out  => w_cell2_data );
            
    CELL_1_1: memory_cell_8bit port map (
            clk_in => clk_in, rst_in => rst_in, write_enable => write_enable, data_in => data_in, 
            select_col => w_col_selects(1), select_row => w_row_selects(1), q_out  => w_cell3_data );

    -- Lógica de Leitura (Barramentos Verticais)
    w_col0_bus <= w_cell0_data or w_cell2_data; -- (Célula 0,0 OU Célula 1,0)
    w_col1_bus <= w_cell1_data or w_cell3_data; -- (Célula 0,1 OU Célula 1,1)
    
    -- MUX de Coluna: Seleciona o barramento da coluna
    COL_MUX: output_multiplexer
        port map (
            mux_sel   => addr_col,
            data_in_A => w_col0_bus,      -- Entrada 0
            data_in_B => w_col1_bus,      -- Entrada 1
            mux_out   => w_selected_col_data
        );

    -- MUX Final: Zera a saída durante a escrita
    -- Lógica: Usar write_enable direto e invertemos as entradas A e B
    FINAL_MUX: output_multiplexer
        port map (
            mux_sel   => write_enable,        -- Se '1' (Escrita), seleciona B. Se '0' (Leitura), seleciona A.
            data_in_A => w_selected_col_data, -- Entrada A (Selecionada quando write_enable = '0') -> LEITURA
            data_in_B => w_zero_bus,          -- Entrada B (Selecionada quando write_enable = '1') -> ESCRITA (Zeros)
            mux_out   => data_out
        );
end architecture Structure;