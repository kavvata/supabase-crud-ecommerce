create or replace view "public"."pedidos_por_estado" as  SELECT get_estado_display((estado)::integer) AS estado,
    count(estado) AS quantidade
   FROM pedidos
  GROUP BY estado
  ORDER BY (count(estado)) DESC;



