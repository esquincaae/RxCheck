import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Domain / Application / Infrastructure / Presentation imports omitidos por brevedad
// Importa aquí todos tus datasources, repositorios, usecases y viewmodels

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['API_URL']!;

  // Datasources
  final authDs = HttpAuthDataSource('$baseUrl/user');
  final recipeDs = HttpRecipeDataSource(baseUrl);
  final userDs = HttpUserDataSource('$baseUrl/user');

  // Repositories
  final authRepo = AuthRepositoryImpl(authDs, storage, prefs);
  final recipeRepo = RecipeRepositoryImpl(recipeDs, storage);
  final userRepo = UserRepositoryImpl(userDs, storage, prefs);

  // Use cases
  final loginUc = LoginUseCase(authRepo);
  final signupUc = SignupUseCase(authRepo);
  final fetchRecipesUc = FetchRecipesUseCase(recipeRepo);
  final fetchMedsUc = FetchMedicationsUseCase(recipeRepo);
  final fetchQrUc = FetchQrUseCase(recipeRepo);
  final supplyMedsUc = SupplyMedicationsUseCase(recipeRepo);
  final getUserUc = GetUserUseCase(userRepo);
  final updateProfileUc = UpdateProfileUseCase(userRepo);
  final updateImageUc = UpdateImageUseCase(userRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginUc)),
        ChangeNotifierProvider(create: (_) => SignupViewModel(signupUc)),
        ChangeNotifierProvider(create: (_) => RecipeListViewModel(fetchRecipesUc)),
        ChangeNotifierProvider(
            create: (_) => RecipeDetailViewModel(fetchMedsUc, fetchQrUc, supplyMedsUc)),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel(getUserUc, updateProfileUc, updateImageUc)),
        // Añade más ViewModels si los creaste
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RxCheck',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    ),
  );
}
