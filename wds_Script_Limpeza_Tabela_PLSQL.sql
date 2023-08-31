--
--
-- Como você come um Elefante? Com uma mordida de cada vez.
-- PL/SQl - Expurgo/Limpeza de forma fracionada
--
-- Modo de usar:
--
-- Altere os nomes simbólicos pelas informações referentes a tabela que você deseja realizar a ação.
--
-- 1 - Primeiro realize os testes em um ambiente de Homologação
-- 2 - Para realizar testes no próprio ambiente de produção, você deve manter o comando de DELETE comentado para evitar que ele seja executado.
-- 3 - Existe a variável v_FLAG_REALIZANDO_TESTE que você deve alterar para informar se está em teste ou não.
--
-- 		v_FLAG_REALIZANDO_TESTE
-- 			TRUE -> Em modo Teste 
-- 			FALSE -> Em modo de limpeza
--
-- 4 - Quando você estiver realizando os testes, o DBMS_OUTPUT.PUT_LINE vai imprimir no output do SqlDeveloper o dias que serão afetados pela limpeza e quantos registros serão atingidos nessa ação, desta forma você consegue validar se está de acordo com a sua necessidade.
--
-- O script é bem simples de ser alterado, então você pode usar ele como base para suas ações de Expurgo/Limpeza.
--
--
--

SET SERVEROUTPUT ON;

DECLARE
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos


	CURSOR c_LISTA_ITEM_DELETE IS
		SELECT 
			 DISTINCT
			 TRUNC( NOME_COLUNA_DE_REFERENCIA ) DIA_LIMPEZA
		FROM
			OWNER_USUARIO.TABELA_QUE_VAI_SOFRER_LIMPEZA
		WHERE
			NOME_COLUNA_DE_REFERENCIA < SYSDATE - 60
		ORDER BY DIA_LIMPEZA;
			
			
	v_LISTA_ITEM_DELETE c_LISTA_ITEM_DELETE%ROWTYPE;
		
	v_QTD_DELETE_POR_DATA NUMBER;
	
	v_QTD_DELETE_REALIZADOS NUMBER DEFAULT 0;
	
	v_TOTAL_DELETE NUMBER DEFAULT 0;
    	
    v_QTD_DELETE_COMMIT CONSTANT NUMBER := 30000;
    
	--
	-- TRUE -> Em modo Teste 
	-- FALSE -> Em modo de Expurgo/Limpeza
    v_FLAG_REALIZANDO_TESTE CONSTANT BOOLEAN := TRUE;
    
    
BEGIN


	OPEN c_LISTA_ITEM_DELETE;
	LOOP
	FETCH c_LISTA_ITEM_DELETE INTO v_LISTA_ITEM_DELETE;
	EXIT WHEN c_LISTA_ITEM_DELETE%NOTFOUND;
		
        
        IF v_FLAG_REALIZANDO_TESTE THEN
            
            --
            -- Select para avaliar o WHERE para o DELETE e simular a quantidade de DELETES que serão realizados
            SELECT 
                COUNT( ID_UNICO_TABELA ) INTO v_QTD_DELETE_POR_DATA
            FROM
                OWNER_USUARIO.TABELA_QUE_VAI_SOFRER_LIMPEZA
            WHERE
                ID_UNICO_TABELA IN ( 
                                SELECT 
                                    ID_UNICO_TABELA
                                FROM
                                    OWNER_USUARIO.TABELA_QUE_VAI_SOFRER_LIMPEZA
                                WHERE
                                    NOME_COLUNA_DE_REFERENCIA BETWEEN TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) AND ( TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) + 1 )
                           );
               
            
            --
            -- Em PRODUCAO comentar o DBMS_OUTPUT, senão gera erro buffer overflow
            DBMS_OUTPUT.PUT_LINE( 
                                    'Quantidade de delete: ' 
                                    || v_QTD_DELETE_POR_DATA || ' - Data Inicial: ' 
                                    || TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) || ' - Data Final: ' 
                                    || ( TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) + 1 ) 
                                );
                                                           
        END IF;                   
		
        
        -- Se entrar vai realizar o DELETE
        IF NOT v_FLAG_REALIZANDO_TESTE THEN
                    
            --
            -- Em PRODUCAO remover o comentário do DELETE												 
            --DELETE FROM
            --	OWNER_USUARIO.TABELA_QUE_VAI_SOFRER_LIMPEZA 
            --WHERE
            --	ID_UNICO_TABELA IN ( 
            --					SELECT 
            --						ID_UNICO_TABELA
            --					FROM
            --						OWNER_USUARIO.TABELA_QUE_VAI_SOFRER_LIMPEZA
            --					WHERE
            --						NOME_COLUNA_DE_REFERENCIA BETWEEN TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) AND ( TRUNC( v_LISTA_ITEM_DELETE.DIA_LIMPEZA ) + 1 )
            --			   );
            --
            --
            
            --
            -- Informa a quantidade de registros deletados
            v_QTD_DELETE_POR_DATA := SQL%ROWCOUNT;
                        
        END IF;    
		
		
		v_QTD_DELETE_REALIZADOS := v_QTD_DELETE_REALIZADOS + v_QTD_DELETE_POR_DATA;
		
				
		IF v_QTD_DELETE_REALIZADOS > v_QTD_DELETE_COMMIT THEN
		
		
			COMMIT;
		
		
			v_TOTAL_DELETE := v_TOTAL_DELETE + v_QTD_DELETE_REALIZADOS;
			
			
			v_QTD_DELETE_REALIZADOS := 0;
			
			
            IF v_FLAG_REALIZANDO_TESTE THEN
                
                EXIT;
            
            END IF;    
			
			
		END IF;
		
			
	END LOOP;		
	CLOSE c_LISTA_ITEM_DELETE;
    
    
    --
    -- Em PRODUCAO comentar o DBMS_OUTPUT, senão gera erro buffer overflow
    DBMS_OUTPUT.PUT_LINE( 'Quantidade total de delete: ' || v_TOTAL_DELETE );   

END;
/

