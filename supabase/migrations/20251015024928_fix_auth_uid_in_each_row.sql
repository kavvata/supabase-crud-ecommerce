drop policy "Permite usuario consultar propria role" on "public"."users_roles";

create policy "Permite usuario consultar propria role"
on "public"."users_roles"
as permissive
for select
to public
using ((user_id = ( SELECT auth.uid() AS uid)));



