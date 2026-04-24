-- 1. Create CLIENTES table
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    telefone TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create SERVICOS table
CREATE TABLE IF NOT EXISTS servicos (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    duracao_minutos INTEGER DEFAULT 30,
    preco DECIMAL(10, 2) NOT NULL,
    categoria TEXT DEFAULT 'Geral',
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create AGENDAMENTOS table
CREATE TABLE IF NOT EXISTS agendamentos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
    servico_id INTEGER REFERENCES servicos(id) ON DELETE CASCADE,
    data_hora TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'agendado' CHECK (status IN ('agendado', 'concluido', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Enable Realtime for agendamentos
-- This allows the Flutter app to listen for new bookings
ALTER PUBLICATION supabase_realtime ADD TABLE agendamentos;
ALTER PUBLICATION supabase_realtime ADD TABLE clientes;

-- 5. Insert initial services (Sample data)
INSERT INTO servicos (nome, descricao, duracao_minutos, preco, categoria)
VALUES 
('Corte Social', 'Corte clássico tesoura e máquina', 30, 45.00, 'Cabelo'),
('Degradê / Fade', 'Corte moderno com acabamento na navalha', 45, 55.00, 'Cabelo'),
('Barba Completa', 'Barba com toalha quente e massagem', 30, 35.00, 'Barba'),
('Combo Klipper', 'Corte + Barba + Lavagem', 60, 80.00, 'Combo')
ON CONFLICT DO NOTHING;

-- 6. Basic RLS (Row Level Security) - Optional but recommended
-- For this demo, we'll allow public access to make it easier to test
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE agendamentos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Access Clientes" ON clientes FOR ALL USING (true);
CREATE POLICY "Public Access Servicos" ON servicos FOR SELECT USING (true);
CREATE POLICY "Public Access Agendamentos" ON agendamentos FOR ALL USING (true);
