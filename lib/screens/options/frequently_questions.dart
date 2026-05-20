import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';

class FrequentlyQuestions extends StatefulWidget {
  const FrequentlyQuestions({super.key});

  @override
  State<FrequentlyQuestions> createState() => _FrequentlyQuestionsState();
}

class _FrequentlyQuestionsState extends State<FrequentlyQuestions> {
  final List<Map<String, String>> faqData = [
    {
      'question': 'Como funciona o sistema de vagas?',
      'answer':
          'O sistema detecta em tempo real as vagas disponíveis através de sensores e exibe no aplicativo.',
    },
    {
      'question': 'É necessário criar uma conta?',
      'answer':
          'Não, o aplicativo funciona perfeitamente sem a criação de nenhuma conta',
    },
    {
      'question': 'O app mostra vagas em todos os estacionamentos?',
      'answer':
          'Não, apenas em estacionamentos parceiros cadastrados na plataforma.',
    },
    // Adicione mais perguntas aqui
  ];
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
          "Perguntas Frequentes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final item = faqData[index];
          //card ja vem estilizado nativamente, facilita muito
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            //tem a propriedade padrão children q é quando expande o tile principal
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                //pega a chave do par chave valor e exibe o valor
                item['question']!,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              //exibe somente quando expande o tile
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item['answer']!, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
