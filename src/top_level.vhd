library ieee;
use ieee.std_logic_1164.all;

entity top_level is
    port (
        entrada_clock : in  std_logic;
        entrada_reset : in  std_logic;
        saida_segmento_esquerdo      : out std_logic_vector(6 downto 0);
        saida_anodo_selecao_esquerdo : out std_logic_vector(3 downto 0);
        saida_segmento_direito       : out std_logic_vector(6 downto 0);
        saida_anodo_selecao_direito  : out std_logic_vector(3 downto 0);
        saida_led_rgb : out std_logic_vector(2 downto 0);
        saida_leds_endereco : out std_logic_vector(1 downto 0); 
        saida_leds_dado     : out std_logic_vector(7 downto 0) 
    );
end entity top_level;

architecture Structure of top_level is
    
    -- ========================================================================
    -- DECLARAÇÃO DOS COMPONENTES
    -- ========================================================================
    
    component maquina_estados is
        port (
            entrada_clock        : in  std_logic;
            entrada_reset        : in  std_logic;
            saida_linha          : out std_logic;
            saida_coluna         : out std_logic;
            saida_write_enable   : out std_logic; 
            saida_reset_memoria  : out std_logic;
            saida_exibir_dado    : out std_logic; 
            saida_numero_dado    : out std_logic_vector(7 downto 0);
            saida_led_rgb        : out std_logic_vector(2 downto 0);
            saida_painel_esquerdo : out std_logic_vector(15 downto 0);
            saida_painel_direito  : out std_logic_vector(15 downto 0) -- CORRIGIDO: 16 bits (4 dígitos)
        );
    end component;
    
    component data_storage_unit is
        -- ... [Resto da declaração] ...
        port (
            clk_in       : in  std_logic;
            rst_in       : in  std_logic;
            write_enable : in  std_logic;
            addr_row     : in  std_logic;
            addr_col     : in  std_logic;
            data_in      : in  std_logic_vector(7 downto 0);
            data_out     : out std_logic_vector(7 downto 0)
        );
    end component;

    component binary_to_bcd_conv is
        port (
            bin_in  : in  std_logic_vector(7 downto 0);
            bcd_out : out std_logic_vector(11 downto 0)
        );
    end component;
    
    component display_manager is
        port (
            entrada_clock    : in  std_logic;
            entrada_reset    : in  std_logic;
            bcd_data_in      : in  std_logic_vector(15 downto 0);
            segment_out      : out std_logic_vector(6 downto 0);
            anode_select_out : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component debounce_button is
        generic (
            DEBOUNCE_TIME : integer := 10000000
        );
        -- ... [Resto da declaração] ...
        port (
            clk_in    : in  std_logic;
            btn_in    : in  std_logic;
            pulse_out : out std_logic
        );
    end component;

    -- ========================================================================
    -- SINAIS INTERNOS
    -- ========================================================================
    signal s_linha           : std_logic;
    signal s_coluna          : std_logic;
    signal s_write_enable    : std_logic;
    signal s_reset_memoria   : std_logic;
    signal s_exibir_dado     : std_logic;
    signal s_numero_dado     : std_logic_vector(7 downto 0);
    signal s_painel_esquerdo  : std_logic_vector(15 downto 0);
    signal s_painel_direito   : std_logic_vector(15 downto 0); -- CORRIGIDO: 16 bits
    
    signal s_memory_output    : std_logic_vector(7 downto 0);
    signal s_bcd_memoria      : std_logic_vector(11 downto 0); 
    signal s_bcd_memoria_lido : std_logic_vector(11 downto 0);
    
    signal s_bcd_dado_escrito : std_logic_vector(15 downto 0); 
    signal s_painel_esq_final : std_logic_vector(15 downto 0);
    signal s_painel_dir_final : std_logic_vector(15 downto 0); -- CORRIGIDO: 16 bits
    
    -- O SINAL s_painel_dir_16bits FOI REMOVIDO POIS É REDUNDANTE
    
    signal s_reset_pulse     : std_logic; 
    signal s_reset_internal  : std_logic; 

begin

    U_DEBOUNCE_RESET: debounce_button
        generic map (DEBOUNCE_TIME => 10000000)
        port map (
            clk_in    => entrada_clock,
            btn_in    => entrada_reset,
            pulse_out => s_reset_pulse
        );
    s_reset_internal <= s_reset_pulse;

    U_MAQUINA: maquina_estados
        port map (
            entrada_clock        => entrada_clock,
            entrada_reset        => s_reset_internal,
            saida_linha          => s_linha,
            saida_coluna         => s_coluna,
            saida_write_enable   => s_write_enable,
            saida_reset_memoria  => s_reset_memoria,
            saida_exibir_dado    => s_exibir_dado, 
            saida_numero_dado    => s_numero_dado,
            saida_led_rgb        => saida_led_rgb,
            saida_painel_esquerdo => s_painel_esquerdo,
            saida_painel_direito  => s_painel_direito -- Conexão direta com o sinal de 16 bits
        );

    U_MEMORIA: data_storage_unit
        port map (
            clk_in       => entrada_clock,
            rst_in       => s_reset_memoria,
            write_enable => s_write_enable,  
            addr_row     => s_linha,
            addr_col     => s_coluna,
            data_in      => s_numero_dado,
            data_out     => s_memory_output
        );

    U_CONVERSOR_ESCRITA: binary_to_bcd_conv
        port map (bin_in => s_numero_dado, bcd_out => s_bcd_memoria);
    
    -- Padding com "1111" (OFF) para apagar o zero à esquerda do dado de escrita
    s_bcd_dado_escrito <= "1111" & s_bcd_memoria; 
    
    U_CONVERSOR_LEITURA: binary_to_bcd_conv
        port map (bin_in => s_memory_output, bcd_out => s_bcd_memoria_lido);

    -- LÓGICA DE EXIBIÇÃO: MUX PAINEL ESQUERDO
    process(s_painel_esquerdo, s_bcd_dado_escrito, s_exibir_dado)
    begin
        if s_exibir_dado = '1' then
            s_painel_esq_final <= s_bcd_dado_escrito; -- Exibe o dado BCD (0XX)
        else
            s_painel_esq_final <= s_painel_esquerdo; -- Exibe o texto da FSM
        end if;
    end process;
    
    -- LÓGICA DE EXIBIÇÃO: MUX PAINEL DIREITO (CORRIGIDO PARA 16 BITS)
    process(s_painel_direito, s_bcd_memoria_lido, s_exibir_dado, s_write_enable)
    begin
        if s_exibir_dado = '1' then
            -- Se for ESCRITA (Wr_En='1'), o painel direito deve apagar (16 bits de OFF)
            if s_write_enable = '1' then
                s_painel_dir_final <= "1111111111111111"; -- 4 dígitos OFF
            else
                -- Se for LEITURA (Wr_En='0'), mostra o dado lido (3 dígitos) + 1 dígito OFF
                s_painel_dir_final <= "1111" & s_bcd_memoria_lido; -- Padding de 4 bits + 12 bits BCD
            end if;
        else
            s_painel_dir_final <= s_painel_direito; -- Exibe o texto da FSM
        end if;
    end process;
    

    U_DISPLAY_ESQUERDO: display_manager
        port map (
            entrada_clock    => entrada_clock,
            entrada_reset    => s_reset_internal,
            bcd_data_in      => s_painel_esq_final,
            segment_out      => saida_segmento_esquerdo,
            anode_select_out => saida_anodo_selecao_esquerdo
        );

    U_DISPLAY_DIREITO: display_manager
        port map (
            entrada_clock    => entrada_clock,
            entrada_reset    => s_reset_internal,
            bcd_data_in      => s_painel_dir_final,
            segment_out      => saida_segmento_direito,
            anode_select_out => saida_anodo_selecao_direito
        );

    -- LEDs DE DEBUG
    saida_leds_endereco(0) <= s_coluna;
    saida_leds_endereco(1) <= s_linha;
    saida_leds_dado <= s_numero_dado;

end architecture Structure;