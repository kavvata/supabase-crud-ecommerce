<h1 align="center" id="title">Sistema de Pedidos eCommerce - Supabase</h1>

<p id="description">Sistema de gerenciamento de pedidos desenvolvido com Supabase, incluindo autenticação de usuários, controle de estoque, processamento de pedidos e notificações por e-mail.</p>

## Como testar

Certifique-se que você possui todas as dependências instaladas:

- Docker
- Node Package Manager

Passo a passo para levante do projeto supabase.

1. Inicialize módulos node:

```shell
npm install --save-dev
```

2. Configurar arquivo env:

```shell
cp .env-example .env
```

3. Levante o ambiente local de desenvolvimento:

```shell
npx supabase start
```

4. Acesse o ambiente web na URL:

```shell
http://127.0.0.1:54323
```

## Desenvolvimento do projeto

Detalhes do desenvolvimento de teste, impasses e como esses incidentes foram solucionados.

### Elaboração de entidades-relacionamentos

Primeiramente, precisei pensar em um banco de dados que atenda os requisitos do teste, além de boas práticas de arquitetura de arquitetura back-end. Assim, elaborei uma tabela de pedidos que comporte o cliente, múltiplos produtos e seus respectivos preços na data do pedido. Para mantimento de logs, optei por criar duas colunas em todas as tabelas: `criado_em` e `removido_em`. Assim, quando um registro é apagado, seu histórico é mantido no banco de dados.
Como o sistema manipulará dinheiro, optei por usar o tipo _inteiro_ para preços, logo que em sistemas de eCommerce não existe fração de um centavo. Isso me garante que em momento nenhum vou ter problemas de arredondamento como aconteceria com tipos de ponto flutuante. Para demonstrar em tela o valor em Real, basta dividir o preço em centavos por 100.

