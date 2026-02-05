import 'package:flutter/material.dart';
import '../models/memory_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<MemoryCard> cards = [];

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() {
    List<IconData> icons = [
      Icons.favorite, Icons.star, Icons.wb_sunny, Icons.pets, 
      Icons.directions_car, Icons.airplanemode_active, Icons.anchor, Icons.alarm,
      Icons.build, Icons.cake, Icons.cloud, Icons.computer,
      Icons.directions_bike, Icons.fastfood, Icons.home, Icons.lightbulb,
      Icons.music_note, Icons.palette
    ];

    List<IconData> cardIcons = [...icons, ...icons];

    cardIcons.shuffle(); 

    cards = List.generate(cardIcons.length, (index) {
      return MemoryCard(
        id: index,
        icon: cardIcons[index],
      );
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Juego de Memoria")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, 
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return _buildCard(cards[index]);
            },
          ),
        ),
      ),
    );
  }

Widget _buildCard(MemoryCard card) {
    return InkWell( // [cite: 58]
      onTap: () {
        setState(() {
          card.isFaceUp = !card.isFaceUp; 
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: card.isFaceUp || card.isMatched ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Center(
          child: Icon(
            card.isFaceUp || card.isMatched ? card.icon : Icons.help_outline,
            color: card.isFaceUp || card.isMatched ? Colors.blue : Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
