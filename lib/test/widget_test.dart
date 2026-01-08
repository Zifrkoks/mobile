import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Main menu screen renders correctly', (WidgetTester tester) async {
    // Создаем виджет
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));
    
    // Проверяем наличие ключевых элементов
    expect(find.text('2048'), findsOneWidget);
    expect(find.text('Начать игру'), findsOneWidget);
    expect(find.text('Как играть'), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
    
    // Проверяем наличие градиента
    expect(find.byType(Container), findsWidgets);
  });
  
  testWidgets('Game screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Game2048Screen()));
    
    // Проверяем наличие элементов игрового экрана
    expect(find.text('2048'), findsOneWidget);
    expect(find.text('СЧЕТ'), findsOneWidget);
    expect(find.text('РЕКОРД'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Новая игра'), findsOneWidget);
  });
  
  testWidgets('Navigation from main menu to game screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Game2048App());
    
    // Находим кнопку "Начать игру" и нажимаем
    await tester.tap(find.text('Начать игру'));
    await tester.pumpAndSettle();
    
    // Проверяем, что перешли на игровой экран
    expect(find.byType(Game2048Screen), findsOneWidget);
  });
  
  testWidgets('How to play dialog appears', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));
    
    // Нажимаем кнопку "Как играть"
    await tester.tap(find.text('Как играть'));
    await tester.pumpAndSettle();
    
    // Проверяем, что диалог появился
    expect(find.text('Как играть'), findsNWidgets(2)); // В кнопке и в диалоге
    expect(find.byType(AlertDialog), findsOneWidget);
  });
  
  testWidgets('Game reset button works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Game2048Screen()));
    
    // Нажимаем кнопку "Новая игра"
    await tester.tap(find.text('Новая игра'));
    await tester.pump();
    
    // Проверяем, что счет сбросился (в начальном состоянии)
    expect(find.text('0'), findsAtLeast(1));
  });
  
  testWidgets('Tile colors change based on value', (WidgetTester tester) async {
    final gameState = Game2048ScreenState();
    
    // Тестируем функцию getTileColor
    expect(gameState.getTileColor(2), Colors.orange[50]);
    expect(gameState.getTileColor(4), Colors.orange[100]);
    expect(gameState.getTileColor(2048), Colors.deepOrange);
    expect(gameState.getTileColor(0), Colors.grey[200]);
  });
  
  testWidgets('Text colors are contrast to tile colors', (WidgetTester tester) async {
    final gameState = Game2048ScreenState();
    
    // Для светлых плиток текст должен быть черным
    expect(gameState.getTextColor(2), Colors.black);
    expect(gameState.getTextColor(4), Colors.black);
    
    // Для темных плиток текст должен быть белым
    expect(gameState.getTextColor(128), Colors.white);
    expect(gameState.getTextColor(256), Colors.white);
  });
}