import 'package:flutter/material.dart';
import '../models/memory_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<MemoryCard> cards = [];
  MemoryCard? firstCard;
  MemoryCard? secondCard;
  bool isBusy = false;
  int attempts = 0;

  void _onCardTap(MemoryCard card) {
    if (card.isFaceUp || card.isMatched || isBusy) return;

    setState(() {
      card.isFaceUp = true;

      if (firstCard == null) {
        firstCard = card;
      } else {
        secondCard = card;
        _checkMatch();
      }
    });
  }

  void _checkMatch() async {
    isBusy = true;
    attempts++;

    if (firstCard!.icon == secondCard!.icon) {
      firstCard!.isMatched = true;
      secondCard!.isMatched = true;
      _resetTurn();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        firstCard!.isFaceUp = false;
        secondCard!.isFaceUp = false;
      });
      _resetTurn();
    }
  }

  void _resetTurn() {
    setState(() {
      firstCard = null;
      secondCard = null;
      isBusy = false;
    });
  }

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
    return InkWell(
      onTap: () => _onCardTap(card),
      child: Container(
        decoration: BoxDecoration(
          color: card.isFaceUp || card.isMatched ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            card.isFaceUp || card.isMatched ? card.icon : Icons.help_outline,
            size: 30,
            color: card.isFaceUp || card.isMatched ? Colors.blue : Colors.white,
          ),
        ),
      ),
    );
  }
}