INSERT INTO "public"."roles" ("id", "nome")
VALUES ('1', 'vendedor'), ('2', 'cliente');




INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
    created_at, updated_at, confirmation_token, email_change_token_current,
    email_change_token_new, email_change, email_change_sent_at,
    last_sign_in_at, is_super_admin, is_sso_user, deleted_at, is_anonymous
) VALUES

(
    '00000000-0000-0000-0000-000000000000',
    '3bbcda2d-b07b-4c1f-a1cb-0e395fa71cba',
    'authenticated',
    'authenticated',
    'kavatagabriel@gmail.com',
    '$2a$10$gfzSsuZER1x4r5dkaX1Wq.dB4etXM3IzB8RcFyIy4DoMNNRbgI8Km',
    '2025-10-14 03:19:46.006448+00',
    '{"provider":"email","providers":["email"]}',
    '{"email_verified":true}',
    '2025-10-14 03:19:45.995161+00',
    '2025-10-14 03:19:46.008131+00',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '2025-10-14 03:19:46.006448+00',
    NULL,
    false,
    NULL,
    false
),

(
    '00000000-0000-0000-0000-000000000000',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'authenticated',
    'authenticated',
    'mariasilva@email.com',
    '$2a$10$gfzSsuZER1x4r5dkaX1Wq.dB4etXM3IzB8RcFyIy4DoMNNRbgI8Km',
    '2025-10-13 10:00:00.000000+00',
    '{"provider":"email","providers":["email"]}',
    '{"email_verified":true}',
    '2025-10-13 09:55:00.000000+00',
    '2025-10-13 10:00:00.000000+00',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '2025-10-13 10:00:00.000000+00',
    NULL,
    false,
    NULL,
    false
),

(
    '00000000-0000-0000-0000-000000000000',
    '9c135887-1b0e-4e5d-a642-67b43839fa7f',
    'authenticated',
    'authenticated',
    'joaosantos@empresa.com',
    '$2a$10$gfzSsuZER1x4r5dkaX1Wq.dB4etXM3IzB8RcFyIy4DoMNNRbgI8Km',
    '2025-10-12 14:30:00.000000+00',
    '{"provider":"email","providers":["email"]}',
    '{"email_verified":true}',
    '2025-10-12 14:25:00.000000+00',
    '2025-10-12 14:30:00.000000+00',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '2025-10-12 14:30:00.000000+00',
    NULL,
    false,
    NULL,
    false
),

(
    '00000000-0000-0000-0000-000000000000',
    'b0d7cdde-ff3a-454f-8f38-78d6497c746d',
    'authenticated',
    'authenticated',
    'anapaula@tech.com',
    '$2a$10$gfzSsuZER1x4r5dkaX1Wq.dB4etXM3IzB8RcFyIy4DoMNNRbgI8Km',
    '2025-10-11 16:45:00.000000+00',
    '{"provider":"email","providers":["email"]}',
    '{"email_verified":true}',
    '2025-10-11 16:40:00.000000+00',
    '2025-10-11 16:45:00.000000+00',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '2025-10-11 16:45:00.000000+00',
    NULL,
    false,
    NULL,
    false
),

(
    '00000000-0000-0000-0000-000000000000',
    '1ee6d767-9ad0-4e48-92bf-cd2558f59753',
    'authenticated',
    'authenticated',
    'carloslima@startup.com',
    '$2a$10$gfzSsuZER1x4r5dkaX1Wq.dB4etXM3IzB8RcFyIy4DoMNNRbgI8Km',
    '2025-10-10 11:20:00.000000+00',
    '{"provider":"email","providers":["email"]}',
    '{"email_verified":true}',
    '2025-10-10 11:15:00.000000+00',
    '2025-10-10 11:20:00.000000+00',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '2025-10-10 11:20:00.000000+00',
    NULL,
    false,
    NULL,
    false
);


