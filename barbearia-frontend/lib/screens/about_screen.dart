import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Logo
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/images/layout/logo_klipper.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // App name with version badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Klipper',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sistema de Gestão para Barbearias',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Projeto de Extensão II',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),

            // Features
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funcionalidades',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.chat_bubble_outline, 'Agendamento via Chat'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.notifications_active_outlined, 'Notificações Push (FCM)'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.dashboard_outlined, 'Dashboard Administrativo'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.people_outline, 'Gestão de Clientes'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.monetization_on_outlined, 'Controle Financeiro'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Credits
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créditos',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.person_outline, 'Desenvolvedor: Ian Santos'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.school_outlined, 'Instituição: Projeto de Extensão II'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rate app button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Obrigado pela preferência! 💈'),
                      backgroundColor: Color(0xFF0D47A1),
                    ),
                  );
                },
                icon: const Icon(Icons.star_outline),
                label: const Text('Avaliar o App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Privacy policy button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Política de Privacidade'),
                      content: const Text(
                        'O Klipper não coleta dados pessoais além dos necessários para o funcionamento do serviço de agendamento.\n\n'
                        'Seus dados (nome, telefone) são usados exclusivamente para identificação no momento do agendamento e comunicação com o estabelecimento.\n\n'
                        'Nenhuma informação é compartilhada com terceiros.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendi'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Política de Privacidade'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D47A1),
                  side: const BorderSide(color: Color(0xFF0D47A1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Footer
            Text(
              'Feito com 💈 no Brasil',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 Klipper',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
