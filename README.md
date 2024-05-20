# ecommerce
Modelo Ecommerce

Apresentação de alguns SQL assim como Modelagem DER. 

Todos os comandos sql foram desenvolvidos em PostgreSQL.

# Modelo_DER
No arquivo "create_tables.sql" temos o DDL das tabelas para o Modelo_DER.png, lembrando que foram adicionados 2 Modelos, sendo:

Modelo_DER.png - 
Customer: É a entidade onde se encontram todos os nossos clientes, sejam eles Compradores ou Vendedores do Site. Os principais atributos são email, nome, sobrenome, sexo, endereço, data de nascimento, telefone, entre outros.

Item: É a entidade onde estão localizados os produtos publicados em nosso marketplace. O volume é muito grande porque estão incluídos todos os produtos que foram publicados em algum momento. Usando o status do item ou a data de cancelamento, você pode detectar os itens ativos no marketplace. 

Category: É a entidade onde se encontra a descrição de cada categoria com seu respectivo caminho. Cada item possui uma categoria associada a ele.
Order: O pedido é a entidade que reflete as transações geradas dentro do site (cada compra é um pedido). Neste caso não teremos fluxo de carrinho de compras, portanto cada item vendido será refletido em um pedido independente da quantidade que foi adquirida.

Itemhistory - É a entidade para armazenar as alterações dos preços dos itens. A solução para resolver o problema de histórico de itens seria a técnica Slowly --Changing Dimensions (SCD) em um data warehouse onde seria possível combinar os conceitos de controle de versão para garantir uma trilha de auditoria transparente. A solução permite a visualização de item quando alterado mais de uma vez ao dia, permitindo o tracking de forma transparente e já preparada para outros campos da tabela item. Uma outra solução possível seria criar um TimeStamp para cada alteração e no final do dia executar uma stored procedure para recuperar todos os itens alterados. Em ambos os casos devemos analisar a melhor para não impactar o banco de dados transacional durante o periodo de utilização.

Modelo_DER_Versão2.png
Aqui apresento uma versão melhorada com tabelas adicionais, pensando na análise de compras, recomendação, histórico de navegação, e também pensando em entidades para geração de arquivos regulatórios, sempre necessário em uma aplicação de ecommerce.

User: É a entidade para controlar os usuarios e seus devidos acessos e para rastrear quem alterou os dados, quando e quais foram as alterações.

Permissions: É a entidade para manipular as permissões, sejam elas a acesso de tabela, e sendo possível alteração para manipular acesso por Linha e coluna de dados

Reports: É a entidade para armazear os relatórios gerados automaticamente e com metadados relevantes

RegulatoryComplianceAnalysis: É a entidade para armazenar os resultados de análises de dados em relação aos requisitos regulatórios do Órgão, facilitando a comparação de resultados, encontrar anomalias, validação e correção de problemas.

EncryptionKeys: É a entidade para Gerenciar chaves de criptografia e proteção dos dados sensiveis em relação a normas como LGPD.

Recommendations: É a entidade para armazenar recomendações de produtos, podendo ser resultados de projetos Machine Learning.

browsinghistory: É a entidade para armazenar o histórico de navegação dos clientes para melhorar a personalização

São apenas alguns exemplos para evolução, podendo além disso criar nvoas entidades como Currency, ItemTranslation para facilitar a internalização de processos, como moedas estrangeiras, e tradução para os nomes dos itens e respectivas descrições. Segue exemplos básicos:

CREATE TABLE Currency (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(50),
    exchange_rate NUMERIC(10, 4)
);

CREATE TABLE ItemTranslation (
    item_id INT REFERENCES Item(item_id),
    language_code CHAR(2),
    name_translated VARCHAR(100),
    description_translated TEXT,
    PRIMARY KEY (item_id, language_code)
);

# Extração de Insights via SQL

O arquivo "respostas_negocio.sql" responde as questões abaixo como exemplo de extração de insights:

Liste usuários com aniversário de hoje cujo número de vendas realizadas em janeiro de 2020 seja superior a 1500.

Para cada mês de 2020, são solicitados os 5 principais usuários que mais venderam (R$) na categoria Celulares. São obrigatórios o mês e ano da análise, nome e sobrenome do vendedor, quantidade de vendas realizadas, quantidade de produtos vendidos e valor total transacionado.

É solicitada uma nova tabela a ser preenchida com o preço e status dos Itens no final do dia. Lembre-se de que deve ser reprocessável. Vale ressaltar que na tabela Item teremos apenas o último status informado pelo PK definido. (Pode ser resolvido através de StoredProcedure)

# API, Python e Notebook

Exemplo de integração com API para download de dados, armazenando em uma camada de storage, e uma análise utilizando Jupyter Notebook podem ser encontrados nos arquivos abaixo:

e-commerce Diagrama Solução.pdf - Diagrama da Solução Alto Nível e próximos passos para melhrorias futuras

E_commerce.ipynb - Notebook com código baixo para conectar e fazer download de dados de uma API pública, a partir de então fazer análise exploratória dos dados, pre-processamento com engenharia de dados e extração de insights, passando até por modelos ML como clustering para identificar os grupos de itens mais próximos através do price.

# Dashboard

# Crescimento da Internet na Argentina

Os arquivos abaixo mostram um exemplo de análise para os dados de crescimento na argentina, assim como o desenvolvimento de um relatório conclusivo sobre o mesmo.

Dashboard_Argentina_Evolucao_Internet.pbix - Dashboard em Powerbi com gráficos para análises.

Análise - Crescimento da Internet na Argentina.pdf - Relatório sobre o entendimento dos dados.


