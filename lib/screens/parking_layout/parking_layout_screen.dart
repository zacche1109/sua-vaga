import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';
import 'package:sua_vaga/models/parking_model.dart';
import 'package:sua_vaga/screens/parking_layout/custom_floor_nav_bar.dart';
import 'package:sua_vaga/screens/parking_layout/spot_design.dart';
import 'package:sua_vaga/screens/parking_layout/build_elements.dart';

class ParkingLayoutScreen extends StatefulWidget {
  final ParkingLot parkingLot;
  const ParkingLayoutScreen({
    super.key,
    required this.parkingLot,
  }); //esta tela requere q na sua cosntrução venha do parametro parkingLot

  @override
  State<ParkingLayoutScreen> createState() => _ParkingLayoutScreenState();
}

class _ParkingLayoutScreenState extends State<ParkingLayoutScreen> {
  final TransformationController _transformationController =
      TransformationController(); //nativo no flutter controla zooms, movimentoe rotações num interactive viewer
  double _rotation = 0.0;
  double _scale = 1.0;
  int _currentFloorIndex = 0;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _scale = 1.0;
      _rotation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFloors =
        widget.parkingLot.floors != null &&
        widget.parkingLot.floors!.isNotEmpty;
    //Como não estou usando mais uma lista de floors eu n posso me basear apenas no seu Id, mas sim na chave do map
    //aqui ele pega todas as chaves dentro de floor
    final floorKeys = widget.parkingLot.floors?.keys.toList() ?? [];
    //vai pegar a floorKey do indice 0 por exemplo
    final currentFloorKey =
        hasFloors && floorKeys.length > _currentFloorIndex
            ? floorKeys[_currentFloorIndex]
            : null;
    final spots =
        hasFloors && currentFloorKey != null
            ? widget.parkingLot.floors![currentFloorKey]?.layout.spots
            : widget.parkingLot.layout!.spots;

    final elements =
        hasFloors && currentFloorKey != null
            ? widget.parkingLot.floors![currentFloorKey]?.layout.elements
            : widget.parkingLot.layout?.elements;
    //Para mandar o nome visual para o customNavBar
    final floorLabels =
        hasFloors
            ? widget.parkingLot.floors!.values.map((f) => f.label).toList()
            : <String>[];

    final width =
        hasFloors
            ? widget.parkingLot.floors![currentFloorKey]?.layout.width
            : widget.parkingLot.layout!.width;
    final height =
        hasFloors
            ? widget.parkingLot.floors![currentFloorKey]?.layout.height
            : widget.parkingLot.layout!.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        backgroundColor: MyColors.darkBlue,
        title: Center(
          child: Text(
            widget.parkingLot.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_left, color: Colors.white),
            onPressed: () {
              setState(() {
                //evitar acúmulo de valor, sempre mantem a rotação em um valor entre 0 e 360, até pq 360 e 720 é a mesma coisa por exemplo
                //_rotation = (_rotation - 90) % 360;
                //quando for negativo ele apenas transforma o valor em positivo
                //if (_rotation < 0) _rotation += 360;
                //Não fica tão bonito esteticamente usar valores entre 0 e 360 sempre, ent optei pelo acúmulo mesmo
                _rotation -= 90;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right, color: Colors.white),
            onPressed: () {
              setState(() {
                //_rotation = (_rotation + 90) % 360;
                _rotation += 90;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            onPressed: _resetZoom,
          ),
        ],
      ), //tenho q usar o widget porque a classe state, não reconhece de fato o parkinglot
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: Stack(
          children: [
            GestureDetector(
              onDoubleTap: _resetZoom,
              child: AnimatedRotation(
                turns: _rotation / 360,
                duration: const Duration(milliseconds: 300),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  //espaço extra invisível ao redor do conteúdo, quantos pixels pro lado além do conteúdo
                  boundaryMargin: EdgeInsets.all(400),
                  minScale: 0.01, //zoom mínimo
                  maxScale: 30, //zoom máximo
                  constrained: false, // permite ser maior que o visível
                  //onInteractionUpdate lança todo momento que tem qqrl interação coma tela
                  onInteractionUpdate: (details) {
                    setState(() {
                      // para atualizar em tempo real o zoom que o usuário faz, pega valor do scale atual
                      _scale =
                          _transformationController.value.getMaxScaleOnAxis();
                    });
                  },
                  //permite sobrepor widgets definindo suas posições a partir do postioned
                  child: Stack(
                    children: [
                      Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          color: Color(0xFF2B2B2F),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              //preto com opacidade 20%
                              color: Color(0x33000000),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      //entries retorna todos pares chave valor e transforma cada um q uma entidade entry e dps transforma spot no valor desta entidade
                      // que neste caso é classe spot
                      ...spots!.entries.map((entry) {
                        final spot = entry.value;

                        return Positioned(
                          left: spot.x,
                          top: spot.y,
                          child: Transform.rotate(
                            angle: (spot.rotation ?? 0) * (pi / 180),
                            alignment: Alignment.center,
                            child: CustomSpotDesign(
                              spot: spot,
                              currentScale: _scale,
                            ),
                          ),
                        );
                      }),
                      //aqui ja pega o valor direto pq n vou precisar da chave em nenhuma situação, la a chave é usada para exibir visualmente a vaga
                      ...elements!.values.map((e) {
                        return Positioned(
                          left: e.x,
                          top: e.y,
                          child: buildLayoutElement(e),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomFloorNavBar(
        floors: floorLabels,
        currentIndex: _currentFloorIndex,
        onTap: (index) {
          setState(() {
            //como é um setState ele reconstroi toda pagina de novo, por isso sempre altera
            _currentFloorIndex = index;
            _resetZoom();
          });
        },
      ),
    );
  }
}
