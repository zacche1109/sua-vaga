import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sua_vaga/common/colors.dart';
import 'package:sua_vaga/models/parking_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:sua_vaga/repositories/parking_repository.dart';
import 'package:sua_vaga/repositories/parking_stream_builder.dart';
import 'package:sua_vaga/screens/favorites_screen.dart';
import 'package:sua_vaga/screens/options/options_screen.dart';
import 'package:sua_vaga/common/custom_bottom_nav_bar.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:sua_vaga/screens/home/match_highlighter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  late List<ParkingLot> parkingLots = [];
  bool isLoading = true; //variavel de controle de carregamento
  List<ParkingLot> filteredParkingLots =
      []; //cria uma lista vazia para fazer as sugestões

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController =
      TextEditingController(); //obter e manipular texto digitado na barra
  bool _isSearching = false;
  bool _showSuggestions = false;
  double _suggestionOpacity = 0.0;
  bool _showAnimatedSuggestions = false;
  Set<String> _favoriteParkingLotIds = {};

  @override
  void initState() {
    super.initState();

    fetchParkingLots();
    loadFavorites();
    _getCurrentLocation();
  }

  //pergunta se permite usar a localização ou não
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // GPS desativado, você pode mostrar mensagem ou abrir configurações
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissão negada
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão negada para sempre
      return;
    }

    // Começa a escutar posição do usuário
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Atualiza só se mover mais que 5 metros
      ),
      //lsitener que escuta toda mudança de posição e acionao setState para setar a nova posição
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;
      });

      // Move o mapa para a nova localização
      _mapController.move(newLocation, _mapController.camera.zoom);
    });
  }

  Future<void> loadFavorites() async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();

    setState(() {
      _favoriteParkingLotIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  Future<void> fetchParkingLots() async {
    final lots = await ParkingRepository().getAllParkingLots();
    setState(() {
      parkingLots = lots;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  //método para apenas mostrar as sugestões quando tem algo escrito
  void _filterParkingLots(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredParkingLots = List.from(parkingLots);
        _showSuggestions = false;
      });
      return; //funciona como um brake, só que o brake só funciona para loop
    }
    // inicializa uma busca difusa, dependencia do flutter que faz calculos para criar proximidades entre strings
    //sem necessariamente ser uma letra pós outra, e sim se baseia no conjunto e ve o q ta proximo e distante
    final fuse = Fuzzy(
      parkingLots, //lista completa com estacionamentos
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'name', //vai se basear no nome dos estacionamentos
            weight:
                1.0, //importancia desse campo na pesquisa, de 0 a 1, sendo 1 máxima importância
            getter:
                (parkingLot) =>
                    (parkingLot as ParkingLot)
                        .name, // extração do nome de cada parkingLot, a partir de uma função básica, pega a lista como um todo transforma no tipo ParkingLot e pega o name
          ),
          WeightedKey(
            name: 'adress',
            weight: 1.0,
            getter: (parkingLot) => (parkingLot as ParkingLot).adress,
          ),
        ],
        threshold:
            0.4, // grau de similaridade quanto mais próximo de 1.0 mais rígido deve ser, quanto mais baixo mais tolerante a erro
        distance:
            100, //define um limite de busca por similaridade, se nao impoem um limite, pode pesar muito o app
      ),
    );

    final results = fuse.search(
      query,
    ); //vai executar a procura com base no texto digitado
    setState(() {
      filteredParkingLots =
          results
              .map(
                (r) => r.item as ParkingLot,
              ) //r é uma variavel temporaria para pegar cada item da lista de parkingLots
              .toList(); //conversão dos resultados da procura em tipo ParkingLot e transformando eles em lista
      _showSuggestions = true;
      _isSearching = true;
      _showAnimatedSuggestions = true;
      _suggestionOpacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      //bloqueia o build de ser processado até q de fato tenha carreagdo os parkingLot do banco de dados
      return const Center(child: CircularProgressIndicator());
    }

    //tipos de mapa e suas cores
    const lightTileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    const darkTileUrl =
        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDarkMode ? darkTileUrl : lightTileUrl;

    //mudança da cor dos markers
    const lightMarker = 'assets/parkingIcon.png';
    const darkMarker = 'assets/parkingIconWhite.png';
    final marker = isDarkMode ? darkMarker : lightMarker;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            100, //define area útil do appBar, para não ocorrer sobreposição
        backgroundColor: MyColors.darkBlue,
        elevation: 0,

        title: Column(
          children: [
            TextField(
              focusNode: _searchFocusNode,
              controller:
                  _searchController, //controle do texto está sendo feito pela classe TextEditingController do flutter
              style: const TextStyle(color: Colors.white),
              onTap: () {
                if (!_isSearching) {
                  //se ja tiver ativa, evita que chame varias vezes pq so chama quando não está procurando
                  _isSearching = true;
                }
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    _showSuggestions = true;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: MyColors.darkBlue1,
                hintText: "Buscar estacionamento",
                hintStyle: const TextStyle(color: Color(0xFFDCDCDC)),
                prefixIcon: const Icon(
                  Icons.search, //icone da lupa do proprio flutter
                  color: Color(0xFFDCDCDC),
                ),

                suffixIcon:
                    _isSearching
                        ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFFDCDCDC),
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _isSearching = false;
                              _showSuggestions = false;
                              _suggestionOpacity = 0.0;
                              _showAnimatedSuggestions = false;
                              _searchFocusNode.unfocus();
                              filteredParkingLots = List.from(parkingLots);
                            });
                          },
                        )
                        : const SizedBox.shrink(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: Color(0xFFC0C0C0),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
              onChanged: (value) {
                //quando troca ele vai ter valor
                setState(() {
                  //vai retornar isSearching como true para qualquer caracter no TextField
                  _isSearching = value.isNotEmpty;
                  _filterParkingLots(
                    value,
                  ); //esta recebendo a query para executar o método, setado la em cima
                });
              },
            ),
          ],
        ),
      ),
      //usando stack para as sugestoes sobreporem o mapa sem alterar seu tamanho, similar ao googlemaps
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            padding: const EdgeInsets.all(8),
            constraints:
                const BoxConstraints.expand(), // deixe de ocupar só o espaço necessário para o filhos e faz o container se expandir ao m
            decoration: BoxDecoration(
              color: const Color(0xFFd9d9d9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                //o inicial do mapa acompanha os limites definidos
                initialCenter:
                    _currentLocation ??
                    LatLng(
                      -23.55052,
                      -46.633308,
                    ), // posição inicial, abre sp se permissao for negada
                initialZoom: 17, //zoom inicial
                onTap:
                    (tapPosition, point) => setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _showSuggestions = false;
                      }
                    }),
              ),

              children: [
                //define a camada básica do mapa
                TileLayer(
                  urlTemplate:
                      tileUrl, //x e y são as coodernadas, z é o zoom e s é o subdomínio
                  subdomains: [
                    'a',
                    'b',
                    'c',
                  ], //subdominio do mapa, melhora performance
                  userAgentPackageName: 'com.seuapp.nome',
                ),
                if (_currentLocation != null)
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ],
                  ),

                MarkerLayer(
                  //para o marker acompanhar a rotação do mapa
                  rotate: true,
                  markers:
                      //maneira para percorrer todos os estacionamento da lista parkingLots e dando uma variável temporária lot para pegar a posição deste estacionamento
                      parkingLots.map((lot) {
                        return Marker(
                          point:
                              lot.location, //localização do ponto de estacionamento
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ParkingStreamBuilder(
                                        initialParkingLot: lot,
                                      ),
                                  //estou enviando o estacionamento para tela ParkingLayoutScreen
                                ),
                              );
                            },
                            child: Image.asset(marker, width: 36, height: 36),
                          ),
                        );
                      }).toList(), //convertendo para lista de marcadores, que se parece com uma lista mas n é de fato, então convertemos
                ),
              ],
            ),
          ),

          if (_showSuggestions && _isSearching)
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              //efeito de opacidade
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                //vai de 0 até a opacidade 1
                opacity: _suggestionOpacity,
                //começa lento, acelera e diminui
                curve: Curves.easeInOut,
                //efeito de expansão e colapso
                child: AnimatedSize(
                  //tamanho do widget tile vai crescendo por 300 miliseconds até chegar no tamanho total
                  duration: const Duration(milliseconds: 300),
                  //mesma ideia de suavização
                  curve: Curves.easeInOut,
                  child:
                      _showAnimatedSuggestions
                          ? Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: MyColors.lightGray,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 36,
                                  ),
                                ],
                              ),

                              //lista rolavel
                              child: ListView.builder(
                                shrinkWrap: true, //ocupa só o espaço necessário
                                physics:
                                    const ClampingScrollPhysics(), //trava a lista quando chega ao fim
                                itemCount:
                                    filteredParkingLots
                                        .length, //quantos itens a lista vai ter
                                //constroi cada item
                                itemBuilder: (context, index) {
                                  final parkingLot = filteredParkingLots[index];
                                  // veririfica se o estacionamento ja ta favoritado ou nao
                                  final isFavorite = _favoriteParkingLotIds
                                      .contains(parkingLot.id);
                                  //widget padrão para itens de lista, ja vem com funcoes basicas, para cada index ele cria um listTile novo
                                  return ListTile(
                                    //widget personalizado do arquivo match_highlighter
                                    title: HighlightedText(
                                      text: parkingLot.name,
                                      query:
                                          _searchController.text.toLowerCase(),
                                      normalStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                      highlightedStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MyColors.gray,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: HighlightedText(
                                      text: parkingLot.adress,
                                      query:
                                          _searchController.text.toLowerCase(),
                                      normalStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                      highlightedStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MyColors.gray,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      color: Colors.black,
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                      ),
                                      onPressed: () {
                                        //para salvar no firestore
                                        final newStatus = !isFavorite;
                                        toggleFavorite(
                                          parkingLot.id,
                                          newStatus,
                                        );
                                        setState(() {
                                          if (newStatus) {
                                            _favoriteParkingLotIds.add(
                                              parkingLot.id,
                                            );
                                          } else {
                                            _favoriteParkingLotIds.remove(
                                              parkingLot.id,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      //quando abro o estacionamento ele ja deixa direcionado para o marker para quando voltar
                                      final LatLng latLng = parkingLot.location;
                                      _mapController.move(
                                        latLng,
                                        _mapController.camera.zoom,
                                      );
                                      setState(() {
                                        _searchController.text =
                                            parkingLot.name;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ParkingStreamBuilder(
                                                initialParkingLot: parkingLot,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                          : const SizedBox(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.darkBlue,
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 17); // Centraliza e dá zoom
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, //define o indice da tela, como é a primeira é 0
        // cada Item tem um index, quando clica nele ele ve qual if bate
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
