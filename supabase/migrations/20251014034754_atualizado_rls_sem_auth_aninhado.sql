drop policy "Permite cliente listar seus pedidos" on "public"."pedidos";

drop policy "Permite cliente realizar novos pedidos" on "public"."pedidos";

drop policy "Permite clientes atualizar seus pedidos" on "public"."pedidos";

drop policy "Permite cliente listar produtos de seus pedidos" on "public"."pedidos_produtos";

drop policy "Permite clientes criar novos registros de pedidos_produtos" on "public"."pedidos_produtos";

create policy "Permite cliente listar seus pedidos"
on "public"."pedidos"
as permissive
for select
to authenticated
using ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = ( SELECT auth.uid() AS uid)))))));


create policy "Permite cliente realizar novos pedidos"
on "public"."pedidos"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = ( SELECT auth.uid() AS uid)))))));


create policy "Permite clientes atualizar seus pedidos"
on "public"."pedidos"
as permissive
for update
to authenticated
using ((("current_role"() = 'cliente'::text) AND ((EXISTS ( SELECT 1
   FROM clientes c
  WHERE ((c.id = pedidos.cliente_id) AND (c.user_id = ( SELECT auth.uid() AS uid))))) AND (estado = 0))));


create policy "Permite cliente listar produtos de seus pedidos"
on "public"."pedidos_produtos"
as permissive
for select
to authenticated
using ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM (pedidos p
     JOIN clientes c ON ((c.id = p.cliente_id)))
  WHERE ((p.id = pedidos_produtos.pedido_id) AND (c.user_id = ( SELECT auth.uid() AS uid)))))));


create policy "Permite clientes criar novos registros de pedidos_produtos"
on "public"."pedidos_produtos"
as permissive
for insert
to authenticated
with check ((("current_role"() = 'cliente'::text) AND (EXISTS ( SELECT 1
   FROM (pedidos p
     JOIN clientes c ON ((c.id = p.cliente_id)))
  WHERE ((p.id = pedidos_produtos.pedido_id) AND (c.user_id = ( SELECT auth.uid() AS uid)))))));



