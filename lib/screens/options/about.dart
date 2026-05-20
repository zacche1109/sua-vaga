import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// Função para abrir app de email
void _launchEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: Uri.encodeFull('subject=Contato&body=Olá!'),
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw Exception('Não foi possível abrir o e-mail');
  }
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        toolbarHeight: 100,
        backgroundColor: MyColors.darkBlue,
        title: Text(
          "Sobre o App",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Image.asset(
            'assets/logo.png',
            height: 100,
            width: 100,
            alignment: Alignment.topRight,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  '"Sua Vaga" é um projeto que consiste em um aplicativo de monitoramento de vagas de estacionamento, que tem como principal objetivo facilitar a mobilidade urbana e otimizar o tempo à procura de vagas em estabelecimentos.\n\nA proposta central do projeto é oferecer aos motoristas uma plataforma digital onde seja possível visualizar, em tempo real, a disponibilidade de vagas em estacionamentos públicos e privados, com informações precisas de localização e status de ocupação.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 30),

              //informações de contato
              Container(
                decoration: BoxDecoration(
                  color: MyColors.darkBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Entre em contato',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'contato@suavaga.com',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '(99) 99999-9999',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.link, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'linkedin.com/in/sua-vaga',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.darkBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Desenvolvido por',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _developerInfo(
                            name: 'Enzo Zacché Costa Pereira',
                            linkedInUrl:
                                'https://www.linkedin.com/in/enzo-zacch%C3%A9-54b3b2324/',
                            email: 'zacch3enzo@gmail.com',
                            linkedInName: 'linkedin.com/in/Enzo-Zacché',
                          ),
                          const SizedBox(height: 12),

                          _developerInfo(
                            name: 'Paulo César Faggionato Filho',
                            linkedInUrl:
                                'https://www.linkedin.com/in/paulo-c%C3%A9sar-faggionato-filho-17501237a/',
                            email: 'paulinhofaggionato@gmail.com',
                            linkedInName:
                                'linkedin.com/in/Paulo-César-Faggionato-Filho',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _developerInfo({
    required String name,
    required String linkedInUrl,
    required String email,
    required String linkedInName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          //icone de pessoa com o nome
          children: [
            Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // icone linkedIn com link
        GestureDetector(
          onTap: () => _launchURL(linkedInUrl),
          child: Row(
            children: [
              Icon(Icons.link, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                linkedInName,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // icone email com link
        GestureDetector(
          onTap: () => _launchEmail(email),
          child: Row(
            children: [
              Icon(Icons.email, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(email, style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),

        const SizedBox(height: 24), // espaçamento entre desenvolvedores
      ],
    );
  }
}
