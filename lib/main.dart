import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'dart:io' show Platform;

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
  int bestScore = 0;
  bool gameOver = false;
  bool gameWon = false;
  bool _isProcessingMove = false;
  
  // История ходов для отладки
  final List<String> _moveHistory = [];
  // Платформо-специфичные настройки
  final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
  final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final bool isWeb = kIsWeb;
  // Загрузка лучшего счета (заглушка)
  Future<void> _loadBestScore() async {
    try {
      // В реальном приложении здесь будет загрузка
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('Загрузка лучшего счета завершена');
    } catch (e) {
      debugPrint('Ошибка загрузки лучшего счета: $e');
    }
  }

  
  void _saveBestScore() async {
    try {
      if (score > bestScore) {
        setState(() {
          bestScore = score;
        });
        debugPrint('Новый рекорд: $bestScore');
      }
    } catch (e) {
      debugPrint('Ошибка сохранения рекорда: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    _loadBestScore();
    initGame();
    
    // Логирование для отладки
    debugPrint('Инициализация игрового экрана');
  }
  

  // Вибрация для мобильных устройств
  void _triggerVibration() {
    // Используем MethodChannel для нативной вибрации
    // Это упрощенный пример
    if (isAndroid) {
      // HapticFeedback.vibrate(); - в реальном приложении
    }
  }

  void initGame() {
    try {
      // Сброс всех состояний
      _isProcessingMove = false;
      _moveHistory.clear();
      
      setState(() {
        grid = List.generate(4, (_) => List.generate(4, (_) => 0));
        score = 0;
        gameOver = false;
        gameWon = false;
      });
      
      // Добавляем две начальные плитки
      _addRandomTileWithValidation();
      _addRandomTileWithValidation();
      
      debugPrint('Новая игра инициализирована');
    } catch (e) {
      debugPrint('Ошибка инициализации игры: $e');
      // Восстановление после ошибки
      _recoverFromError();
    }
  }
  void _recoverFromError() {
    debugPrint('Попытка восстановления после ошибки...');
    
    try {
      // Простая стратегия восстановления - новая игра
      initGame();
      debugPrint('Восстановление успешно');
    } catch (e) {
      debugPrint('Не удалось восстановиться: $e');
      // Последняя попытка - полный сброс
      setState(() {
        grid = List.generate(4, (_) => List.generate(4, (_) => 0));
        score = 0;
        gameOver = false;
        gameWon = false;
      });
    }
  }
   void _debugPrintGrid() {
    debugPrint('=== Текущее состояние игры ===');
    debugPrint('Счет: $score, Рекорд: $bestScore');
    debugPrint('GameOver: $gameOver, GameWon: $gameWon');
    for (int i = 0; i < 4; i++) {
      debugPrint('${grid[i][0]} ${grid[i][1]} ${grid[i][2]} ${grid[i][3]}');
    }
    debugPrint('=============================');
  }
  void _addRandomTileWithValidation() {
    try {
      List<Point> emptyCells = [];
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (grid[i][j] == 0) {
            emptyCells.add(Point(i, j));
          }
        }
      }
      
      if (emptyCells.isEmpty) {
        debugPrint('Нет пустых клеток для добавления плитки');
        return;
      }
      
      // Более надежный способ выбора случайной клетки
      final random = DateTime.now().microsecondsSinceEpoch;
      Point cell = emptyCells[random % emptyCells.length];
      
      // Проверка, что клетка действительно пустая
      if (grid[cell.x][cell.y] != 0) {
        debugPrint('Ошибка: клетка [${cell.x},${cell.y}] не пустая!');
        // Попытка найти другую пустую клетку
        for (var point in emptyCells) {
          if (grid[point.x][point.y] == 0) {
            cell = point;
            break;
          }
        }
      }
      
      // 90% шанс на 2, 10% на 4
      grid[cell.x][cell.y] = (random % 10 == 0) ? 4 : 2;
      debugPrint('Добавлена плитка ${grid[cell.x][cell.y]} в [${cell.x},${cell.y}]');
    } catch (e) {
      debugPrint('Ошибка добавления плитки: $e');
    }
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
    if (gameOver || gameWon || _isProcessingMove) return;
    _isProcessingMove = true;
    _moveHistory.add('LEFT - начальный счет: $score');
    try {
      bool moved = false;
      List<List<int>> oldGrid = _copyGrid(grid); // Сохраняем старое состояние
      for (int i = 0; i < 4; i++) {
        List<int> row = List.from(grid[i]);
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
            if (newRow[j] == 2048 && !gameWon) {
              gameWon = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showWinDialog();
              });
            }
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
            break;
          }
        }
        
        grid[i] = newRow;
      }
      
      if (moved) {
        addRandomTile();
        checkGameOver();
      }
      
      setState(() {});
    } catch (e) {
      debugPrint('Ошибка в moveLeft: $e');
      _moveHistory.add('LEFT - ОШИБКА: $e');
      // Восстановление из истории или перезапуск
      _recoverFromError();
    } finally {
      _isProcessingMove = false;
      setState(() {});
    }
  }

    // Движение вправо
    void moveRight() {
      if (gameOver || gameWon || _isProcessingMove) return;
      _isProcessingMove = true;
      _moveHistory.add('RIGHT - начальный счет: $score');
      try{
        List<List<int>> oldGrid = _copyGrid(grid); // Сохраняем старое состояние
        
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
              if (newRow[j] == 2048 && !gameWon) {
              gameWon = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showWinDialog();
              });
            }
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
              break;
            }
          }
          
          grid[i] = newRow;
        }
        
        if (moved) {
          addRandomTile();
          checkGameOver();
        }
        
        setState(() {});
      }catch (e) {
      debugPrint('Ошибка в moveRight: $e');
      _moveHistory.add('RIGHT - ОШИБКА: $e');
      // Восстановление из истории или перезапуск
      _recoverFromError();
    } finally {
      _isProcessingMove = false;
      setState(() {});
    }
    }
  // Движение вверх
  void moveUp() {
    
    if (gameOver || gameWon || _isProcessingMove) return;
    _isProcessingMove = true;
    _moveHistory.add('LEFT - начальный счет: $score');
    try{
      bool moved = false;
      List<List<int>> oldGrid = _copyGrid(grid); // Сохраняем старое состояние
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
    }catch (e) {
      debugPrint('Ошибка в moveLeft: $e');
      _moveHistory.add('LEFT - ОШИБКА: $e');
      // Восстановление из истории или перезапуск
      _recoverFromError();
    } finally {
      _isProcessingMove = false;
      setState(() {});
    }
  }

  // Движение вниз
  void moveDown() {
    if (gameOver || gameWon || _isProcessingMove) return;
    _isProcessingMove = true;
    _moveHistory.add('LEFT - начальный счет: $score');
    try{
      bool moved = false;
      List<List<int>> oldGrid = _copyGrid(grid); // Сохраняем старое состояние
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
    }catch (e) {
      debugPrint('Ошибка в moveLeft: $e');
      _moveHistory.add('LEFT - ОШИБКА: $e');
      // Восстановление из истории или перезапуск
      _recoverFromError();
    } finally {
      _isProcessingMove = false;
      setState(() {});
    }
  }
  // ИСПРАВЛЕННЫЙ метод проверки конца игры
  void _checkGameOver() {
    if (gameWon) return;
    
    try {
      // Проверка на наличие пустых клеток
      bool hasEmptyCell = false;
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (grid[i][j] == 0) {
            hasEmptyCell = true;
            break;
          }
        }
        if (hasEmptyCell) break;
      }
      
      if (hasEmptyCell) {
        gameOver = false;
        return;
      }
      
      // Проверка на возможные слияния по горизонтали
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
          if (grid[i][j] == grid[i][j + 1]) {
            gameOver = false;
            return;
          }
        }
      }
      
      // Проверка на возможные слияния по вертикали
      for (int j = 0; j < 4; j++) {
        for (int i = 0; i < 3; i++) {
          if (grid[i][j] == grid[i + 1][j]) {
            gameOver = false;
            return;
          }
        }
      }
      
      // Если дошли сюда - игра окончена
      gameOver = true;
      debugPrint('Игра окончена! Финальный счет: $score');
      
    } catch (e) {
      debugPrint('Ошибка в checkGameOver: $e');
      gameOver = false; // На всякий случай сбрасываем флаг
    }
  }

  // Вспомогательный метод для копирования сетки
  List<List<int>> _copyGrid(List<List<int>> source) {
    return List.generate(source.length, (i) => List.from(source[i]));
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
    bool isDebugMode = true;
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
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: initGame,
            tooltip: 'Новая игра',
          ),
          if (isDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _debugPrintGrid,
              tooltip: 'Отладка',
            ),
        ],
      ),
      body: GestureDetector(
        // Обработка свайпов для мобильных устройств
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Свайп вправо
            moveRight();
          } else if (details.primaryVelocity! < 0) {
            // Свайп влево
            moveLeft();
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Свайп вниз
            moveDown();
          } else if (details.primaryVelocity! < 0) {
            // Свайп вверх
            moveUp();
          }
        },
        child: Column(
          children: [
            // Информационная панель
            Container(
              padding: EdgeInsets.all(isWeb ? 20 : 16), // Адаптивный padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'СЧЕТ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: isWeb ? 36 : 32, // Больше на Web
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'РЕКОРД',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$bestScore',
                        style: TextStyle(
                          fontSize: isWeb ? 36 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  // Платформо-специфичная иконка
                  if (isAndroid)
                    const Icon(Icons.android, color: Colors.green),
                  if (isIOS)
                    const Icon(Icons.apple, color: Colors.grey),
                  if (isWeb)
                    const Icon(Icons.web, color: Colors.blue),
                ],
              ),
            ),
            
            // Адаптивное игровое поле
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Адаптивный размер в зависимости от платформы
                    double size = constraints.maxWidth > 600 
                        ? 400  // Для планшетов и десктопов
                        : constraints.maxWidth - 32; // Для телефонов
                    
                    return Container(
                      width: size,
                      height: size,
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
                            curve: Curves.easeInOut,
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
                                        fontSize: _getTileFontSize(value, size),
                                        fontWeight: FontWeight.bold,
                                        color: getTextColor(value),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
                ),
                child: const Text(
                  '🎉 Вы достигли 2048! Продолжайте играть!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (gameOver)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💥 Игра окончена! Начните новую игру.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Управление - скрываем кнопки на мобильных, если используются свайпы
            if (!isAndroid && !isIOS) // Показываем кнопки только на Web и десктопе
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: moveUp,
                            icon: const Icon(Icons.keyboard_arrow_up, size: 40),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: moveLeft,
                                icon: const Icon(Icons.keyboard_arrow_left, size: 40),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                onPressed: moveRight,
                                icon: const Icon(Icons.keyboard_arrow_right, size: 40),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: moveDown,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 40),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Используйте стрелки или свайпы',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            // Кнопки действий (всегда видны)
            Container(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: initGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Новая игра'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('В меню'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// Адаптивный размер шрифта для плиток
  double _getTileFontSize(int value, double containerSize) {
    double baseSize = containerSize / 16; // Базовая пропорция
    
    if (value < 100) return baseSize * 1.5;
    if (value < 1000) return baseSize * 1.2;
    return baseSize; // Для 1024, 2048
  }

  // Платформо-специфичный диалог
  void _showPlatformSpecificDialog(BuildContext context) {
    String platform = isAndroid ? 'Android' : isIOS ? 'iOS' : 'Unknown';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о платформе'),
        content: Text('Вы используете приложение на $platform'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '2048 Game',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Все права защищены',
      children: [
        const SizedBox(height: 16),
        const Text('Классическая игра 2048, адаптированная для всех платформ.'),
        const SizedBox(height: 8),
        Text('Платформа: ${isAndroid ? 'Android' : isIOS ? 'iOS' : 'Web'}'),
      ],
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