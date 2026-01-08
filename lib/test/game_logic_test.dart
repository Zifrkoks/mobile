import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  group('Game Logic Tests', () {
    late Game2048ScreenState gameState;

    setUp(() {
      gameState = Game2048ScreenState();
      // Инициализация состояния для тестов
      gameState.grid = List.generate(4, (_) => List.generate(4, (_) => 0));
      gameState.score = 0;
      gameState.gameOver = false;
      gameState.gameWon = false;
    });
    
    test('Initial game state should have two tiles', () {
      gameState.initGame();
      
      int tileCount = 0;
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (gameState.grid[i][j] != 0) {
            tileCount++;
          }
        }
      }
      
      expect(tileCount, 2);
    });
    
    test('Move left - basic merge', () {
      // Устанавливаем тестовое состояние: [2, 2, 0, 0]
      gameState.grid[0] = [2, 2, 0, 0];
      
      gameState.moveLeft();
      
      // Ожидаемый результат: [4, 0, 0, 0]
      expect(gameState.grid[0][0], 4);
      expect(gameState.grid[0][1], 0);
      expect(gameState.score, 4); // Очки за слияние
    });
    
    test('Move left - multiple merges', () {
      // [2, 2, 2, 2] → [4, 4, 0, 0]
      gameState.grid[0] = [2, 2, 2, 2];
      
      gameState.moveLeft();
      
      expect(gameState.grid[0][0], 4);
      expect(gameState.grid[0][1], 4);
      expect(gameState.grid[0][2], 0);
      expect(gameState.grid[0][3], 0);
      expect(gameState.score, 8); // 4 + 4
    });
    
    test('Move right - basic merge', () {
      gameState.grid[0] = [0, 0, 2, 2];
      
      gameState.moveRight();
      
      expect(gameState.grid[0][2], 0);
      expect(gameState.grid[0][3], 4);
      expect(gameState.score, 4);
    });
    
    test('Check game over - empty cells present', () {
      gameState.grid[0][0] = 2;
      
      gameState.checkGameOver();
      
      expect(gameState.gameOver, false);
    });
    
    test('Check game over - no moves possible', () {
      // Заполняем сетку без возможных слияний
      gameState.grid = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      
      gameState.checkGameOver();
      
      expect(gameState.gameOver, true);
    });
    
    test('Check game over - moves possible', () {
      // Два одинаковых числа рядом
      gameState.grid = [
        [2, 2, 4, 8],
        [4, 8, 16, 32],
        [2, 4, 8, 16],
        [16, 32, 64, 128],
      ];
      
      gameState.checkGameOver();
      
      expect(gameState.gameOver, false);
    });
    
    test('Win detection - tile 2048 created', () {
      gameState.grid[0][0] = 1024;
      gameState.grid[0][1] = 1024;
      
      gameState.moveLeft();
      
      expect(gameState.gameWon, true);
      expect(gameState.grid[0][0], 2048);
    });
    
    test('Score calculation - multiple merges', () {
      gameState.grid[0] = [2, 2, 4, 4];
      
      gameState.moveLeft();
      
      // [2,2,4,4] → [4,8,0,0]
      // Очки: 4 (2+2) + 8 (4+4) = 12
      expect(gameState.score, 12);
    });
    
    test('Random tile generation - probability', () {
      // Тестируем, что добавляется только в пустые клетки
      gameState.grid = [
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [32, 64, 128, 256],
        [0, 0, 0, 0],
      ];
      
      int emptyCellsBefore = 0;
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (gameState.grid[i][j] == 0) emptyCellsBefore++;
        }
      }
      
      gameState.addRandomTileWithValidation();
      
      int emptyCellsAfter = 0;
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (gameState.grid[i][j] == 0) emptyCellsAfter++;
        }
      }
      
      expect(emptyCellsAfter, emptyCellsBefore - 1);
    });
    
    test('Grid validation - negative values', () {
      // Симуляция ошибки: отрицательное значение
      gameState.grid[0][0] = -1;
      
      gameState.validateGridState(gameState.grid);
      
      expect(gameState.grid[0][0], 0); // Должно быть исправлено
    });
  });
  
  group('Point Class Tests', () {
    test('Point creation and properties', () {
      final point = Point(2, 3);
      
      expect(point.x, 2);
      expect(point.y, 3);
    });
    
    test('Point equality', () {
      final point1 = Point(1, 1);
      final point2 = Point(1, 1);
      final point3 = Point(2, 2);
      
      expect(point1.x == point2.x && point1.y == point2.y, true);
      expect(point1.x == point3.x && point1.y == point3.y, false);
    });
  });
}