drop policy "Permite que usuario com role cliente popule seu registro de cli" on "public"."clientes";

create policy "Permite que usuario com role cliente popule seu registro"
on "public"."clientes"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Permite cliente listar seus pedidos"
on "public"."pedidos"
as permissive
for select
to authenticated
using ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = auth.uid()))))));


create policy "Permite cliente realizar novos pedidos"
on "public"."pedidos"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = auth.uid()))))));


create policy "Permite clientes atualizar seus pedidos"
on "public"."pedidos"
as permissive
for update
to authenticated
using ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = auth.uid())))) AND (estado = 0)));


create policy "Permite vendedor atualizar pedidos"
on "public"."pedidos"
as permissive
for update
to authenticated
using (("current_role"() = 'vendedor'::text))
with check (("current_role"() = 'vendedor'::text));


create policy "Permite vendedor criar pedidos"
on "public"."pedidos"
as permissive
for insert
to authenticated
with check (("current_role"() = 'vendedor'::text));


create policy "Permite vendedor listar pedidos"
on "public"."pedidos"
as permissive
for select
to authenticated
using (("current_role"() = 'vendedor'::text));


create policy "Permite cliente listar produtos de seus pedidos"
on "public"."pedidos_produtos"
as permissive
for select
to authenticated
using ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM (pedidos p
     JOIN clientes c ON ((c.id = p.cliente_id)))
  WHERE ((p.id = pedidos_produtos.pedido_id) AND (c.user_id = auth.uid()))))));


create policy "Permite clientes criar novos registros de pedidos_produtos"
on "public"."pedidos_produtos"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM (pedidos p
     JOIN clientes c ON ((c.id = p.cliente_id)))
  WHERE ((p.id = pedidos_produtos.pedido_id) AND (c.user_id = auth.uid()))))));


create policy "Permite vendedores atualizar produtos_pedidos"
on "public"."pedidos_produtos"
as permissive
for update
to authenticated
using (("current_role"() = 'vendedor'::text))
with check (("current_role"() = 'vendedor'::text));


create policy "Permite vendedores criar produtos_pedidos"
on "public"."pedidos_produtos"
as permissive
for insert
to authenticated
with check (("current_role"() = 'vendedor'::text));


create policy "Permite vendedores listar produtos_pedidos"
on "public"."pedidos_produtos"
as permissive
for select
to authenticated
using (("current_role"() = 'vendedor'::text));



