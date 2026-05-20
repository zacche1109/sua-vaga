import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';

//Criação da classe customizada do bottomNavigator para facilitar uso

//não muda em tempo real, é estático
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex; //indice atual do do BottomNavigationBarItem (0,1,2)
  final Function(int)
  onTap; //função que recebe um valor int on tap, e o navgationItem devolve um valor int que é seu indice
  //vai ser útil para ter a navBar em todas as telas, quando clicar vai receber o index

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex, //construtor
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: BottomNavigationBar(
        currentIndex:
            currentIndex, //Em cada tela que for chamar vou digitar um valor
        onTap: onTap, //quando clica recebe a a função onTap
        backgroundColor: MyColors.darkBlue,
        selectedItemColor:
            Colors
                .white, //vai pintar o currentIndex, ou seja se baseia no index atual
        unselectedItemColor: const Color.fromARGB(
          255,
          122,
          120,
          120,
        ), //todos outros itens que não sejam o selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_outlined),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
