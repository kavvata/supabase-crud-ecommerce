import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const { pedidoId } = await req.json();

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const { data: pedido, error: pedidoError } = await supabaseClient
    .from("pedidos")
    .select("*")
    .eq("id", pedidoId)
    .single();

  if (pedidoError) {
    throw new Error(`Error fetching pedido: ${pedidoError.message}`);
  }

  if (!pedido) {
    return new Response(JSON.stringify({ error: "Pedido não encontrado." }), {
      status: 404,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const { data: pedidosProdutos, error: pedidoProdutosError } =
    await supabaseClient
      .from("pedidos_produtos")
      .select("*")
      .eq("pedido_id", pedidoId);

  if (pedidoProdutosError) {
    throw new Error(
      `Error fetching pedido products: ${pedidoProdutosError.message}`,
    );
  }

  if (!pedidosProdutos) {
    return new Response(
      JSON.stringify({ error: "Produtos do pedido não encontrados." }),
      {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const estadoMap: { [key: number]: string } = {
    0: "Pendente",
    1: "Enviado",
    2: "Entregue",
    3: "Recebido",
    4: "Cancelado",
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleDateString("pt-BR");
  };

  const formatCurrency = (amount: number) => {
    return `R$ ${(amount / 100).toFixed(2).replace(".", ",")}`;
  };

  const headers = [
    "Pedido ID",
    "Cliente",
    "Data do Pedido",
    "Entrega Prevista",
    "Entregue em",
    "Estado",
    "Produto",
    "Quantidade",
    "Preço Unitário",
    "Subtotal",
  ];

  const promises = pedidosProdutos.map(async (item: any) => {
    const subtotal = item.preco_no_pedido * item.quantidade;

    const { data: cliente, error: clienteError } = await supabaseClient
      .from("clientes")
      .select("nome_completo")
      .eq("id", pedido.cliente_id)
      .single();

    const { data: produto, error: produtoError } = await supabaseClient
      .from("produtos")
      .select("descricao")
      .eq("id", item.produto_id)
      .single();
    return [
      pedido.id,
      `"${cliente.nome_completo}"`,
      formatDate(pedido.criado_em),
      formatDate(pedido.entrega_prevista_em),
      formatDate(pedido.entregue_em),
      estadoMap[pedido.estado] || "Desconhecido",
      `"${produto.descricao}"`,
      item.quantidade,
      formatCurrency(item.preco_no_pedido),
      formatCurrency(subtotal),
    ];
  });

  const csvRows = await Promise.all(promises);

  const csvContent = [
    headers.join(","),
    ...csvRows.map((row) => row.join(",")),
  ].join("\n");

  const filename = `pedido_${pedido.id}_${new Date().toISOString().split("T")[0]}.csv`;

  return new Response(csvContent, {
    headers: {
      ...corsHeaders,
      "Content-Type": "text/csv",
      "Content-Disposition": `attachment; filename="${filename}"`,
    },
  });
});
