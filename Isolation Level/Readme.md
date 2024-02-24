# Transaction Isolation Level
Fala galera, os Níveis de Isolamento (ou Transaction Isolation Level, do Inglês) não são apenas transações criadas para validar se um processamento gerou erro ou não, talvez você não esteja usando o Transaction Isolation Level corretamente. Vejo muita gente usando somente o BEGIN TRAN e COMMIT/ROLLBACK pensando que estão usando transações de forma correta, afinal, se der algum problema durante o processamento ele pode voltar com um ROLLBACK e tudo estará tudo como antes.

Bom, por exemplo, olhar somente por essa ótica pode estar errado! Acima de tudo pelo fato do Isolation Level ter causas/efeitos mais profundos do que somente garantir que a transação que está rodando no momento dê erro ou não.

Vale lembrar que o SQL Server é um SGBD que implementa o conceito de ACID (Atomicidade, Consistência, Isolamento e Durabilidade) e os níveis de isolamento atuam diretamente neste conceito. Outra coisa que é bom lembrar é que os níveis de isolamento impactam diretamente na quantidade de LOCKs e WAITs gerados no SQL.

Por padrão, o SQL Server tem o Isolation Level configurado para READ COMMITED. Isso pode ser confirmado rodando esta linha de código abaixo, e encontrando o resultado de ISOLATION LEVEL.

```SQL
DBCC USEROPTIONS
```

# Usando o Transaction Isolation Level corretamente
Para exemplificar estas explicações, e saber se está usando o Transaction Isolation Level corretamente, abra uma conexão com o SQL Server e execute o código abaixo. Ele irá criar um database e duas tabelas com alguns dados, onde serão explicados os tipos de isolamentos e de quebra um exemplo de dead lock.

Quando alteramos o nivel de isolamento, ele é aplicado à conexão que o alterou. Se você abrir uma nova conexão com o SQL Server e verificar qual é o nivel de isolamento desta transação, você verá que voltou para o padrão. Read Committed.

# Transaction Isolation Level – Read Commited
> [!NOTE]
> Este é o isolation level default usado pelo SQL

O READ COMMITTED nos garante uma leitura somente do que já está “commitado” no banco, isso é, garante que o dado que está sendo lido foi realmente escrito no banco e não é uma leitura suja ou fantasma, causado por alguma outra transação. Pelo fato dele só ler as informações realmente escritas no banco, se uma outra transação estiver trabalhando com a tabela que você quer ler, o SQL irá esperar a transação liberar a tabela para então fazer a leitura. Isso gera LOCK (pela outra transação) e WAIT (pela sua).

Para entender na prática esse tipo de isolamento, abra duas conexões diferentes com a mesma tabela. Execute o primeiro bloco de código em uma delas, contanto que o segundo bloco seja executado segunda conexão. Após iniciar a execução do primeiro, vá até a segunda conexão e execute em simultâneo, deixando ambas rodando. Você irá ver o SQL Server terminar de executar a primeira transação para então iniciar a segunda.

```SQL
/*********  RODAR NA CONEXÃO 1 *********/
BEGIN TRAN

 UPDATE DimEmployee 
    SET MiddleName = 'Teste 1' 
  WHERE EmployeeKey = 1
WAITFOR DELAY '00:00:10'

--ROLLBACK

/*********  RODAR NA CONEXÃO 2 *********/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SELECT * FROM tbIsolationLevel
```
> [!IMPORTANT]
> Se a consulta 2 for executada filtrando apenas o EmployeeKey <> 1 os valores serão retornados e não ocorrerá lock.

# Transaction Isolation Level – Read Uncommited
O READ UNCOMMITTED evita que o SQL Server dê um LOCK na tabela de leitura por causa de uma transação, isso faz com que também não gere um WAIT em outra transação. Porém, este processo permite uma leitura suja dos dados, entregando a informação “errada” em alguns cenários. Quando se utiliza este nível de isolamento, é possível ler os dados de uma tabela mesmo ela sendo utilizada dentro de uma transação longa que executa vários processos (INSERTS, UPDATES e DELETES). Estes passos intermediários que são executados antes do COMMIT no final, podem ser lidos e retornados. Quando isso acontece, chamamos de leitura suja (Dirty Read, do inglês).

```SQL
/*********  RODAR NA CONEXÃO 1 *********/
BEGIN TRAN

 UPDATE DimEmployee 
    SET MiddleName = 'Teste 1' 
  WHERE EmployeeKey = 1
WAITFOR DELAY '00:00:10'

--ROLLBACK
```
No código abaixo existem duas consultas. Ambas podem ler dados sujos, a primeira alterando o isolation level e a segundo consumindo dados com o hint WITH (NOLOCK). No final, o resultado de ambas serão os mesmos.

```sql
/*********  RODAR NA CONEXÃO 2 *********/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT * FROM DimEmployee

-- Usando o hint NOLOCK
SELECT * FROM DimEmployee WITH(NOLOCK)
```

