set check_function_bodies = off;

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

create policy "Permite clientes ver somente o próprio cadastro de cliente"
on "public"."clientes"
as permissive
for select
to authenticated
using ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Permite listagem de clientes para vendedores"
on "public"."clientes"
as permissive
for select
to authenticated
using (("current_role"() = 'vendedor'::text));


create policy "Permite que clientes alterem seus dados"
on "public"."clientes"
as permissive
for update
to authenticated
using ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)))
with check ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Permite que usuario com role cliente popule seu registro de cli"
on "public"."clientes"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Permite atualização de produtos para vendedores"
on "public"."produtos"
as permissive
for update
to authenticated
using (("current_role"() = 'vendedor'::text));


create policy "Permite criação de novos produtos para vendedores"
on "public"."produtos"
as permissive
for insert
to authenticated
with check (("current_role"() = 'vendedor'::text));


create policy "Permite listagem de produtos para todos os usuarios"
on "public"."produtos"
as permissive
for select
to public
using (true);



