INSERT INTO CONVENIOS_PRODUTOS

           (ENTIDADE,
            PRODUTO,
            TIPO,
            DESCONTO_PRODUTO,
            CO_PAGAMENTO,
            DESCONTO_PRAZO
            )


SELECT 
       ENTIDADE,
	   PRODUTO,
	   TIPO,			
	   DESCONTO,
	   CO_PAGAMENTO,
	   0
 FROM NOME_LINKES_SERVER.NOME_BANCO.DBO.NOMETABELA

--sp_linkedservers
