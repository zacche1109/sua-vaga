import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';
import 'package:sua_vaga/common/custom_bottom_nav_bar.dart';
import 'package:sua_vaga/main.dart';
import 'package:sua_vaga/screens/options/about.dart';
import 'package:sua_vaga/screens/favorites_screen.dart';
import 'package:sua_vaga/screens/home/home_screen.dart';
import 'package:sua_vaga/screens/options/frequently_questions.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: MyColors.darkBlue,
        title: Text(
          "Opções",
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
            width: 200,
            alignment: Alignment.topRight,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildOptionItem(
            icon: Icons.help_outline,
            text: 'Perguntas frequentes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FrequentlyQuestions()),
              );
            },
          ),
          buildOptionItem(
            icon: Icons.support_agent,
            text: 'Sobre o aplicativo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => About()),
              );
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: MyColors.darkBlue)),
            ),
            child: SwitchListTile(
              title: Text(
                'Modo Escuro',
                style: TextStyle(color: MyColors.darkBlue, fontSize: 28),
              ),
              secondary: Icon(
                Icons.dark_mode,
                color: MyColors.darkBlue,
                size: 36,
              ),
              value: themeNotifier.value == ThemeMode.dark,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => FavoritesScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => OptionsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget buildOptionItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: MyColors.darkBlue)),
        ),
        child: Row(
          children: [
            Icon(icon, color: MyColors.darkBlue, size: 36),
            SizedBox(width: 36),
            Text(
              text,
              style: TextStyle(fontSize: 28, color: MyColors.darkBlue),
            ),
          ],
        ),
      ),
    );
  }
}
