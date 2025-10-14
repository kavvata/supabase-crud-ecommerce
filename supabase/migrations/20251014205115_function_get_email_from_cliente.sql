set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_cliente_email(cliente_id integer)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    user_email text;
BEGIN
    SELECT u.email INTO user_email
    FROM auth.users u
    JOIN clientes c ON u.id = c.user_id
    WHERE c.id = cliente_id;
    
    RETURN user_email;
END;
$function$
;