INSERT INTO clientes (id, user_id, nome_completo, criado_em) VALUES
(1, '3bbcda2d-b07b-4c1f-a1cb-0e395fa71cba', 'Gabriel Kavata', NOW()),
(2, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Maria Silva', NOW()),
(3, '9c135887-1b0e-4e5d-a642-67b43839fa7f', 'João Santos', NOW()),
(4, 'b0d7cdde-ff3a-454f-8f38-78d6497c746d', 'Ana Paula Oliveira', NOW()),
(5, '1ee6d767-9ad0-4e48-92bf-cd2558f59753', 'Carlos Lima', NOW());


INSERT INTO produtos (descricao, preco, estoque, criado_em) VALUES
('Smartphone Android', 120000, 50, NOW()),
('Notebook Gamer', 250000, 20, NOW()),
('Fone de Ouvido Bluetooth', 8000, 100, NOW()),
('Tablet 10"', 150000, 30, NOW()),
('Smartwatch', 50000, 75, NOW()),
('Teclado Mecânico', 12000, 60, NOW()),
('Mouse Gamer', 6000, 80, NOW()),
('Monitor 24"', 90000, 25, NOW()),
('Caixa de Som Bluetooth', 15000, 40, NOW()),
('Carregador Portátil', 3000, 120, NOW());


INSERT INTO pedidos (cliente_id, entrega_prevista_em, entregue_em, estado) VALUES

(1, NOW() + INTERVAL '5 days', NULL, 0),
(1, NOW() - INTERVAL '1 day', NOW(), 2),
(1, NOW() - INTERVAL '6 days', NOW() - INTERVAL '3 days', 3),
(1, NOW() + INTERVAL '3 days', NULL, 1),
(1, NOW() + INTERVAL '5 days', NULL, 4),


(2, NOW() + INTERVAL '2 days', NULL, 0),
(2, NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', 3),
(2, NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days', 3),
(2, NOW() + INTERVAL '1 day', NULL, 1),


(3, NOW() + INTERVAL '7 days', NULL, 0),
(3, NOW() - INTERVAL '2 days', NOW(), 2),
(3, NOW() + INTERVAL '4 days', NULL, 4),
(3, NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days', 3),
(3, NOW() + INTERVAL '2 days', NULL, 1),


(4, NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day', 3),
(4, NOW() + INTERVAL '6 days', NULL, 0),
(4, NOW() - INTERVAL '1 day', NOW(), 2),


(5, NOW() + INTERVAL '3 days', NULL, 1),
(5, NOW() - INTERVAL '7 days', NOW() - INTERVAL '4 days', 3),
(5, NOW() + INTERVAL '2 days', NULL, 0);


INSERT INTO pedidos_produtos (pedido_id, produto_id, preco_no_pedido, quantidade) VALUES

(1, 1, 120000, 1), (1, 3, 8000, 2),
(2, 2, 250000, 1),
(3, 4, 150000, 1), (3, 5, 50000, 1), (3, 6, 12000, 1),
(4, 7, 6000, 3),
(5, 8, 90000, 1), (5, 9, 15000, 2),


(6, 10, 3000, 5),
(7, 1, 120000, 1), (7, 3, 8000, 1),
(8, 2, 250000, 1),
(9, 4, 150000, 1), (9, 6, 12000, 2),


(10, 5, 50000, 1), (10, 7, 6000, 2),
(11, 8, 90000, 1), (11, 9, 15000, 1), (11, 10, 3000, 3),
(12, 1, 120000, 1),
(13, 2, 250000, 1), (13, 3, 8000, 1),
(14, 4, 150000, 1),


(15, 5, 50000, 2), (15, 6, 12000, 1),
(16, 7, 6000, 4),
(17, 8, 90000, 1), (17, 9, 15000, 1),


(18, 10, 3000, 10),
(19, 1, 120000, 1), (19, 2, 250000, 1),
(20, 3, 8000, 2), (20, 4, 150000, 1);
