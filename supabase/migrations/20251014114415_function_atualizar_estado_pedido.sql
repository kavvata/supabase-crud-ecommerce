set check_function_bodies = off;

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


