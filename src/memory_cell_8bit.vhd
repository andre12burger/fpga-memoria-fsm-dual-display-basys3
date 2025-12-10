library ieee;
use ieee.std_logic_1164.all;

entity memory_cell_8bit is
    port (
        -- Entradas de controle
        clk_in       : in  std_logic;
        rst_in       : in  std_logic; -- Reset Ativo Alto
        write_enable : in  std_logic;
        select_col   : in  std_logic; -- Seletor de Coluna
        select_row   : in  std_logic; -- Seletor de Linha

        -- Portas de Dados
        data_in : in  std_logic_vector(7 downto 0);
        q_out   : out std_logic_vector(7 downto 0)
    );
end entity memory_cell_8bit;

architecture Logic of memory_cell_8bit is
    -- Registrador para armazenar o dado
    signal r_storage_reg : std_logic_vector(7 downto 0) := (others => '0');
    -- Registrador para a saída (para garantir lógica síncrona)
    signal r_output_reg  : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- Processo Síncrono de Memória
    process (clk_in, rst_in)
    begin
        -- Reset Assíncrono (Ativo Alto)
        if rst_in = '1' then
            r_storage_reg <= (others => '0');
            r_output_reg  <= (others => '0');
        
        -- Borda de Subida do Clock
        elsif rising_edge(clk_in) then
            
            -- Verifica se esta célula específica está endereçada
            if (select_col = '1' and select_row = '1') then
                
                -- Lógica de Escrita
                if (write_enable = '1') then
                    r_storage_reg <= data_in;
                end if;
                
                -- Lógica de Leitura Síncrona
                if (write_enable = '0') then
                    r_output_reg <= r_storage_reg; -- Coloca o dado armazenado na saída
                else
                    r_output_reg <= (others => '0'); -- Zera a saída durante a escrita
                end if;
            
            else -- Célula não endereçada
                r_output_reg <= (others => '0'); -- Mantém a saída em zero
            end if;
            
        end if;
    end process;

    -- Atribuição final para a porta de saída
    q_out <= r_output_reg;
    
end architecture Logic;