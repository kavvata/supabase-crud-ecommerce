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


