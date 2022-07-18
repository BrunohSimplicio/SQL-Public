CREATE Function [dbo].[Digito_Cnpj](@Cnpj numeric(12))  
Returns Numeric(2)  
As  
Begin  
  
Declare @Cnpj_Texto As Varchar(13)  
Set @Cnpj_Texto = Replicate('0', 12 - Len(@Cnpj) ) + Convert(Varchar(12), @Cnpj)  
  
Declare @Calculador Varchar(13)   
Set @Calculador = '543298765432'  
Declare @Digito Varchar(2)   
Set @Digito = ''  
Declare @cont tinyint   
Set @cont = 1  
Declare @Soma int   
Set @Soma = 0  
Declare @Laco tinyint   
Set @Laco = 12  
Declare @Soma_Dividida int  
  
Laco:  
While @cont <= @Laco  
Begin  
 Set @Soma = @Soma + Convert(tinyint, Substring(@Cnpj_Texto, @cont, 1)) * Convert(tinyint, Substring(@Calculador, @cont, 1))  
 Set @cont = @cont + 1  
End  
  
Set @cont = 1  
  
Set @Soma_Dividida = @Soma % 11  
  
If @Soma_Dividida < 2  
 Set @Digito = @Digito + '0'  
else  
 Set @Digito = @Digito + Convert(Varchar(1), (11 - @Soma_Dividida))  
  
Set @Soma = 0  
  
IF Len(@Digito) < 2  
Begin  
 Set @Laco = 13  
 Set @Calculador = '6' + @Calculador  
 Set @Cnpj_Texto = @Cnpj_Texto + @Digito  
 Goto Laco  
End  
  
Return Convert(Numeric(2), @Digito)  
  
End
