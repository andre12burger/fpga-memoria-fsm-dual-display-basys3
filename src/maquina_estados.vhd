library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquina_estados is
    port (
        entrada_clock        : in  std_logic;
        entrada_reset        : in  std_logic; 
        saida_linha          : out std_logic;
        saida_coluna         : out std_logic;
        saida_write_enable   : out std_logic; 
        saida_reset_memoria  : out std_logic;
        
        -- NOVO SINAL: Controla se mostra número ou texto/apagado
        saida_exibir_dado    : out std_logic; 

        saida_numero_dado    : out std_logic_vector(7 downto 0);
        saida_led_rgb        : out std_logic_vector(2 downto 0);
        saida_painel_esquerdo : out std_logic_vector(15 downto 0);
        saida_painel_direito  : out std_logic_vector(15 downto 0)
    );
end entity maquina_estados;

architecture comportamento of maquina_estados is

    type armazenamento_dados is array (0 to 3) of std_logic_vector(7 downto 0);
    constant dados_memoria : armazenamento_dados :=(
        std_logic_vector(to_unsigned(3,8)), 
        std_logic_vector(to_unsigned(25,8)), 
        std_logic_vector(to_unsigned(255,8)),
        std_logic_vector(to_unsigned(42,8)) 
    );

    type tipo_estado is (
        SEGURANCA, AVISO_ESCRITA, 
        ESCRITA_POSICAO_0, ESCRITA_POSICAO_1, ESCRITA_POSICAO_2, ESCRITA_POSICAO_3,
        AVISO_LEITURA, 
        LEITURA_POSICAO_0, LEITURA_POSICAO_1, LEITURA_POSICAO_2, LEITURA_POSICAO_3,
        RESET_MEMORIA, FINAL
    );

    constant tres_segundos : integer := 300000000;
    constant dois_segundos : integer := 200000000;
    constant um_segundo    : integer := 100000000;
    constant meio_segundo  : integer := 50000000;

    signal estado_atual : tipo_estado := SEGURANCA;
    signal proximo_estado : tipo_estado;
    signal contador_universal : integer := 0;
    signal contador_pisca : integer := 0;
    signal tempo_completo : std_logic;
    signal mostra_texto : std_logic := '0';
    signal indice_cor_rgb : integer range 0 to 2;

    -- === CONSTANTES VISUAIS ===
    -- NUMEROS
    constant SEG_0 : std_logic_vector(3 downto 0) := "0000"; -- 0 
    constant SEG_1 : std_logic_vector(3 downto 0) := "0001"; -- 1
    constant SEG_2 : std_logic_vector(3 downto 0) := "0010"; -- 2
    constant SEG_3 : std_logic_vector(3 downto 0) := "0011"; -- 3
    constant SEG_4 : std_logic_vector(3 downto 0) := "0100"; -- 4
    constant SEG_5 : std_logic_vector(3 downto 0) := "0101"; -- 5
    constant SEG_6 : std_logic_vector(3 downto 0) := "0110"; -- 6
    constant SEG_7 : std_logic_vector(3 downto 0) := "0111"; -- 7
    constant SEG_8 : std_logic_vector(3 downto 0) := "1000"; -- 8
    constant SEG_9 : std_logic_vector(3 downto 0) := "1001"; -- 9
    
    -- LETRAS
    constant SEG_A : std_logic_vector(3 downto 0) := "1010"; -- 10
    constant SEG_L : std_logic_vector(3 downto 0) := "1011"; -- 11
    constant SEG_C : std_logic_vector(3 downto 0) := "1100"; -- 12
    constant SEG_r : std_logic_vector(3 downto 0) := "1101"; -- 13
    constant SEG_U : std_logic_vector(3 downto 0) := "1110"; -- 14
    
    -- OFF agora usa o código 1111 (que o display_manager vai apagar)
    constant SEG_OFF : std_logic_vector(3 downto 0) := "1111"; -- 15
    
    -- Adaptações
    constant SEG_I : std_logic_vector(3 downto 0) := SEG_1; 
    constant SEG_E : std_logic_vector(3 downto 0) := SEG_3; 
    constant SEG_S : std_logic_vector(3 downto 0) := SEG_5;
    constant SEG_t : std_logic_vector(3 downto 0) := SEG_7; 
    
    
    -- == LED's ==
    constant COR_OFF      : std_logic_vector(2 downto 0) := "000";
    constant COR_VERMELHO : std_logic_vector(2 downto 0) := "001"; 
    constant COR_VERDE    : std_logic_vector(2 downto 0) := "010";
    constant COR_AZUL     : std_logic_vector(2 downto 0) := "100";
    
    -- Cores Mistas (Combinando os canais)
    constant COR_AMARELO  : std_logic_vector(2 downto 0) := "011"; -- Vermelho + Verde
    constant COR_MAGENTA  : std_logic_vector(2 downto 0) := "101"; -- Vermelho + Azul
    constant COR_CIANO    : std_logic_vector(2 downto 0) := "110"; -- Verde + Azul
    constant COR_BRANCO   : std_logic_vector(2 downto 0) := "111"; -- Tudo ligado
    
