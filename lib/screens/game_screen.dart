import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int score = 0;
  int highScore = 0;

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      await prefs.setInt('highScore', score);
      setState(() => highScore = score);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Nuevo Récord Local!')),
      );
    }
  }



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
      score += 10;

      _saveHighScore();

      if (cards.every((card) => card.isMatched)) {
        _saveHighScore();
      }
      _resetTurn();
    } else {
      score = (score - 2).clamp(0, 999999);

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
    _loadHighScore();
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

  void _resetGame() {
    _saveHighScore();
    
    setState(() {
    attempts = 0;
    score = 0;
    firstCard = null;
    secondCard = null;
    isBusy = false;
    _generateCards();
  });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Memoria UNIMET"),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetGame, 
          tooltip: "Reiniciar Juego",
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoCard("Puntaje", "$score"),
              _infoCard("Récord", "$highScore"),
              _infoCard("Intentos", "$attempts"),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
      ],
    ),
  );
}

Widget _infoCard(String label, String value) {
  return Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    ],
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