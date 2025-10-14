set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.calcular_total(id_pedido integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
begin
  return (
    select coalesce(sum(pp.preco_no_pedido * pp.quantidade), 0)
    from pedidos_produtos pp
    where pp.pedido_id = id_pedido
  );
end;
$function$
;


