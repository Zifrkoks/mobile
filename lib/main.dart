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
        useMaterial3: true, // Включение Material Design 3
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
      // Убрали AppBar для чистого дизайна
      body: Container(
        // Фоновый градиент - основной визуальный ресурс
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Темно-синий
              Color(0xFF0D47A1), // Синий
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок с улучшенной стилизацией
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4, // Увеличенное расстояние между буквами
                ),
              ),
              const SizedBox(height: 8),
              
              // Подзаголовок
              const Text(
                'Объединяй плитки и достигни 2048!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70, // Полупрозрачный белый
                ),
              ),
              const Spacer(flex: 1),
              
              // Контейнер для кнопок с фиксированной шириной
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    // Основная кнопка - стилизована
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
                        backgroundColor: Colors.orange, // Яркий акцентный цвет
                      ),
                      child: const Text(
                        'Начать игру',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Вторичная кнопка с контуром
                    OutlinedButton(
                      onPressed: () {
                        _showHowToPlayDialog(context); // Вызов диалога
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.white), // Белая рамка
                      ),
                      child: const Text(
                        'Как играть',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Текстовая кнопка
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop(); // Выход из приложения
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
              
              // Нижний колонтитул
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

  // Метод для показа диалогового окна (ресурс UI)
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

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

// State класс для управления состоянием игрового экрана
class _Game2048ScreenState extends State<Game2048Screen> {
  // Переменные состояния
  int score = 0;
  bool gameOver = false;
  
  // Хук инициализации состояния
  @override
  void initState() {
    super.initState();
    // Инициализация игры
    _initGame();
  }
  
  // Метод инициализации игры
  void _initGame() {
    setState(() {
      score = 0;
      gameOver = false;
    });
  }
  
  // Хук обновления состояния при изменении зависимостей
  @override
  void didUpdateWidget(covariant Game2048Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      ),
      body: Column(
        children: [
          // Панель счета
          Container(
            padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(
                        fontSize: 32,
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
                      '0', // Заглушка для лучшего счета
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Игровое поле (заглушка)
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Игровое поле в разработке'),
                ),
              ),
            ),
          ),
          
          // Кнопки управления
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _initGame, // Сброс состояния игры
              child: const Text('Новая игра'),
            ),
          ),
        ],
      ),
    );
  }
}