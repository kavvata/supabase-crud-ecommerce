import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const ECOMMERCE_EMAIL = Deno.env.get("ECOMMERCE_EMAIL")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  const { pedidoId } = await req.json();

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // const { data: pedido, error: pedidoError } = await supabaseClient
  //   .from("pedidos")
  //   .select("*")
  //   .eq("id", pedidoId)
  //   .single();
  //
  const subject = `[eCommerce] - Pedido #${pedidoId} confirmado!`;

  const { data: pedido, error: pedidoError } = await supabaseClient
    .from("pedidos")
    .select(
      `
    *,
    clientes!inner (
      nome_completo,
      user_id
    ),
    pedidos_produtos (
      quantidade,
      preco_no_pedido,
      produtos (
        descricao,
        id
      )
    )
  `,
    )
    .eq("id", pedidoId)
    .single();

  const to = await supabaseClient.rpc("get_cliente_email", {
    cliente_id: pedido.cliente_id,
  });

  const produtosInfo = pedido.pedidos_produtos.map((item) => ({
    descricao: item.produtos.descricao,
    quantidade: item.quantidade,
    preco_no_pedido: item.preco_no_pedido,
    subtotal: item.preco_no_pedido * item.quantidade,
  }));

  const total = produtosInfo.reduce((sum, item) => sum + item.subtotal, 0);

  const message = `
  Prezado ${pedido.clientes.nome_completo},

  Seu pedido #${pedido.id} foi confirmado!

  Itens do pedido:
  ${produtosInfo
    .map(
      (item) =>
        `   ${item.descricao}
    Quantidade: ${item.quantidade}
    Preço unitário: R$ ${(item.preco_no_pedido / 100).toFixed(2)}
    Subtotal: R$ ${(item.subtotal / 100).toFixed(2)}
    `,
    )
    .join("\n")}

  Valor total: R$ ${(total / 100).toFixed(2)}

  Data prevista de entrega: ${new Date(pedido.entrega_prevista_em).toLocaleDateString("pt-BR")}

  Agradecemos pela preferência!
  `;

  console.log(message);

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: ECOMMERCE_EMAIL,
      to,
      subject,
      html: message,
    }),
  });
  const data = await res.json();
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" },
  });
});
