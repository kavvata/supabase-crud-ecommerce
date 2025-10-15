create policy "Permite visibilidade de roles para autenticados"
on "public"."roles"
as permissive
for select
to authenticated
using (true);


create policy "Permite usuario consultar propria role"
on "public"."users_roles"
as permissive
for select
to public
using ((user_id = auth.uid()));