begin

    process(entrada_clock, entrada_reset)
    begin
        if entrada_reset = '1' then
            contador_universal <= 0;
        elsif rising_edge(entrada_clock) then
            case estado_atual is
                when SEGURANCA | AVISO_ESCRITA | ESCRITA_POSICAO_0 | ESCRITA_POSICAO_1 | 
                     ESCRITA_POSICAO_2 | ESCRITA_POSICAO_3 | AVISO_LEITURA | LEITURA_POSICAO_0 | 
                     LEITURA_POSICAO_1 | LEITURA_POSICAO_2 | LEITURA_POSICAO_3 | RESET_MEMORIA =>
                    if contador_universal >= tres_segundos - 1 then
                        contador_universal <= 0;
                    else
                        contador_universal <= contador_universal + 1;
                    end if;
                when FINAL =>
                    if contador_universal >= tres_segundos - 1 then
                        contador_universal <= 0;
                    else
                        contador_universal <= contador_universal + 1;
                    end if;
            end case;
        end if;
    end process;

    process(entrada_clock, entrada_reset)
    begin
        if entrada_reset = '1' then
            contador_pisca <= 0;
            mostra_texto <= '0';
        elsif rising_edge(entrada_clock) then
            contador_pisca <= contador_pisca + 1;
            if contador_pisca >= meio_segundo - 1 then
                contador_pisca <= 0;
                mostra_texto <= not mostra_texto;
            end if;
        end if;
    end process;

    tempo_completo <= '1' when contador_universal >= tres_segundos - 1 else '0';
    indice_cor_rgb <= 0 when contador_universal < um_segundo else
                      1 when contador_universal < dois_segundos else 2;

    process(entrada_clock, entrada_reset)
    begin
        if entrada_reset = '1' then
            estado_atual <= SEGURANCA;
        elsif rising_edge(entrada_clock) then
            estado_atual <= proximo_estado;
        end if;
    end process;

    process(estado_atual, tempo_completo)
    begin
        proximo_estado <= estado_atual;
        case estado_atual is
            when SEGURANCA => if tempo_completo = '1' then proximo_estado <= AVISO_ESCRITA; end if;
            when AVISO_ESCRITA => if tempo_completo = '1' then proximo_estado <= ESCRITA_POSICAO_0; end if;
            when ESCRITA_POSICAO_0 => if tempo_completo = '1' then proximo_estado <= ESCRITA_POSICAO_1; end if;
            when ESCRITA_POSICAO_1 => if tempo_completo = '1' then proximo_estado <= ESCRITA_POSICAO_2; end if;
            when ESCRITA_POSICAO_2 => if tempo_completo = '1' then proximo_estado <= ESCRITA_POSICAO_3; end if;
            when ESCRITA_POSICAO_3 => if tempo_completo = '1' then proximo_estado <= AVISO_LEITURA; end if;
            when AVISO_LEITURA => if tempo_completo = '1' then proximo_estado <= LEITURA_POSICAO_0; end if;
            when LEITURA_POSICAO_0 => if tempo_completo = '1' then proximo_estado <= LEITURA_POSICAO_1; end if;
            when LEITURA_POSICAO_1 => if tempo_completo = '1' then proximo_estado <= LEITURA_POSICAO_2; end if;
            when LEITURA_POSICAO_2 => if tempo_completo = '1' then proximo_estado <= LEITURA_POSICAO_3; end if;
            when LEITURA_POSICAO_3 => if tempo_completo = '1' then proximo_estado <= RESET_MEMORIA; end if;
            when RESET_MEMORIA => if tempo_completo = '1' then proximo_estado <= FINAL; end if;
            when FINAL => proximo_estado <= FINAL;
        end case;
    end process;

    process(estado_atual, mostra_texto, indice_cor_rgb)
    begin
        saida_linha <= '0'; saida_coluna <= '0';
        saida_write_enable <= '0'; saida_reset_memoria <= '0';
        saida_exibir_dado <= '0'; -- Só ativa quando for mostrar o número da memória
        saida_numero_dado <= (others => '0');
        saida_led_rgb <= COR_OFF;
        
        -- PADRÃO: Tudo APAGADO (SEG_OFF)
        saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
        saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF; 

        case estado_atual is
            when SEGURANCA =>
                if mostra_texto = '1' then
                    saida_painel_esquerdo <= SEG_8 & SEG_8 & SEG_8 & SEG_8;
                    saida_painel_direito <= SEG_8 & SEG_8 & SEG_8 & SEG_8;
                    saida_led_rgb <= COR_AMARELO;
                else
                    saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_led_rgb <= COR_OFF;
                end if;

            when AVISO_ESCRITA =>            
                if mostra_texto = '1' then
                    saida_painel_esquerdo <= SEG_E & SEG_5 & SEG_C & SEG_r;
                    saida_painel_direito <= SEG_I & SEG_t & SEG_A & SEG_OFF; -- "ItA"
                else
                    -- Pisca Apagado
                    saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                end if;

            when ESCRITA_POSICAO_0 =>
                saida_write_enable <= '1'; saida_exibir_dado <= '1';
                saida_numero_dado <= dados_memoria(0);
                saida_linha <= '0'; saida_coluna <= '0';
                
                saida_led_rgb <= COR_VERDE;
                
            when ESCRITA_POSICAO_1 =>
                saida_write_enable <= '1'; saida_exibir_dado <= '1';
                saida_numero_dado <= dados_memoria(1);
                saida_linha <= '0'; saida_coluna <= '1';
                
                saida_led_rgb <= COR_VERDE;

            when ESCRITA_POSICAO_2 =>
                saida_write_enable <= '1'; saida_exibir_dado <= '1';
                saida_numero_dado <= dados_memoria(2);
                saida_linha <= '1'; saida_coluna <= '0';
                
                saida_led_rgb <= COR_VERDE;

            when ESCRITA_POSICAO_3 =>
                saida_write_enable <= '1'; saida_exibir_dado <= '1';
                saida_numero_dado <= dados_memoria(3);
                saida_linha <= '1'; saida_coluna <= '1';
                
                saida_led_rgb <= COR_VERDE;

            when AVISO_LEITURA =>
                if mostra_texto = '1' then
                    saida_painel_esquerdo <= SEG_L & SEG_E & SEG_I & SEG_t;
                    saida_painel_direito <= SEG_U & SEG_r & SEG_A & SEG_OFF; -- "0rA" (UrA)
                else
                    saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                end if;

            when LEITURA_POSICAO_0 =>
                saida_exibir_dado <= '1';
                saida_linha <= '0'; saida_coluna <= '0';
                
                saida_led_rgb <= COR_AZUL;

            when LEITURA_POSICAO_1 =>
                saida_exibir_dado <= '1';
                saida_linha <= '0'; saida_coluna <= '1';
                
                saida_led_rgb <= COR_AZUL;

            when LEITURA_POSICAO_2 =>
                saida_exibir_dado <= '1';
                saida_linha <= '1'; saida_coluna <= '0';
                
                saida_led_rgb <= COR_AZUL;

            when LEITURA_POSICAO_3 =>
                saida_exibir_dado <= '1';
                saida_linha <= '1'; saida_coluna <= '1';
                
                saida_led_rgb <= COR_AZUL;

            when RESET_MEMORIA =>
                saida_reset_memoria <= '1';
                if mostra_texto = '1' then
                    saida_painel_esquerdo <= SEG_OFF & SEG_0 & SEG_0 & SEG_0;
                    saida_painel_direito <= SEG_OFF & SEG_0 & SEG_0 & SEG_0;
                    saida_led_rgb <= COR_VERMELHO;
                else
                    saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                    saida_led_rgb <= COR_OFF;
                end if;

            when FINAL =>
                case indice_cor_rgb is
                    when 0 => saida_led_rgb <= COR_VERMELHO;
                    when 2 => saida_led_rgb <= COR_VERDE;
                    when 1 => saida_led_rgb <= COR_AZUL;
                end case;
                saida_painel_esquerdo <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
                saida_painel_direito <= SEG_OFF & SEG_OFF & SEG_OFF & SEG_OFF;
        end case;
    end process;
end architecture comportamento;