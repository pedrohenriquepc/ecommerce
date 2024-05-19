--respostas_negocio.sql

-- Liste usuários com aniversário de hoje cujo número de vendas realizadas em janeiro de 2020 seja superior --a 1500.

WITH January2020Sales AS (
    SELECT customer_id, COUNT(*) AS num_sales
    FROM "Order"
    -- Filtrar aqui o Ano e Mês desejado
    WHERE EXTRACT(year FROM order_date) = 2020
    AND EXTRACT(month FROM order_date) = 1
    GROUP BY customer_id
)
SELECT *
FROM Customer
-- Filtrando aniversario pela data de hoje
WHERE DATE_PART('month', birth_date) = DATE_PART('month', CURRENT_DATE)
AND DATE_PART('day', birth_date) = DATE_PART('day', CURRENT_DATE)
AND EXISTS (
    SELECT 1
    FROM January2020Sales
    WHERE January2020Sales.customer_id = Customer.customer_id
    -- Filtrar aqui o numero de vendas desejado
    AND January2020Sales.num_sales > 1500
);

--Para cada mês de 2020, são solicitados os 5 principais usuários que mais venderam (R$) na categoria --Celulares. São obrigatórios o mês e ano da análise, nome e sobrenome do vendedor, quantidade de vendas --realizadas, quantidade de produtos vendidos e valor total transacionado

-- View para encontrar os Top 5, adicionando Rank para particionar os dados por cada mês e seu total, retornando assim um rank com os dados por mês
WITH MonthlyTopFiveSellers AS (
    SELECT
        EXTRACT(year FROM o.order_date) AS year,
        EXTRACT(month FROM o.order_date) AS month,
        o.customer_id,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(year FROM o.order_date), EXTRACT(month FROM o.order_date) ORDER BY SUM(o.total_price) DESC) AS rank,
        c.first_name,
        c.last_name,
        SUM(o.quantity) AS total_quantity,
        SUM(o.total_price) AS total_sales
    FROM
        "Order" o
    JOIN
        Item i ON o.item_id = i.item_id
    JOIN
        Customer c ON o.customer_id = c.customer_id
    JOIN
        Category cat ON i.category_id = cat.category_id
    WHERE
        EXTRACT(year FROM o.order_date) = 2020
        --Adicionar aqui a categoria desejada
        AND cat.category_name = 'Celulares' 
    GROUP BY
        EXTRACT(year FROM o.order_date),
        EXTRACT(month FROM o.order_date),
        o.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    year,
    month,
    first_name,
    last_name,
    total_quantity AS quantidade_vendida,
    COUNT(*) AS quantidade_vendas,
    total_sales AS valor_total_transacionado
FROM
    MonthlyTopFiveSellers
where
    -- Adicionar aqui a quantidade de rank desejada
    rank <= 5
GROUP BY
    year,
    month,
    first_name,
    last_name,
    total_quantity,
    total_sales
ORDER BY
    year,
    month,
    -- Buscando pelos maiores valores na ordem decrescente
    total_sales DESC;
	
--É solicitada uma nova tabela a ser preenchida com o preço e status dos Itens no final do dia. Lembre-se de --que deve ser reprocessável. Vale ressaltar que na tabela Item teremos apenas o último status informado --pelo PK definido. (Pode ser resolvido através de StoredProcedure)

--Uma solução para resolver o problema de histórico de itens seria a técnica Slowly --Changing Dimensions (SCD) em um data warehouse onde seria possível combinar os conceitos de controle de --versão para garantir uma trilha de auditoria transparente.

--Uma outra solução seria utilizar o proprio banco de dados para ter um controle de CDC (Change Data --Control), onde por exemplo existem varias ferramentas de mercados que podem criar esse tracking para --auditoria de forma automatizada.


-- Criando a tabela de historico

CREATE TABLE public.itemhistory (
	history_id serial4 NOT NULL,
	item_id int4 NULL,
	effective_date date NULL,
	price numeric(10, 2) NULL,
	status varchar(50) NULL,
	previous_history_id int4 NULL
);


-- public.itemhistory foreign keys

ALTER TABLE public.itemhistory ADD CONSTRAINT itemhistory_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id);
ALTER TABLE public.itemhistory ADD CONSTRAINT itemhistory_previous_history_id_fkey FOREIGN KEY (previous_history_id) REFERENCES public.itemhistory(history_id);


-- Criando Trigger na tabela item

create trigger itemchangestrigger after
insert
    or
update
    on
    public.item for each row execute function trackitemchanges();
	
-- Função Track Itens
-- DROP FUNCTION public.trackitemchanges();

CREATE OR REPLACE FUNCTION public.trackitemchanges()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Insere um novo registro na tabela de histórico sempre que um item é atualizado
    INSERT INTO ItemHistory (item_id, effective_date, price, status, previous_history_id)
    VALUES (NEW.item_id, CURRENT_DATE, NEW.price, NEW.status, COALESCE((SELECT MAX(history_id) FROM ItemHistory WHERE item_id = NEW.item_id), 0));
    RETURN NEW;
END;
$function$
;

--A solução permite a visualização de item quando alterado mais de uma vez ao dia, permitindo o tracking de forma transparente e já preparada para outros campos da tabela item. Uma outra solução possível seria criar um TimeStamp para cada alteração e no final do dia executar uma stored procedure para recuperar todos os itens alterados. Em ambos os casos devemos analisar a melhor para não impactar o banco de dados transacional durante o periodo de utilização.