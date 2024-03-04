import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class CardModel extends ChangeNotifier {
  List<CardItem> cards = [];

  CardModel() {
    for (int i = 1; i <= 8; i++) {
      cards.add(CardItem(id: i, frontImagePath: "assets/cardImage$i.jpg"));
      cards.add(CardItem(id: i, frontImagePath: "assets/cardImage$i.jpg"));
    }
    cards.shuffle();
  }

  List<int> faceUpCards = [];
  int matches = 0;

  void flipCard(int index) async {
    if (faceUpCards.length < 2 && !cards[index].isFaceUp) {
      cards[index].isFaceUp = true;
      faceUpCards.add(index);

      if (faceUpCards.length == 2) {
        if (cards[faceUpCards[0]].id == cards[faceUpCards[1]].id) {
          matches += 2;
          if (matches == 16) {
            print("Game Won!");
          }
        } else {
          cards[index].isFaceUp = true;
          await Future.delayed(Duration(milliseconds: 500));
          cards[faceUpCards[0]].isFaceUp = false;
          cards[faceUpCards[1]].isFaceUp = false;
          notifyListeners();
        }
        faceUpCards = [];
      }

      notifyListeners();
    }
  }

  void resetGame() {
    for (var card in cards) {
      card.isFaceUp = false;
    }
    cards.shuffle();
    faceUpCards = [];
    matches = 0;
    notifyListeners();
  }
}

class CardItem {
  final int id;
  final String frontImagePath;
  bool isFaceUp;

  CardItem({required this.id, required this.frontImagePath, this.isFaceUp = false});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardModel(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool showCongrats = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 12),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    CardModel cardModel = Provider.of<CardModel>(context);

    if (cardModel.matches == 16 && !showCongrats) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          showCongrats = true;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '                Matchtoria',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Garamond'),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.green.shade900,
            child: Center(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: Provider.of<CardModel>(context).cards.length,
                itemBuilder: (context, index) {
                  return CardWidget(index: index);
                },
              ),
            ),
          ),
          if (showCongrats) _buildCongratsWidget(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<CardModel>(context, listen: false).resetGame();
          setState(() {
            showCongrats = false;
          });
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    CardModel cardModel = Provider.of<CardModel>(context);

    return BottomAppBar(
      color: Colors.green.shade900,
      child: Container(
        height: 50,
        child: Center(
          child: cardModel.matches == 16
              ? Container()
              : Text(
                  'Matched Cards: ${cardModel.matches} out of 16',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Garamond'),
                ),
        ),
      ),
    );
  }

  Widget _buildCongratsWidget() {
  return Container(
    color: Colors.green.shade900.withOpacity(0.9),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(CurvedAnimation(
              parent: animationController,
              curve: Curves.easeInOut,
            )),
            child: Image.asset(
              'assets/congratulations_Icon.png',
              height: 300,
              width: 300,
            ),
          ),
          SizedBox(height: 30, width: 50),
          ElevatedButton(
            onPressed: () {
              Provider.of<CardModel>(context, listen: false).resetGame();
              setState(() {
                showCongrats = false;
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
            ),
            child: Text(
              'Press to Play Again',
              style: TextStyle(color: Colors.green.shade900, fontSize: 22, fontFamily: 'Garamond'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class CardWidget extends StatelessWidget {
  final int index;

  CardWidget({required this.index});

  @override
  Widget build(BuildContext context) {
    CardModel cardModel = Provider.of<CardModel>(context);
    CardItem card = cardModel.cards[index];

    return GestureDetector(
      onTap: () {
        cardModel.flipCard(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(8),
        color: card.isFaceUp ? Colors.green.shade900 : Colors.black,
        child: Center(
          child: card.isFaceUp || cardModel.faceUpCards.contains(index)
              ? Image.asset(
                  card.frontImagePath,
                  height: 80,
                  width: 80,
                )
              : Image.asset(
                  'assets/cardBackImage.jpg',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