# Transaction Isolation Level – Repeatable Read
Já o REPEATABLE READ garante que a transação que leia uma tabela mais do que uma vez dentro desta mesma transação, possa fazer isso sem ler dados diferentes dos registros já encontrados da primeira vez. Nenhuma alteração (UPDATE) dos dados já lidos anteriormente serão modificados na leitura (são alterados na tabela), mas novos registros (INSERT) são retornados nesta segunda leitura.

```SQL
/********* RODAR NA CONEXÃO 1 *********/
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN
  
  SELECT * FROM DimEmployee WHERE ParentEmployeeKey = 18 and LoginID = 'adventure-works\guy1'
  WAITFOR DELAY '00:00:10'
  
  SELECT * FROM DimEmployee WHERE ParentEmployeeKey = 18 and LoginID = 'adventure-works\guy1'
  
  rollback
```
Veja o SQL Server gerando um WAIT para executar o UPDATE, mas não o gera quando roda o INSERT, ele simplesmente insere os dados.

```SQL
/********* RODAR NA CONEXÃO 2 *********/
-- Update
 UPDATE DimEmployee 
    SET MiddleName = 'Teste 1' 
  WHERE EmployeeKey = 1


--Insert
INSERT INTO DimEmployee 
(
       ParentEmployeeKey
     , EmployeeNationalIDAlternateKey
     , ParentEmployeeNationalIDAlternateKey
     , SalesTerritoryKey
     , FirstName
     , LastName
     , MiddleName
     , NameStyle
     , Title
     , HireDate
     , BirthDate
     , LoginID
     , EmailAddress
     , Phone
     , MaritalStatus
     , EmergencyContactName
     , EmergencyContactPhone
     , SalariedFlag
     , Gender
     , PayFrequency
     , BaseRate
     , VacationHours
     , SickLeaveHours
     , CurrentFlag
     , SalesPersonFlag
     , DepartmentName
     , StartDate
     , EndDate
     , Status
     , EmployeePhoto
)
SELECT ParentEmployeeKey
     , EmployeeNationalIDAlternateKey
     , ParentEmployeeNationalIDAlternateKey
     , SalesTerritoryKey
     , 'Teste' as FirstName
     , 'Isolation' as LastName
     , 'Level' as MiddleName
     , NameStyle
     , Title
     , HireDate
     , BirthDate
     , LoginID
     , EmailAddress
     , Phone
     , MaritalStatus
     , EmergencyContactName
     , EmergencyContactPhone
     , SalariedFlag
     , Gender
     , PayFrequency
     , BaseRate
     , VacationHours
     , SickLeaveHours
     , CurrentFlag
     , SalesPersonFlag
     , DepartmentName
     , StartDate
     , EndDate
     , Status
     , EmployeePhoto 
  FROM DimEmployee 
 WHERE EmployeeKey = 1
```
# Transaction Isolation Level – Serializable
Uma variação mais completa do REPEATABLE READ é o SERIALIZABLE que bloqueia qualquer modificação de dados nas colunas que são consultadas, independente da modificação ser um UPDATE ou um INSERT. Este nível de isolamento causa um LOCK na transação original e um WAIT na segunda transação tanto para o UPDATE quanto para INSERT.

Veja este processo nos códigos abaixo:
```SQL
/*********  RODAR NA CONEXÃO 1 *********/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRAN
  
  SELECT * FROM DimEmployee WHERE ParentEmployeeKey = 18 and LoginID = 'adventure-works\guy1'
  WAITFOR DELAY '00:00:10'
  
  SELECT * FROM DimEmployee WHERE ParentEmployeeKey = 18 and LoginID = 'adventure-works\guy1'
  
  rollback
```
```sql
/********* RODAR NA CONEXÃO 2 *********/
-- Update
 UPDATE DimEmployee 
    SET MiddleName = 'Teste 1' 
  WHERE EmployeeKey = 1


--Insert
INSERT INTO DimEmployee 
(
       ParentEmployeeKey
     , EmployeeNationalIDAlternateKey
     , ParentEmployeeNationalIDAlternateKey
     , SalesTerritoryKey
     , FirstName
     , LastName
     , MiddleName
     , NameStyle
     , Title
     , HireDate
     , BirthDate
     , LoginID
     , EmailAddress
     , Phone
     , MaritalStatus
     , EmergencyContactName
     , EmergencyContactPhone
     , SalariedFlag
     , Gender
     , PayFrequency
     , BaseRate
     , VacationHours
     , SickLeaveHours
     , CurrentFlag
     , SalesPersonFlag
     , DepartmentName
     , StartDate
     , EndDate
     , Status
     , EmployeePhoto
)
SELECT ParentEmployeeKey
     , EmployeeNationalIDAlternateKey
     , ParentEmployeeNationalIDAlternateKey
     , SalesTerritoryKey
     , 'Teste' as FirstName
     , 'Isolation' as LastName
     , 'Level' as MiddleName
     , NameStyle
     , Title
     , HireDate
     , BirthDate
     , LoginID
     , EmailAddress
     , Phone
     , MaritalStatus
     , EmergencyContactName
     , EmergencyContactPhone
     , SalariedFlag
     , Gender
     , PayFrequency
     , BaseRate
     , VacationHours
     , SickLeaveHours
     , CurrentFlag
     , SalesPersonFlag
     , DepartmentName
     , StartDate
     , EndDate
     , Status
     , EmployeePhoto 
  FROM DimEmployee 
 WHERE EmployeeKey = 1
```
# Transaction Isolation Level – Snapshot
Uma alternativa para evitar LOCK e WAIT nas tabelas, e também garantir que os dados modificados sejam escritos e não tenha leitura suja é o SNAPSHOT. Ele permite tal ação porque ele copia os dados alterados para a tempdb, possibilitando ler os dados originais durante a transação, mesmo que eles sejam alterados. Quando uma transação tem um snapshot, ela coloca uma flag em todos os registros, para garantir que não foram alterados. Caso isso ocorra, ela altera a flag.

