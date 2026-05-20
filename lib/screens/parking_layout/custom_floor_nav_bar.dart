import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';

class CustomFloorNavBar extends StatelessWidget {
  final List<String> floors;
  final int currentIndex;
  final Function(int) onTap;

  const CustomFloorNavBar({
    super.key,
    required this.floors,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFloors = floors.isNotEmpty;

    return SizedBox(
      height: 100,
      child: BottomNavigationBar(
        currentIndex: hasFloors ? currentIndex : 0,
        onTap: hasFloors ? onTap : (_) {},
        backgroundColor: MyColors.darkBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 122, 120, 120),
        items:
            hasFloors
                ? floors.map((label) {
                  return BottomNavigationBarItem(
                    icon: const SizedBox(),
                    label: label,
                  );
                }).toList()
                : [
                  //talvez colocar o logo da marca nos estacionamento que não tem mais de um andar
                  BottomNavigationBarItem(icon: SizedBox(), label: ''),
                  BottomNavigationBarItem(icon: SizedBox(), label: ''),
                ],
      ),
    );
  }
}
