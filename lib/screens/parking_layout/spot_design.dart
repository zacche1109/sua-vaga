import 'package:flutter/material.dart';
import 'package:sua_vaga/models/spot_model.dart';

class CustomSpotDesign extends StatefulWidget {
  final Spot spot;
  final double currentScale;

  const CustomSpotDesign({
    super.key,
    required this.spot,
    required this.currentScale,
  });

  @override
  State<CustomSpotDesign> createState() => _CustomSpotDesignState();
}

class _CustomSpotDesignState extends State<CustomSpotDesign> {
  IconData? _getSpotIcon() {
    switch (widget.spot.type) {
      case 'carro':
        return Icons.directions_car;
      case 'moto':
        return Icons.motorcycle;
      case 'deficiente':
        return Icons.accessible;
      default:
        return null;
    }
  }

  //pega altura da vaga (size) e a escala atual
  double scaledValue(double size, double scale) {
    final raw = size / scale;

    // Define limites dinâmicos para o icone e texto com base no tamanho da vaga, para evitar overflow
    final min = size * 0.1; // mínimo 10% da altura da vaga
    final max = size * 0.20; // máximo 20% da altura da vaga

    //retorna um limite de tamanho máximo e mínimo
    return raw.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.spot.toggleStatus();
        });
      },
      onLongPress: () {
        _showSpotDetails(widget.spot);
      },
      child: Container(
        width: widget.spot.width,
        height: widget.spot.height,
        decoration: BoxDecoration(
          color: widget.spot.status ? Colors.green[600] : Colors.red,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white,
            width: 1 / widget.currentScale,
          ), //a borda deve acompanhar a escala
        ),
        child:
            (widget.spot.width >= widget.spot.height * 1.5)
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.spot.id,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scaledValue(
                          widget.spot.width,
                          widget.currentScale,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _getSpotIcon(),
                      color: Colors.black,
                      size: scaledValue(widget.spot.width, widget.currentScale),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.spot.id,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scaledValue(
                          widget.spot.width,
                          widget.currentScale,
                        ),
                      ),
                    ),
                    Icon(
                      _getSpotIcon(),
                      color: Colors.black,
                      size: scaledValue(widget.spot.width, widget.currentScale),
                    ),
                  ],
                ),
      ),
    );
  }

  void _showSpotDetails(Spot spot) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Vaga ${spot.id}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${spot.type}'),
                Text('Status: ${spot.status ? 'Disponível' : 'Ocupada'}'),
                if (spot.type == 'deficiente')
                  const Text('Vaga prioritária para deficientes'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }
}
