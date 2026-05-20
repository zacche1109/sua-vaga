import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';
import 'package:sua_vaga/common/custom_bottom_nav_bar.dart';
import 'package:sua_vaga/models/parking_model.dart';
import 'package:sua_vaga/repositories/parking_repository.dart';
import 'package:sua_vaga/screens/options/options_screen.dart';
import 'package:sua_vaga/screens/home/home_screen.dart';
import 'package:sua_vaga/screens/parking_layout/parking_layout_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Set<String> _favoriteParkingLotIds = {};
  List<ParkingLot> _favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();
    //lista para controle no momento de qual tao salvos, em tempo de execução, fica salvando toda vez no banco de dados
    setState(() {
      _favoriteParkingLotIds = snapshot.docs.map((doc) => doc.id).toSet();
    });

    List<ParkingLot> favoritesData = [];
    for (final id in _favoriteParkingLotIds) {
      final lot = await firestore.collection('parkingLots').doc(id).get();
      final data = lot.data() as Map<String, dynamic>;
      favoritesData.add(ParkingLot.fromMap(data));
    }

    setState(() {
      _favorites = favoritesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: MyColors.darkBlue,
        title: Text(
          "Favoritos",
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
      body:
          _favorites.isEmpty
              ? Center(child: Text("Nenhum estacionamento favoritado"))
              : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final parkingLot = _favorites[index];
                  final isFavorite = _favoriteParkingLotIds.contains(
                    parkingLot.id,
                  );
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: MyColors.darkBlue),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        parkingLot.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        parkingLot.adress,
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        onPressed: () {
                          final newStatus = !isFavorite;
                          toggleFavorite(parkingLot.id, newStatus);
                          setState(() {
                            if (newStatus) {
                              _favoriteParkingLotIds.add(parkingLot.id);
                            } else {
                              _favoriteParkingLotIds.remove(parkingLot.id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ParkingLayoutScreen(parkingLot: parkingLot),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
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
}
