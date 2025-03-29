// Текущий пользователь
// String? currentUsername;

// Вместо currentUsername в globals.dart
int? currentUserId;  // Изменить тип
String? currentUserToken; // Добавить для будущей аутентификации

// Текущая валюта
String currentCurrency = 'KGS';

// Курсы валют
Map<String, double> currency = {
  'USD': 1,
  'EUR': 0.9,
  'INR': 85,
  'KGS': 85,
};
