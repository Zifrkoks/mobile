import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Объединяй плитки и достигни 2048!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const Spacer(flex: 1),
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Game2048Screen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Начать игру',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _showHowToPlayDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text(
                        'Как играть',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        'Выйти',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              const Text(
                '© 2024 2048 Game',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Как играть'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Используйте стрелки для перемещения плиток'),
              SizedBox(height: 8),
              Text('2. Плитки с одинаковыми номерами объединяются'),
              SizedBox(height: 8),
              Text('3. Постарайтесь получить плитку 2048'),
              SizedBox(height: 8),
              Text('4. Игра заканчивается, когда не останется возможных ходов'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class Point {
  final int x;
  final int y;
  
  Point(this.x, this.y);
}

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  _Game2048ScreenState createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late List<List<int>> grid;
  int score = 0;
  int bestScore = 0; // Добавлен лучший счет
  bool gameOver = false;
  bool gameWon = false; // Флаг победы

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => 0));
      score = 0;
      gameOver = false;
      gameWon = false;
      addRandomTile();
      addRandomTile();
    });
  }

  void addRandomTile() {
    List<Point> emptyCells = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }
    
    if (emptyCells.isNotEmpty) {
      Point cell = emptyCells[DateTime.now().millisecond % emptyCells.length];
      grid[cell.x][cell.y] = (DateTime.now().millisecond % 10 == 0) ? 4 : 2;
    }
  }
  // Движение влево - основная логика игры
  void moveLeft() {
    bool moved = false;
    
    for (int i = 0; i < 4; i++) {
      List<int> row = grid[i];
      List<int> newRow = [];
      
      // Собираем все ненулевые элементы
      for (int j = 0; j < 4; j++) {
        if (row[j] != 0) {
          newRow.add(row[j]);
        }
      }
      
      // Слияние одинаковых плиток
      for (int j = 0; j < newRow.length - 1; j++) {
        if (newRow[j] == newRow[j + 1]) {
          newRow[j] *= 2;
          score += newRow[j]; // Увеличение счета
          newRow.removeAt(j + 1);
        }
      }
      
      // Дополняем нулями до 4 элементов
      while (newRow.length < 4) {
        newRow.add(0);
      }
      
      // Проверка, было ли движение
      for (int j = 0; j < 4; j++) {
        if (row[j] != newRow[j]) {
          moved = true;
        }
      }
      
      grid[i] = newRow;
    }
    
    if (moved) {
      addRandomTile();
      checkGameOver();
    }
    
    setState(() {});
  }

    // Движение вправо
    void moveRight() {
      bool moved = false;
      
      for (int i = 0; i < 4; i++) {
        List<int> row = grid[i];
        List<int> newRow = [];
        
        // Собираем справа налево
        for (int j = 3; j >= 0; j--) {
          if (row[j] != 0) {
            newRow.insert(0, row[j]);
          }
        }
        
        // Слияние справа налево
        for (int j = newRow.length - 1; j > 0; j--) {
          if (newRow[j] == newRow[j - 1]) {
            newRow[j] *= 2;
            score += newRow[j];
            newRow.removeAt(j - 1);
          }
        }
        
        // Дополняем нулями слева
        while (newRow.length < 4) {
          newRow.insert(0, 0);
        }
        
        for (int j = 0; j < 4; j++) {
          if (row[j] != newRow[j]) {
            moved = true;
          }
        }
        
        grid[i] = newRow;
      }
      
      if (moved) {
        addRandomTile();
        checkGameOver();
      }
      
      setState(() {});
    }
  // Движение вверх
  void moveUp() {
    bool moved = false;
    
    for (int j = 0; j < 4; j++) {
      List<int> column = [];
      for (int i = 0; i < 4; i++) {
        column.add(grid[i][j]);
      }
      
      List<int> newColumn = [];
      
      for (int i = 0; i < 4; i++) {
        if (column[i] != 0) {
          newColumn.add(column[i]);
        }
      }
      
      for (int i = 0; i < newColumn.length - 1; i++) {
        if (newColumn[i] == newColumn[i + 1]) {
          newColumn[i] *= 2;
          score += newColumn[i];
          if (newColumn[i] == 2048 && !gameWon) {
            gameWon = true;
            _showWinDialog(); // Показ диалога победы
          }
          newColumn.removeAt(i + 1);
        }
      }
      
      while (newColumn.length < 4) {
        newColumn.add(0);
      }
      
      for (int i = 0; i < 4; i++) {
        if (column[i] != newColumn[i]) {
          moved = true;
        }
        grid[i][j] = newColumn[i];
      }
    }
    
    if (moved) {
      addRandomTile();
      checkGameOver();
      _updateBestScore();
    }
    
    setState(() {});
  }

  // Движение вниз
  void moveDown() {
    bool moved = false;
    
    for (int j = 0; j < 4; j++) {
      List<int> column = [];
      for (int i = 0; i < 4; i++) {
        column.add(grid[i][j]);
      }
      
      List<int> newColumn = [];
      
      for (int i = 3; i >= 0; i--) {
        if (column[i] != 0) {
          newColumn.insert(0, column[i]);
        }
      }
      
      for (int i = newColumn.length - 1; i > 0; i--) {
        if (newColumn[i] == newColumn[i - 1]) {
          newColumn[i] *= 2;
          score += newColumn[i];
          if (newColumn[i] == 2048 && !gameWon) {
            gameWon = true;
            _showWinDialog();
          }
          newColumn.removeAt(i - 1);
        }
      }
      
      while (newColumn.length < 4) {
        newColumn.insert(0, 0);
      }
      
      for (int i = 0; i < 4; i++) {
        if (column[i] != newColumn[i]) {
          moved = true;
        }
        grid[i][j] = newColumn[i];
      }
    }
    
    if (moved) {
      addRandomTile();
      checkGameOver();
      _updateBestScore();
    }
    
    setState(() {});
  }

  // Обновление лучшего счета
  void _updateBestScore() {
    if (score > bestScore) {
      setState(() {
        bestScore = score;
      });
    }
  }

  void checkGameOver() {
    if (gameWon) return;
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          return;
        }
      }
    }
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (j < 3 && grid[i][j] == grid[i][j + 1]) {
          return;
        }
        if (i < 3 && grid[i][j] == grid[i + 1][j]) {
          return;
        }
      }
    }
    
    gameOver = true;
  }

  // Диалог победы
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Победа!'),
        content: const Text('Вы достигли плитки 2048! Хотите продолжить игру?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Продолжить'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              initGame();
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
  }

  // Цвет текста в зависимости от цвета плитки
  Color getTextColor(int value) {
    return value < 8 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('2048'),
        centerTitle: true,
        actions: [
          // Кнопка перезапуска в AppBar
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: initGame,
            tooltip: 'Новая игра',
          ),
        ],
      ),
      body: Column(
        children: [
          // Улучшенная информационная панель
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Текущий счет
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'СЧЕТ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Лучший счет
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'РЕКОРД',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '$bestScore',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Игровое поле с тенью
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int row = index ~/ 4;
                      int col = index % 4;
                      int value = grid[row][col];
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: getTileColor(value),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: value > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: value == 0
                              ? const SizedBox()
                              : Text(
                                  '$value',
                                  style: TextStyle(
                                    fontSize: value < 100 ? 24 : 
                                             value < 1000 ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: getTextColor(value),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Сообщения о состоянии игры
          if (gameWon)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Вы достигли 2048! Продолжайте играть!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          if (gameOver)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Игра окончена! Начните новую игру.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // Полноценная панель управления
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      // Кнопка вверх
                      IconButton(
                        onPressed: moveUp,
                        icon: const Icon(Icons.keyboard_arrow_up, size: 40),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Кнопки влево/вправо
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: moveLeft,
                            icon: const Icon(Icons.keyboard_arrow_left, size: 40),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            onPressed: moveRight,
                            icon: const Icon(Icons.keyboard_arrow_right, size: 40),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Кнопка вниз
                      IconButton(
                        onPressed: moveDown,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 40),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: initGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Новая игра'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('В меню'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Используйте кнопки для перемещения плиток',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2: return Colors.orange[50]!;
      case 4: return Colors.orange[100]!;
      case 8: return Colors.orange[200]!;
      case 16: return Colors.orange[300]!;
      case 32: return Colors.orange[400]!;
      case 64: return Colors.orange[500]!;
      case 128: return Colors.orange[600]!;
      case 256: return Colors.orange[700]!;
      case 512: return Colors.orange[800]!;
      case 1024: return Colors.orange[900]!;
      case 2048: return Colors.deepOrange;
      default: return Colors.grey[200]!;
    }
  }
}