Veja na imagem abaixo a explicação deste processo.

Com o snapshot habilitado no banco, e setado na transação, ele lê os dados originais da tabela mesmo sofrendo modificações por outra transação.

Se os dados lidos não sofrerem nenhuma alteração, nada é escrito na tempDB.

![image](https://github.com/BrunohSimplicio/SQL-Public/assets/103937135/3a8d9a61-af1e-4822-bfda-8bda8fbb03db)

Tabela com dados preenchidos

Porém, se algum dado for modificado, o SQL Server continua lendo a tabela. Será lida a versão original do dado que foi modificado já que ele foi copiado para a TempDB. Na hora da leitura, o SQL se encarrega de ler a TempDB e recuperar o dado original.

![image](https://github.com/BrunohSimplicio/SQL-Public/assets/103937135/7996f15a-6984-4d9a-b237-38544cd04111)

Tabela com uma mudança de dados

Esta funcionalidade, por padrão, vem desabilitada do banco de dados, e para utilizar, é necessário habilitar fazendo uma alteração no database. No código abaixo, é possível ver essa alteração.

```SQL
USE MASTER
GO

ALTER DATABASE AdventureWorksDW2017
SET ALLOW_SNAPSHOT_ISOLATION ON
GO

USE AdventureWorksDW2017
GO
```

Depois de habilitar o Snapshot Isolation Level no banco de dados, é hora de ver os blocos de códigos que possibilitam este nivel de isolamento.

```SQL
/*********  RODAR NA CONEXÃO 1 *********/
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRAN
    SELECT * FROM DimEmployee WHERE EmployeeKey = 1
    WAITFOR DELAY '00:00:10'

    SELECT * FROM DimEmployee WHERE EmployeeKey = 1

     UPDATE DimEmployee 
        SET MiddleName = 'Teste Snapshot' 
      WHERE EmployeeKey = 2
    WAITFOR DELAY '00:00:10'
COMMIT TRAN





/*********  RODAR NA CONEXÃO 1 *********/
 UPDATE DimEmployee 
    SET MiddleName = 'Teste Snapshot 22222' 
  WHERE EmployeeKey = 1

  SELECT * FROM DimEmployee WHERE EmployeeKey = 1
```
# Problemas com Dead Lock
Por fim, o DEAD LOCK também causa um pouco de confusão com sua execução. A causa de um DEAK LOCK é quando uma transação espera uma liberação para seguir em frente. Porém, a transação que está segurando o processo (causando LOCK) está esperando a primeira transação terminar de processar alguma coisa. A grosso modo, é A esperando o B terminar e o B esperando o A terminar. Eles ficariam um esperando o outro até alguém “desistir”. Para isso, o SQL Server escolhe uma vítima de acordo com o início do processo e o grau de severidade que aquele processo pode ter. Normalmente a transação que começou por ultimo é a vítima, se desligando do processo (o SQL faz isso automaticamente) e dá um rollback nas alterações. Isso faz com que a transação que ganhou o processo termine suas atividades.

![image](https://github.com/BrunohSimplicio/SQL-Public/assets/103937135/6e9241cb-1af8-486c-a800-fb8cb7e548be)


Para ver isso através de código, execute os blocos abaixo.

```SQL
/*********  RODAR NA CONEXÃO 1 *********/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
BEGIN TRAN
    UPDATE DimEmployee 
       SET MiddleName = 'DeadLock' + EmployeeKey
     WHERE EmployeeKey = 3
    WAITFOR DELAY '00:00:10'

    UPDATE DimEmployee 
       SET MiddleName = 'DeadLock' + EmployeeKey
     WHERE EmployeeKey = 4
ROLLBACK TRAN
/*********  RODAR NA CONEXÃO 2 *********/
BEGIN TRAN

    UPDATE DimEmployee 
       SET MiddleName = 'DeadLock' + EmployeeKey
     WHERE EmployeeKey = 4
   WAITFOR DELAY '00:00:10'

    UPDATE DimEmployee 
       SET MiddleName = 'DeadLock' + EmployeeKey
     WHERE EmployeeKey = 3

ROLLBACK TRAN
```
