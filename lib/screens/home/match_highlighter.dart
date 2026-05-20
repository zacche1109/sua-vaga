import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle normalStyle;
  final TextStyle highlightedStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.normalStyle,
    required this.highlightedStyle,
  });

  @override
  Widget build(BuildContext context) {
    //dividi tanto a pesquisa quando nome do estacionamento de letra em letra, função rune devidi em chars, e coloca eles em lista
    final queryChars = query.toLowerCase().runes.toList();
    final textChars = text.toLowerCase().runes.toList();
    final highlightedSpans =
        <
          TextSpan
        >[]; //construção da lista que vai exibir a String completa com destaques ou não, vamo incrementando nela
    int lastMatchEnd = 0;
    //percorre o nome do estacionamento caracter por caracter
    for (int i = 0; i < textChars.length; i++) {
      //se a query contém alguma letra do nome do estacionamento
      if (queryChars.contains(textChars[i])) {
        //se for maior que o ultimo caracter q bateu, ele vai deixar tudo q ta antes daquilo como normal
        if (i > lastMatchEnd) {
          highlightedSpans.add(
            TextSpan(text: text.substring(lastMatchEnd, i), style: normalStyle),
          );
        }

        // adiciona o caracter em questão como destacada a lista de destacados
        highlightedSpans.add(
          TextSpan(text: text.substring(i, i + 1), style: highlightedStyle),
        );

        lastMatchEnd =
            i +
            1; //dps de passar todo o for ele define o indice do ultimo q bateu, para futuras ocorrências
      }
    }

    // Adiciona o restante do texto que não foi destacado
    if (lastMatchEnd < text.length) {
      highlightedSpans.add(
        //vai do indice do lastMatch até o final da String e define como normal
        TextSpan(text: text.substring(lastMatchEnd), style: normalStyle),
      );
    }

    return RichText(text: TextSpan(children: highlightedSpans));
  }
}
