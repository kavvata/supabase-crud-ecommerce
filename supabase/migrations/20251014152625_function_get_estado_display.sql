set check_function_bodies = off;

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