![Diagrama Entidade-Relacionamento do banco](https://raw.githubusercontent.com/kavvata/supabase-crud-ecommerce/refs/heads/main/resources/db-diagram.svg)
Também defini os valores de `estado`:

- **0**: Pendente
- **1**: Enviado
- **2**: Entregue
- **3**: Recebido
- **4**: Cancelado

### Criação do projeto supabase

Estabelecido o relacionamento das entidades, criei as tabelas na instância remota do projeto supabase.
![Diagrama Entidade-Relacionamento gerado pelo supabase](https://raw.githubusercontent.com/kavvata/supabase-crud-ecommerce/refs/heads/main/resources/supabase-schema.png)
Na sequência, criei o repositório git em minha máquina local, realizando as configurações iniciais, criação de imagens docker e levante do ambiente containerizado para desenvolvimento com o `supabase-cli`.

![Captura de tela com listagem de migrations](https://raw.githubusercontent.com/kavvata/supabase-crud-ecommerce/refs/heads/main/resources/terminal-screenshot.png)

### Implementação de RLS

Com os schemas criados, iniciei a implementação das Row-Level Securities (RLS). Estabeleci duas roles: `vendedor` e `cliente`. A primeira é responsável por manter os cadastros referentes aos produtos da loja e atualização de andamento de pedidos. Já a segunda é responsável por realizar pedidos.
A princípio, utilizei as roles do próprio postgres:

```sql
-- [...]
create policy "Permite que clientes alterem seus dados"
on "public"."clientes"
as permissive
for update
to cliente
using (true)
with check ((( SELECT auth.uid() AS uid) = user_id));
-- [...]
```

Porém, isso se demonstrou pouco escalável. Em seguida, implementei uma verificação de role do usuário autenticado em uma function auxiliar:

```sql
CREATE OR REPLACE FUNCTION public.current_role()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(
    (SELECT r.nome
     FROM users_roles ur
     JOIN roles r ON ur.role_id = r.id
     WHERE ur.user_id = auth.uid()
     LIMIT 1),
    'anon'
);
$function$;
```

A partir desta function, reestruturei as policies criadas anteriormente.

```sql
-- [...]
create policy "Permite que clientes alterem seus dados"
on "public"."clientes"
as permissive
for update
to authenticated
using ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)))
with check ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)));
-- [...]
```

### Stored Functions auxiliares

Elaborei algumas functions auxiliares para automatizar alguns processos, como calcular o preço total de um pedido:

```sql
CREATE OR REPLACE FUNCTION public.calcular_total(id_pedido integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
begin
  return (
    select coalesce(sum(pp.preco_no_pedido), 0)
    from pedidos_produtos pp
    where pp.pedido_id = id_pedido
  );
end;
$function$
;
```

Atualizar o estado de um pedido:

```sql
CREATE OR REPLACE FUNCTION public.atualizar_estado(id_pedido integer, estado_int integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  result_id integer;
begin
  update pedidos
  set estado = estado_int
  where id = id_pedido
  returning id into result_id;

return result_id;
end;
$function$
;
```

E mostrar descrição de tela de um estado de pedido:

```sql
CREATE OR REPLACE FUNCTION public.get_estado_display(estado_int integer)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    RETURN CASE estado_int
        WHEN 0 THEN 'Pendente'
        WHEN 1 THEN 'Enviado'
        WHEN 2 THEN 'Entregue'
        WHEN 3 THEN 'Recebido'
        WHEN 4 THEN 'Cancelado'
        ELSE 'Desconhecido'
    END;
END;
$function$
;
```

### Views para relatório

Implementei views para relatório de lucros dos pedidos:

```sql
create or replace view "public"."clientes_lucro_total" as  WITH count_pedidos AS (
         SELECT pedidos.cliente_id,
            count(*) AS qtd_pedidos
           FROM pedidos
          WHERE (pedidos.estado = ANY (ARRAY[2, 3]))
          GROUP BY pedidos.cliente_id
        )
 SELECT c.nome_completo,
    count_p.qtd_pedidos,
    count(pp.*) AS qtd_produtos_pedidos,
    sum((pp.preco_no_pedido * pp.quantidade)) AS valor_total
   FROM (((clientes c
     JOIN pedidos p ON ((c.id = p.cliente_id)))
     JOIN pedidos_produtos pp ON ((pp.pedido_id = p.id)))
     JOIN count_pedidos count_p ON ((count_p.cliente_id = c.id)))
  WHERE (p.estado = ANY (ARRAY[2, 3]))
  GROUP BY c.nome_completo, count_p.qtd_pedidos
  order by valor_total desc, c.nome_completo;
```

E relatório de quantidade de pedidos por estado:

```sql
create or replace view "public"."pedidos_por_estado" as  SELECT get_estado_display((estado)::integer) AS estado,
    count(estado) AS quantidade
   FROM pedidos
  GROUP BY estado
  ORDER BY (count(estado)) DESC;
```

### Edge Functions

Elaborei uma edge function para exportar um pedido em csv com os dados do pedido. Disponível em `supabase/functions/exportarPedidoCsv/index.ts`.
Também, criei uma edge function para envio de e-mail de pedidos confirmados, sendo possível ser chamada através de um trigger do banco. Por exemplo:

```sql
CREATE OR REPLACE FUNCTION public.notify_pedido_insert()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  payload json;
BEGIN
  payload = json_build_object(
    'pedidoId', NEW.id,
  );

  PERFORM net.http_post(
    url := 'https://ref-do-seu-projeto.supabase.co/functions/v1/enviarEmailConfirmacaoPedido',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-key"}'::jsonb,
    body := payload::jsonb
  );

  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS on_pedido_insert ON pedidos;
CREATE TRIGGER on_pedido_insert
  AFTER INSERT ON pedidos
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_pedido_insert();
```

É possível ver a implementação dessa edge function em `supabase/functions/enviarEmailConfirmacaoPedido/index.ts`.

### Problemas com migrations no supabase

Enquanto validava a edge function de exportação CSV, encontrei um impasse. Falta de permissão para leitura. Mesmo utilizando uma key de service_role, ainda não era possível realizar consultas no banco. Investiguei as RLS. Tentei desativá-las. Sem sucesso. Após ler documentações e forums do supabase, tive certeza que algo estava muito errado na estrutura do meu projeto. Decidi investigar minhas migrations, onde encontrei os seguintes comandos SQL gerados via `npx supabase db diff`:

```sql
-- supabase/migrations/20251013233241_criado_vinculo_cliente_usuario.sql

revoke delete on table "public"."clientes" from "anon";

-- [...] revogado CRUD de todas as tabelas para anon

revoke delete on table "public"."clientes" from "authenticated";

-- [...] revogado CRUD de todas as tabelas para authenticated

revoke delete on table "public"."pedidos" from "service_role";

-- [...] revogado CRUD de todas as tabelas para "service_role"

-- [...]
alter table "public"."clientes" add column "user_id" uuid not null;
alter table "public"."pedidos" alter column "estado" set default '0'::smallint;
alter table "public"."pedidos" alter column "estado" set not null;
alter table "public"."clientes" add constraint "clientes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;
alter table "public"."clientes" validate constraint "clientes_user_id_fkey";
```

Removendo essas operações e resetando o banco local com `supabase db reset`, o endpoint da edge function funcionou corretamente:

```csv
Pedido ID,Cliente,Data do Pedido,Entrega Prevista,Entregue em,Estado,Produto,Quantidade,Preço Unitário,Subtotal
1,"Gabriel Kavata",14/10/2025,19/10/2025,N/A,Pendente,"Smartphone Android",1,R$ 1200,00,R$ 1200,00
1,"Gabriel Kavata",14/10/2025,19/10/2025,N/A,Pendente,"Fone de Ouvido Bluetooth",2,R$ 80,00,R$ 160,00
```
